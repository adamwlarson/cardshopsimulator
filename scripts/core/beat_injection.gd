class_name BeatInjectionService
extends Node

const SPIKE_STAPLE_BEAT := &"sec10_4_spike_staple"
const RENT_FIRESALE_BEAT := &"sec10_6_rent_firesale"
const TITAN_HYPE_BEAT := &"sec10_7_titan_hype"
const SHOWCASE_BEAT := &"sec10_8_slab_vs_singles"
const MARKETPLACE_OUTING_BEAT := &"sec10_3_marketplace_outing"
const HIRE_CASHIER_BEAT := &"sec10_5_hire_cashier"
const EXPAND_MEDIUM_BEAT := &"sec10_9_expand_medium"
const SHADY_TRUNK_BEAT := &"sec10_10_shady_trunk"

const BASTION_SKU := &"AA-BASE-088"
const ARCBOLT_SKU := &"AA-BASE-078"
const DUST_ETB_SKU := &"AA-DUST-ETB"
const DUST_BLASTER_SKU := &"AA-DUST-BLST"
const TITAN_SKU := &"AA-SKIE-047"
const EMPRESS_SKU := &"AA-SKIE-052"
const PARAGON_SKU := &"AA-SKIE-058"
const SKIE_ETB_SKU := &"AA-SKIE-ETB"

var _started: Dictionary = {}
var _completed: Dictionary = {}
var _rent_price_path: StringName = &""
var _outing_opportunity_id: StringName = &""
var _shady_opportunity_id: StringName = &""


func _ready() -> void:
	EventBus.day_started.connect(_on_day_started)
	EventBus.day_phase_changed.connect(_on_day_phase_changed)
	EventBus.customer_resolved.connect(_on_customer_resolved)
	EventBus.beat_ui_resolved.connect(_on_beat_ui_resolved)
	EventBus.rent_decision_selected.connect(choose_rent_path)
	EventBus.showcase_choice_selected.connect(choose_showcase)
	EventBus.showcase_choice_resolved.connect(_on_showcase_choice_resolved)
	EventBus.beat_decision_selected.connect(choose_beat_path)


func reset() -> void:
	_started.clear()
	_completed.clear()
	_rent_price_path = &""
	_outing_opportunity_id = &""
	_shady_opportunity_id = &""


func trigger_qa_beat(beat_id: StringName) -> bool:
	if not QaInstrumentation.is_enabled():
		return false
	match beat_id:
		SPIKE_STAPLE_BEAT:
			return (
				GameState.current_phase == GameState.DayPhase.FLOOR
				and _start_spike_staple()
			)
		RENT_FIRESALE_BEAT:
			return (
				GameState.current_phase == GameState.DayPhase.PREP
				and _start_rent_firesale()
			)
		TITAN_HYPE_BEAT:
			return _start_titan_hype()
		SHOWCASE_BEAT:
			return (
				GameState.current_phase == GameState.DayPhase.PREP
				and _start_showcase_choice()
			)
		MARKETPLACE_OUTING_BEAT:
			return (
				GameState.current_phase == GameState.DayPhase.PREP
				and _start_marketplace_outing()
			)
		HIRE_CASHIER_BEAT:
			return (
				GameState.current_phase == GameState.DayPhase.PREP
				and _start_hire_cashier()
			)
		EXPAND_MEDIUM_BEAT:
			return (
				GameState.current_phase == GameState.DayPhase.PREP
				and _start_expand_medium()
			)
		SHADY_TRUNK_BEAT:
			return (
				GameState.current_phase == GameState.DayPhase.PREP
				and _start_shady_trunk()
			)
	return false


func is_started(beat_id: StringName) -> bool:
	return _started.has(beat_id)


func is_completed(beat_id: StringName) -> bool:
	return _completed.has(beat_id)


