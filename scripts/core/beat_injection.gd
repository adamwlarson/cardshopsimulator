class_name BeatInjectionService
extends Node

const SPIKE_STAPLE_BEAT := &"sec10_4_spike_staple"
const RENT_FIRESALE_BEAT := &"sec10_6_rent_firesale"
const TITAN_HYPE_BEAT := &"sec10_7_titan_hype"
const SHOWCASE_BEAT := &"sec10_8_slab_vs_singles"

const BASTION_SKU := &"AA-BASE-088"
const ARCBOLT_SKU := &"AA-BASE-078"
const DUST_ETB_SKU := &"AA-DUST-ETB"
const DUST_BLASTER_SKU := &"AA-DUST-BLST"
const TITAN_SKU := &"AA-SKIE-047"
const EMPRESS_SKU := &"AA-SKIE-052"
const PARAGON_SKU := &"AA-SKIE-058"

var _started: Dictionary = {}
var _completed: Dictionary = {}
var _rent_price_path: StringName = &""


func _ready() -> void:
	EventBus.day_started.connect(_on_day_started)
	EventBus.day_phase_changed.connect(_on_day_phase_changed)
	EventBus.customer_resolved.connect(_on_customer_resolved)
	EventBus.beat_ui_resolved.connect(_on_beat_ui_resolved)
	EventBus.rent_decision_selected.connect(choose_rent_path)
	EventBus.showcase_choice_selected.connect(choose_showcase)
	EventBus.showcase_choice_resolved.connect(_on_showcase_choice_resolved)


func reset() -> void:
	_started.clear()
	_completed.clear()
	_rent_price_path = &""


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
	if day >= 8 and day <= 10 and not _started.has(TITAN_HYPE_BEAT):
		_start_titan_hype()
		return
	if _is_titan_pending():
		_refocus_pending_titan()
		return
	if day >= 10 and day <= 12 and not _started.has(SHOWCASE_BEAT):
		_start_showcase_choice()


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


func _is_rent_pending() -> bool:
	return (
		_started.has(RENT_FIRESALE_BEAT)
		and not _completed.has(RENT_FIRESALE_BEAT)
	)


func _is_titan_pending() -> bool:
	return (
		_started.has(TITAN_HYPE_BEAT)
		and not _completed.has(TITAN_HYPE_BEAT)
	)


func _is_normal_game() -> bool:
	return (
		GameState.is_game_active
		and GameState.balance_config.difficulty == BalanceConfig.Difficulty.NORMAL
	)