func choose_rent_path(choice: StringName) -> bool:
	if (
		not _is_rent_pending()
		or GameState.current_phase != GameState.DayPhase.PREP
	):
		return false
	match choice:
		&"fire_sale":
			var dust_sku := _dustway_target()
			if dust_sku.is_empty():
				return false
			_rent_price_path = choice
			EventBus.price_focus_requested.emit(
				dust_sku,
				RENT_FIRESALE_BEAT,
				"Rent due today — Dustway fire-sale",
				&"undercut"
			)
		&"cut_accessories":
			var accessory_sku := _accessory_target()
			if accessory_sku.is_empty():
				return false
			_rent_price_path = choice
			EventBus.price_focus_requested.emit(
				accessory_sku,
				RENT_FIRESALE_BEAT,
				"Rent due today — cut accessories",
				&"undercut"
			)
		&"payday_loan":
			if not Economy.take_payday_loan():
				return false
			_resolve_rent(choice)
		&"dismissed":
			_resolve_rent(choice)
		_:
			return false
	return true


func choose_showcase(choice: StringName) -> bool:
	if not _started.has(SHOWCASE_BEAT):
		return false
	var slab := InventoryService.get_slab(EMPRESS_SKU)
	var titan := InventoryService.get_card(TITAN_SKU)
	var paragon := InventoryService.get_card(PARAGON_SKU)
	if slab == null or titan == null or paragon == null:
		return false
	var case_location := InventoryLocation.new(InventoryLocation.Type.CASE)
	var binder_location := InventoryLocation.new(InventoryLocation.Type.BINDER)
	var hold_location := InventoryLocation.new(InventoryLocation.Type.ONLINE_HOLD)
	match choice:
		&"slab":
			var slab_space := InventoryService.case_free_slot_weight()
			if titan.location.type == InventoryLocation.Type.CASE:
				slab_space += InventoryModel.CASE_CARD_WEIGHT
			if paragon.location.type == InventoryLocation.Type.CASE:
				slab_space += InventoryModel.CASE_CARD_WEIGHT
			if slab_space < InventoryModel.CASE_SLAB_WEIGHT:
				EventBus.showcase_choice_failed.emit(
					"The case needs 2 free slot-weights for the slab."
				)
				return false
			if titan.location.type == InventoryLocation.Type.CASE:
				InventoryService.move_card_to(titan, binder_location)
			if paragon.location.type == InventoryLocation.Type.CASE:
				InventoryService.move_card_to(paragon, binder_location)
			if not InventoryService.move_slab_to(slab, case_location):
				return false
		&"singles":
			var singles_space := InventoryService.case_free_slot_weight()
			if slab.location.type == InventoryLocation.Type.CASE:
				singles_space += InventoryModel.CASE_SLAB_WEIGHT
			var singles_needed := 0
			if titan.location.type != InventoryLocation.Type.CASE:
				singles_needed += InventoryModel.CASE_CARD_WEIGHT
			if paragon.location.type != InventoryLocation.Type.CASE:
				singles_needed += InventoryModel.CASE_CARD_WEIGHT
			if singles_space < singles_needed:
				EventBus.showcase_choice_failed.emit(
					"The case needs 2 free slot-weights for both singles."
				)
				return false
			if slab.location.type == InventoryLocation.Type.CASE:
				InventoryService.move_slab_to(slab, hold_location)
			if (
				not InventoryService.move_card_to(titan, case_location)
				or not InventoryService.move_card_to(paragon, case_location)
			):
				return false
		_:
			return false
	EventBus.showcase_choice_resolved.emit(SHOWCASE_BEAT, choice)
	return true


func choose_beat_path(choice: StringName) -> bool:
	if GameState.current_phase != GameState.DayPhase.PREP:
		return false
	if _is_pending(MARKETPLACE_OUTING_BEAT):
		return _choose_marketplace_outing(choice)
	if _is_pending(HIRE_CASHIER_BEAT):
		return _choose_hire_cashier(choice)
	if _is_pending(EXPAND_MEDIUM_BEAT):
		return _choose_expand_medium(choice)
	if _is_pending(SHADY_TRUNK_BEAT):
		return _choose_shady_trunk(choice)
	return false


func _on_day_started(day: int) -> void:
	if not GameState.is_game_active:
		return
	call_deferred("_start_day_beats", day)


func _start_day_beats(day: int) -> void:
	if not GameState.is_game_active or day != GameState.current_day:
		return
	if (
		GameState.balance_config.is_rent_due_day(day)
		and day == GameState.balance_config.first_rent_due_day
		and not _started.has(RENT_FIRESALE_BEAT)
		and _start_rent_firesale()
	):
		return
	if not _is_normal_game():
		return
	if day == 3 and not _started.has(MARKETPLACE_OUTING_BEAT):
		_start_marketplace_outing()
		return
	if day == 5 and not _started.has(HIRE_CASHIER_BEAT):
		_start_hire_cashier()
		return
	if day >= 8 and day <= 10 and not _started.has(TITAN_HYPE_BEAT):
		_start_titan_hype()
		return
	if _is_titan_pending():
		_refocus_pending_titan()
		return
	if day >= 10 and day <= 12 and not _started.has(SHOWCASE_BEAT):
		_start_showcase_choice()
		return
	if day >= 18 and day <= 25 and not _started.has(EXPAND_MEDIUM_BEAT):
		_start_expand_medium()
		return
	if _start_shady_trunk_if_due(day):
		return


func _on_day_phase_changed(phase: int) -> void:
	if (
		_is_normal_game()
		and phase == GameState.DayPhase.FLOOR
		and GameState.current_day >= 3
		and GameState.current_day <= 5
		and not _started.has(SPIKE_STAPLE_BEAT)
	):
		_start_spike_staple()
	if not _is_titan_pending():
		return
	if phase == GameState.DayPhase.FLOOR:
		call_deferred(
			"_refocus_titan_after_phase_change",
			GameState.current_day
		)
	elif phase == GameState.DayPhase.SETTLE:
		_mark_completed(TITAN_HYPE_BEAT, &"ignored")


func _refocus_titan_after_phase_change(day: int) -> void:
	if (
		GameState.current_day == day
		and GameState.current_phase == GameState.DayPhase.FLOOR
	):
		_refocus_pending_titan()


func _start_spike_staple() -> bool:
	var sku_id := _choose_staple()
	if InventoryService.displayable_card_count(sku_id) == 0:
		var sku := InventoryService.model.get_sku(sku_id)
		if sku == null:
			return false
		if InventoryService.receive_card(
			sku_id,
			sku.base_market_cents,
			InventoryLocation.new(InventoryLocation.Type.BINDER),
			sku.base_market_cents
		) == null:
			return false
	var kept_displayable := false
	for card: CardInstance in InventoryService.get_cards(sku_id):
		if card.location.type not in [
			InventoryLocation.Type.CASE,
			InventoryLocation.Type.BINDER,
		]:
			continue
		if not kept_displayable:
			kept_displayable = true
			continue
		InventoryService.move_card_to(
			card,
			InventoryLocation.new(InventoryLocation.Type.ONLINE_HOLD)
		)
	var listed_price := InventoryService.listed_price_for(sku_id)
	var customer := CustomerProfile.new()
	customer.archetype_id = &"spike"
	customer.display_name = "Spike"
	customer.desired_skus = [sku_id]
	customer.budget_cents = maxi(listed_price, 1)
	customer.patience_seconds = 300.0
	customer.beat_id = SPIKE_STAPLE_BEAT
	_mark_started(SPIKE_STAPLE_BEAT)
	EventBus.scripted_customer_requested.emit(customer)
	return true


func _start_rent_firesale() -> bool:
	if (
		GameState.current_phase != GameState.DayPhase.PREP
		or _started.has(RENT_FIRESALE_BEAT)
	):
		return false
	var dust_sku := _dustway_target()
	var projected_cash := (
		Economy.balance_cents
		- GameState.balance_config.rent_small_weekly_cents
	)
	var has_buffer_pressure := (
		projected_cash < GameState.balance_config.rent_small_weekly_cents
	)
	var has_soft_shelf := (
		not dust_sku.is_empty()
		and DemandSignals.apply_soft_shelf_signal(
			dust_sku,
			GameState.current_day
		)
	)
	if not has_soft_shelf and not has_buffer_pressure:
		return false
	var accessory_sku := _accessory_target()
	_mark_started(RENT_FIRESALE_BEAT)
	EventBus.rent_decision_requested.emit({
		"beat_id": RENT_FIRESALE_BEAT,
		"title": "Rent due today — shelf is soft",
		"rent_cents": GameState.balance_config.rent_small_weekly_cents,
		"projected_cash_cents": projected_cash,
		"fire_sale_enabled": not dust_sku.is_empty(),
		"accessory_enabled": not accessory_sku.is_empty(),
		"loan_enabled": (
			GameState.balance_config.loan_shark_enabled
			and not Economy.has_active_payday_loan()
		),
		"loan_cash_cents": GameState.balance_config.loan_shark_cash_cents,
		"loan_daily_cents": GameState.balance_config.loan_shark_daily_cents,
		"loan_days": GameState.balance_config.loan_shark_days,
		"loan_rep_hit": GameState.balance_config.loan_shark_rep_hit,
	})
	return true


func _start_titan_hype() -> bool:
	var sku := InventoryService.model.get_sku(TITAN_SKU)
	if sku == null:
		return false
	if InventoryService.get_card(TITAN_SKU) == null:
		if InventoryService.receive_card(
			TITAN_SKU,
			sku.base_market_cents,
			InventoryLocation.new(InventoryLocation.Type.BINDER),
			sku.base_market_cents
		) == null:
			return false
	if not DemandSignals.apply_hype_event(
		TITAN_SKU,
		GameState.current_day + 1
	):
		return false
	_mark_started(TITAN_HYPE_BEAT)
	EventBus.price_focus_requested.emit(
		TITAN_SKU,
		TITAN_HYPE_BEAT,
		"Hype: Skiefall Titan",
		&"suggested"
	)
	return true


func _refocus_pending_titan() -> void:
	if not _is_titan_pending():
		return
	EventBus.price_focus_requested.emit(
		TITAN_SKU,
		TITAN_HYPE_BEAT,
		"Hype: Skiefall Titan",
		&"suggested"
	)


func _start_showcase_choice() -> bool:
	if not _ensure_showcase_inventory():
		return false
	if InventoryService.case_free_slot_weight() < 2:
		return false
	var empress := InventoryService.model.get_sku(EMPRESS_SKU)
	var titan := InventoryService.model.get_sku(TITAN_SKU)
	var paragon := InventoryService.model.get_sku(PARAGON_SKU)
	_mark_started(SHOWCASE_BEAT)
	EventBus.showcase_choice_requested.emit({
		"beat_id": SHOWCASE_BEAT,
		"title": "Showcase tight — pick display",
		"slab_label": "%s · Prism 10" % empress.display_name,
		"singles_label": "%s + %s" % [
			titan.display_name,
			paragon.display_name,
		],
		"free_slot_weight": InventoryService.case_free_slot_weight(),
	})
	return true


func _start_marketplace_outing() -> bool:
	if (
		GameState.current_phase != GameState.DayPhase.PREP
		or _started.has(MARKETPLACE_OUTING_BEAT)
	):
		return false
	var opportunity := _ensure_marketplace_steal()
	if opportunity == null:
		return false
	var dto := DemandSignals.buy_signal_for_id(opportunity.id)
	if dto == null or dto.confidence != &"low":
		return false
	_outing_opportunity_id = opportunity.id
	var config := GameState.balance_config
	_mark_started(MARKETPLACE_OUTING_BEAT)
	EventBus.beat_decision_requested.emit({
		"beat_id": MARKETPLACE_OUTING_BEAT,
		"title": "Off-site lot — leave the floor?",
		"summary": (
			"%s looks cheap versus noisy comps, Low confidence, Photo only."
			% opportunity.display_name
		),
		"choices": [
			{
				"id": &"drive_out",
				"label": (
					"Drive out\nAttention %d · miss 1–2 FLOOR hours"
					% config.marketplace_outing_attention
				),
				"enabled": (
					GameState.attention_remaining
					>= config.marketplace_outing_attention
				),
			},
			{
				"id": &"courier",
				"label": (
					"Courier fee\nPay %s · keep the FLOOR"
					% DemandSignalPresenter.format_cents(
						config.marketplace_courier_fee_cents
					)
				),
				"enabled": Economy.can_afford(
					config.marketplace_courier_fee_cents
				),
			},
			{
				"id": &"skip",
				"label": "Skip\nPass on the lot",
				"enabled": true,
			},
		],
	})
	return true


func _start_hire_cashier() -> bool:
	if (
		GameState.current_phase != GameState.DayPhase.PREP
		or _started.has(HIRE_CASHIER_BEAT)
		or not GameState.shop.is_owner_only()
		or not GameState.shop.can_hire()
	):
		return false
	_mark_started(HIRE_CASHIER_BEAT)
	EventBus.beat_decision_requested.emit({
		"beat_id": HIRE_CASHIER_BEAT,
		"title": "Counter’s getting slammed — hire help?",
		"summary": (
			"Staff cap %d (Small). Owner only right now. Wages hit at SETTLE."
			% GameState.shop.staff_cap()
		),
		"choices": [
			{
				"id": &"hire_cashier",
				"label": (
					"Hire Cashier\n%s/day · Reliability ~%.2f"
					% [
						DemandSignalPresenter.format_cents(
							ShopState.CASHIER_WAGE_CENTS
						),
						ShopState.CASHIER_RELIABILITY,
					]
				),
				"enabled": true,
			},
			{
				"id": &"keep_solo",
				"label": "Keep solo\nNo wage, no extra hands",
				"enabled": true,
			},
			{
				"id": &"hire_cheap",
				"label": (
					"Hire cheap\n%s/day · Reliability ≤%.2f"
					% [
						DemandSignalPresenter.format_cents(
							ShopState.CHEAP_CASHIER_WAGE_CENTS
						),
						ShopState.CHEAP_CASHIER_RELIABILITY,
					]
				),
				"enabled": true,
			},
		],
		"confirms": {
			"hire_cheap": {
				"title": "Hire the cheap cashier?",
				"body": (
					"Reliability %.2f — theft/no-show bias. Wage still posts at SETTLE."
					% ShopState.CHEAP_CASHIER_RELIABILITY
				),
			},
		},
	})
	return true


func _start_expand_medium() -> bool:
	if (
		GameState.current_phase != GameState.DayPhase.PREP
		or _started.has(EXPAND_MEDIUM_BEAT)
		or GameState.shop.tier != ShopState.Tier.SMALL
	):
		return false
	var config := GameState.balance_config
	var can_sign := GameState.shop.can_expand_medium(
		Economy.balance_cents,
		GameState.current_reputation
	)
	var gate_lines: PackedStringArray = []
	if not GameState.shop.cash_meets_medium(Economy.balance_cents):
		gate_lines.append(
			"Need %s cash (have %s)." % [
				DemandSignalPresenter.format_cents(config.expand_medium_cash_cents),
				DemandSignalPresenter.format_cents(Economy.balance_cents),
			]
		)
	if not GameState.shop.rep_meets_medium(GameState.current_reputation):
		gate_lines.append(
			"Need Rep %d (have %d)." % [
				config.expand_medium_rep,
				GameState.current_reputation,
			]
		)
	var summary := "Landlord offered a Medium unit."
	if not gate_lines.is_empty():
		summary += " Missing gate: " + " ".join(gate_lines)
	_mark_started(EXPAND_MEDIUM_BEAT)
	EventBus.beat_decision_requested.emit({
		"beat_id": EXPAND_MEDIUM_BEAT,
		"title": "Landlord offered Medium unit — sign?",
		"summary": summary,
		"choices": [
			{
				"id": &"sign_lease",
				"label": "Sign lease\nMedium rent next week · grid/staff upgrade",
				"enabled": can_sign,
			},
			{
				"id": &"wait_for_rep",
				"label": "Wait for Rep\nStay Small until reputation catches up",
				"enabled": not GameState.shop.rep_meets_medium(
					GameState.current_reputation
				),
			},
			{
				"id": &"stay_small",
				"label": "Stay Small\nKeep current rent and staff cap",
				"enabled": true,
			},
		],
		"confirms": {
			"sign_lease": {
				"title": "Confirm Medium lease?",
				"body": (
					"Rent %s → %s next week. Staff cap %d → %d. Grid %dx%d → %dx%d."
					% [
						DemandSignalPresenter.format_cents(
							config.rent_small_weekly_cents
						),
						DemandSignalPresenter.format_cents(
							config.rent_medium_weekly_cents
						),
						config.staff_cap_small,
						config.staff_cap_medium,
						ShopState.SMALL_GRID_WIDTH,
						ShopState.SMALL_GRID_HEIGHT,
						ShopState.MEDIUM_GRID_WIDTH,
						ShopState.MEDIUM_GRID_HEIGHT,
					]
				),
			},
		},
	})
	return true


func _start_shady_trunk_if_due(day: int) -> bool:
	if (
		day < 20
		or day > 30
		or _started.has(SHADY_TRUNK_BEAT)
		or _is_pending(EXPAND_MEDIUM_BEAT)
	):
		return false
	return _start_shady_trunk()


func _start_shady_trunk() -> bool:
	if (
		GameState.current_phase != GameState.DayPhase.PREP
		or _started.has(SHADY_TRUNK_BEAT)
	):
		return false
	var opportunity := _ensure_shady_trunk_lot()
	if opportunity == null:
		return false
	var dto := DemandSignals.buy_signal_for_id(opportunity.id)
	if dto == null or dto.confidence != &"low":
		return false
	_shady_opportunity_id = opportunity.id
	_mark_started(SHADY_TRUNK_BEAT)
	EventBus.beat_decision_requested.emit({
		"beat_id": SHADY_TRUNK_BEAT,
		"title": "Trunk sale — too good?",
		"summary": (
			"Deep-discount shady lot. Low confidence. %s"
			% dto.condition_cue
		),
		"choices": [
			{
				"id": &"buy",
				"label": "Buy\nInspect the trunk lot",
				"enabled": true,
			},
			{
				"id": &"report",
				"label": (
					"Report\n+%d Rep · lot gone"
					% GameState.balance_config.shady_report_rep_gain
				),
				"enabled": true,
			},
			{
				"id": &"ignore",
				"label": "Ignore\nWalk away",
				"enabled": true,
			},
		],
	})
	return true


func _choose_marketplace_outing(choice: StringName) -> bool:
	var opportunity_id := _outing_opportunity_id
	if opportunity_id.is_empty():
		return false
	var config := GameState.balance_config
	match choice:
		&"drive_out":
			if not GameState.consume_attention(config.marketplace_outing_attention):
				return false
			GameState.queue_floor_skip(config.marketplace_outing_floor_skip_seconds)
			_focus_buy_opportunity(
				opportunity_id,
				MARKETPLACE_OUTING_BEAT,
				"Off-site lot — you left the floor"
			)
		&"courier":
			if not Economy.record_expense(
				config.marketplace_courier_fee_cents,
				&"courier",
				"Marketplace courier fee"
			):
				return false
			_focus_buy_opportunity(
				opportunity_id,
				MARKETPLACE_OUTING_BEAT,
				"Courier brought the lot — FLOOR stays open"
			)
		&"skip":
			DemandSignals.dismiss_buy_opportunity(opportunity_id)
		_:
			return false
	_resolve_decision(MARKETPLACE_OUTING_BEAT, choice)
	return true


func _choose_hire_cashier(choice: StringName) -> bool:
	match choice:
		&"hire_cashier":
			if GameState.shop.hire_cashier(false) == null:
				return false
		&"hire_cheap":
			if GameState.shop.hire_cashier(true) == null:
				return false
		&"keep_solo":
			pass
		_:
			return false
	_resolve_decision(HIRE_CASHIER_BEAT, choice)
	return true


func _choose_expand_medium(choice: StringName) -> bool:
	match choice:
		&"sign_lease":
			if not GameState.shop.expand_to_medium(
				GameState.current_day,
				Economy.balance_cents,
				GameState.current_reputation
			):
				return false
			InventoryService.apply_medium_capacity(
				ShopState.MEDIUM_CASE_SLOT_BONUS,
				ShopState.MEDIUM_BACKSTOCK_BONUS
			)
		&"wait_for_rep":
			if GameState.shop.rep_meets_medium(GameState.current_reputation):
				return false
		&"stay_small":
			pass
		_:
			return false
	_resolve_decision(EXPAND_MEDIUM_BEAT, choice)
	return true


func _choose_shady_trunk(choice: StringName) -> bool:
	var opportunity_id := _shady_opportunity_id
	if opportunity_id.is_empty():
		return false
	match choice:
		&"buy":
			_focus_buy_opportunity(
				opportunity_id,
				SHADY_TRUNK_BEAT,
				"Trunk lot — Low confidence, inspect recommended"
			)
		&"report":
			GameState.adjust_reputation(
				GameState.balance_config.shady_report_rep_gain
			)
			DemandSignals.dismiss_buy_opportunity(opportunity_id)
		&"ignore":
			DemandSignals.dismiss_buy_opportunity(opportunity_id)
		_:
			return false
	_resolve_decision(SHADY_TRUNK_BEAT, choice)
	return true


func _ensure_showcase_inventory() -> bool:
	var empress := InventoryService.model.get_sku(EMPRESS_SKU)
	var titan := InventoryService.model.get_sku(TITAN_SKU)
	var paragon := InventoryService.model.get_sku(PARAGON_SKU)
	if empress == null or titan == null or paragon == null:
		return false
	if InventoryService.get_slab(EMPRESS_SKU) == null:
		if InventoryService.receive_slab(
			EMPRESS_SKU,
			&"Prism",
			10.0,
			empress.base_market_cents,
			InventoryLocation.new(InventoryLocation.Type.ONLINE_HOLD)
		) == null:
			return false
	for sku: ProductSKU in [titan, paragon]:
		if InventoryService.get_card(sku.id) == null:
			if InventoryService.receive_card(
				sku.id,
				sku.base_market_cents,
				InventoryLocation.new(InventoryLocation.Type.BINDER),
				sku.base_market_cents
			) == null:
				return false
	return true


func _ensure_marketplace_steal() -> BuyOpportunity:
	for dto: BuyConfirmSignal in DemandSignals.open_buy_signals():
		if dto.channel != &"marketplace" or dto.confidence != &"low":
			continue
		if not dto.condition_cue.to_lower().contains("photo"):
			continue
		var midpoint := (dto.shown_comp_low_cents + dto.shown_comp_high_cents) / 2
		if dto.unit_cost_cents < midpoint:
			return _opportunity_from_open_id(dto.opportunity_id)
	var sku := InventoryService.model.get_sku(SKIE_ETB_SKU)
	if sku == null:
		return null
	var steal := _make_scripted_opportunity(
		&"marketplace-outing-steal",
		SKIE_ETB_SKU,
		DemandSignalService.Channel.MARKETPLACE,
		maxi(1, roundi(float(sku.base_market_cents) * 0.56)),
		2,
		"Off-site lot",
		MARKETPLACE_OUTING_BEAT
	)
	if not DemandSignals.inject_buy_opportunity(steal):
		return _opportunity_from_open_id(steal.id)
	return steal


func _ensure_shady_trunk_lot() -> BuyOpportunity:
	for dto: BuyConfirmSignal in DemandSignals.open_buy_signals():
		if dto.channel == &"shady" and dto.confidence == &"low":
			return _opportunity_from_open_id(dto.opportunity_id)
	var sku := InventoryService.model.get_sku(SKIE_ETB_SKU)
	if sku == null:
		return null
	var lot := _make_scripted_opportunity(
		&"shady-trunk-lot",
		SKIE_ETB_SKU,
		DemandSignalService.Channel.SHADY,
		maxi(1, roundi(float(sku.base_market_cents) * 0.32)),
		1,
		"Trunk sale",
		SHADY_TRUNK_BEAT
	)
	if not DemandSignals.inject_buy_opportunity(lot):
		return _opportunity_from_open_id(lot.id)
	return lot


func _make_scripted_opportunity(
	opportunity_id: StringName,
	sku_id: StringName,
	channel: DemandSignalService.Channel,
	unit_cost_cents: int,
	quantity: int,
	offer_label: String,
	beat_id: StringName
) -> BuyOpportunity:
	var sku := InventoryService.model.get_sku(sku_id)
	var opportunity := BuyOpportunity.new()
	opportunity.id = opportunity_id
	opportunity.sku_id = sku_id
	opportunity.display_name = sku.display_name if sku != null else String(sku_id)
	opportunity.offer_label = offer_label
	opportunity.channel = channel
	opportunity.unit_cost_cents = unit_cost_cents
	opportunity.quantity = quantity
	opportunity.space_required = 1
	opportunity.beat_id = beat_id
	return opportunity


func _opportunity_from_open_id(opportunity_id: StringName) -> BuyOpportunity:
	var dto := DemandSignals.buy_signal_for_id(opportunity_id)
	if dto == null:
		return null
	var opportunity := BuyOpportunity.new()
	opportunity.id = dto.opportunity_id
	opportunity.sku_id = dto.sku_id
	opportunity.display_name = dto.display_name
	opportunity.offer_label = dto.offer_label
	opportunity.channel = DemandSignalService.Channel.MARKETPLACE
	if dto.channel == &"shady":
		opportunity.channel = DemandSignalService.Channel.SHADY
	opportunity.unit_cost_cents = dto.unit_cost_cents
	opportunity.quantity = dto.quantity
	opportunity.space_required = dto.space_required
	opportunity.beat_id = dto.beat_id
	return opportunity


func _focus_buy_opportunity(
	opportunity_id: StringName,
	beat_id: StringName,
	message: String
) -> void:
	EventBus.buy_focus_requested.emit(opportunity_id, beat_id, message)


func _choose_staple() -> StringName:
	for sku_id: StringName in [BASTION_SKU, ARCBOLT_SKU]:
		if InventoryService.displayable_card_count(sku_id) == 1:
			return sku_id
	for sku_id: StringName in [BASTION_SKU, ARCBOLT_SKU]:
		if InventoryService.displayable_card_count(sku_id) > 0:
			return sku_id
	return BASTION_SKU


func _dustway_target() -> StringName:
	for sku_id: StringName in [DUST_ETB_SKU, DUST_BLASTER_SKU]:
		if InventoryService.has_stock(sku_id):
			return sku_id
	return &""


func _accessory_target() -> StringName:
	for lot: StockLot in InventoryService.get_all_stock():
		if lot.qty > 0 and String(lot.sku.id).begins_with("ACC-"):
			return lot.sku.id
	return &""


func _on_customer_resolved(
	customer: CustomerProfile,
	outcome: StringName
) -> void:
	if customer != null and customer.beat_id == SPIKE_STAPLE_BEAT:
		_mark_completed(SPIKE_STAPLE_BEAT, outcome)


func _on_beat_ui_resolved(
	beat_id: StringName,
	outcome: StringName
) -> void:
	if beat_id == RENT_FIRESALE_BEAT and _is_rent_pending():
		_resolve_rent(
			StringName("%s_%s" % [_rent_price_path, outcome])
		)
		return
	if beat_id == TITAN_HYPE_BEAT and _is_titan_pending():
		_mark_completed(beat_id, outcome)
		if (
			GameState.current_phase == GameState.DayPhase.PREP
			and GameState.current_day >= 10
			and GameState.current_day <= 12
			and not _started.has(SHOWCASE_BEAT)
		):
			call_deferred("_start_showcase_choice")


func _on_showcase_choice_resolved(
	beat_id: StringName,
	choice: StringName
) -> void:
	if beat_id == SHOWCASE_BEAT:
		_mark_completed(beat_id, choice)


func _mark_started(beat_id: StringName) -> void:
	_started[beat_id] = GameState.current_day
	QaInstrumentation.record_beat_started(beat_id, GameState.current_day)


func _mark_completed(beat_id: StringName, outcome: StringName) -> void:
	if _completed.has(beat_id):
		return
	_completed[beat_id] = outcome
	QaInstrumentation.record_beat_completed(
		beat_id,
		GameState.current_day,
		outcome
	)


func _resolve_rent(outcome: StringName) -> void:
	_mark_completed(RENT_FIRESALE_BEAT, outcome)
	_rent_price_path = &""
	EventBus.rent_decision_resolved.emit(RENT_FIRESALE_BEAT, outcome)


func _resolve_decision(beat_id: StringName, outcome: StringName) -> void:
	_mark_completed(beat_id, outcome)
	EventBus.beat_decision_resolved.emit(beat_id, outcome)
	if beat_id == EXPAND_MEDIUM_BEAT:
		call_deferred("_start_shady_trunk_if_due", GameState.current_day)


func _is_rent_pending() -> bool:
	return _is_pending(RENT_FIRESALE_BEAT)


func _is_titan_pending() -> bool:
	return _is_pending(TITAN_HYPE_BEAT)


func _is_pending(beat_id: StringName) -> bool:
	return _started.has(beat_id) and not _completed.has(beat_id)


func _is_normal_game() -> bool:
	return (
		GameState.is_game_active
		and GameState.balance_config.difficulty == BalanceConfig.Difficulty.NORMAL
	)
