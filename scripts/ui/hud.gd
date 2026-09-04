extends Control

@onready var cash_label: Label = %CashLabel
@onready var day_label: Label = %DayLabel
@onready var phase_chip: PanelContainer = %PhaseChip
@onready var phase_label: Label = %PhaseLabel
@onready var attention_label: Label = %AttentionLabel
@onready var queue_label: Label = %QueueLabel
@onready var phase_button: Button = %PhaseButton
@onready var buy_list_panel: PanelContainer = %BuyOpportunityList
@onready var buy_rows: VBoxContainer = %BuyOpportunityRows
@onready var buy_empty_label: Label = %BuyOpportunityEmpty
@onready var buy_panel: PanelContainer = %BuyOpportunityDetail
@onready var buy_title: Label = %BuyOpportunityTitle
@onready var buy_summary: Label = %BuySummary
@onready var inspect_button: Button = %InspectButton
@onready var buy_button: Button = %BuyButton
@onready var buy_confirm_panel: PanelContainer = %BuyConfirm
@onready var buy_confirm_summary: Label = %BuyConfirmSummary
@onready var price_list_panel: PanelContainer = %PriceInventoryList
@onready var price_rows: VBoxContainer = %PriceInventoryRows
@onready var price_empty_label: Label = %PriceInventoryEmpty
@onready var price_panel: PanelContainer = %PriceEditor
@onready var price_title: Label = %PriceTitle
@onready var price_input: LineEdit = %PriceInput
@onready var price_summary: Label = %PriceSummary
@onready var price_position_chip: Label = %PricePositionChip
@onready var price_demand_chip: Label = %PriceDemandChip
@onready var price_move_chip: Label = %PriceMoveChip
@onready var serve_panel: PanelContainer = %CustomerServe
@onready var customer_title: Label = %CustomerTitle
@onready var customer_summary: Label = %CustomerSummary
@onready var patience_bar: ProgressBar = %PatienceBar
@onready var beat_toast: Label = %BeatToast
@onready var rent_panel: PanelContainer = %RentDecision
@onready var rent_title: Label = %RentTitle
@onready var rent_summary: Label = %RentSummary
@onready var rent_fire_sale_button: Button = %RentFireSaleButton
@onready var rent_accessories_button: Button = %RentAccessoriesButton
@onready var rent_loan_button: Button = %RentLoanButton
@onready var rent_dismiss_button: Button = %RentDismissButton
@onready var rent_loan_confirm: VBoxContainer = %RentLoanConfirm
@onready var rent_loan_terms: Label = %RentLoanTerms
@onready var showcase_panel: PanelContainer = %ShowcaseChoice
@onready var showcase_title: Label = %ShowcaseTitle
@onready var showcase_summary: Label = %ShowcaseSummary
@onready var showcase_slab_button: Button = %ShowcaseSlabButton
@onready var showcase_singles_button: Button = %ShowcaseSinglesButton
@onready var beat_decision_panel: PanelContainer = %BeatDecision
@onready var beat_decision_title: Label = %BeatDecisionTitle
@onready var beat_decision_summary: Label = %BeatDecisionSummary
@onready var beat_choice_a_button: Button = %BeatChoiceAButton
@onready var beat_choice_b_button: Button = %BeatChoiceBButton
@onready var beat_choice_c_button: Button = %BeatChoiceCButton
@onready var beat_choice_d_button: Button = %BeatChoiceDButton
@onready var open_staff_button: Button = %OpenStaffButton
@onready var staff_panel: PanelContainer = %StaffPanel
@onready var staff_hint: Label = %StaffHint
@onready var staff_rows: VBoxContainer = %StaffRows
@onready var hire_cashier_button: Button = %HireCashierButton
@onready var hire_specialist_button: Button = %HireSpecialistButton
@onready var beat_confirm: VBoxContainer = %BeatConfirm
@onready var beat_confirm_title: Label = %BeatConfirmTitle
@onready var beat_confirm_body: Label = %BeatConfirmBody
@onready var open_research_button: Button = %OpenResearchButton
@onready var open_rearrange_button: Button = %OpenRearrangeButton
@onready var rotation_watch_label: Label = %RotationWatchLabel
@onready var research_list_panel: PanelContainer = %ResearchList
@onready var research_rows: VBoxContainer = %ResearchRows
@onready var research_hint: Label = %ResearchHint
@onready var research_confirm_panel: PanelContainer = %ResearchConfirm
@onready var research_confirm_title: Label = %ResearchConfirmTitle
@onready var research_confirm_body: Label = %ResearchConfirmBody
@onready var research_confirm_button: Button = %ResearchConfirmButton
@onready var rearrange_panel: PanelContainer = %RearrangePanel
@onready var rearrange_hint: Label = %RearrangeHint
@onready var rearrange_fixture_rows: VBoxContainer = %RearrangeFixtureRows
@onready var rearrange_grid: GridContainer = %RearrangeGrid
@onready var rearrange_status: Label = %RearrangeStatus
@onready var rearrange_confirm_button: Button = %RearrangeConfirmButton

var _buy_signal: BuyConfirmSignal
var _price_signal: PriceConfirmSignal
var _current_customer: CustomerProfile
var _desk_customer_ready: bool = false
var _serve_dismissed: bool = false
var _active_price_beat_id: StringName = &""
var _rent_beat_id: StringName = &""
var _showcase_beat_id: StringName = &""
var _showcase_choice_made: bool = false
var _beat_decision_id: StringName = &""
var _beat_confirms: Dictionary = {}
var _pending_confirm_choice: StringName = &""
var _queue_length: int = 0
var _pending_research_set: StringName = &""
var _selected_rearrange_fixture: StringName = &""
var _selected_rearrange_origin := Vector2i(-1, -1)


func _ready() -> void:
	EventBus.cash_changed.connect(_update_cash)
	EventBus.day_started.connect(_update_day)
	EventBus.day_phase_changed.connect(_update_phase)
	EventBus.attention_changed.connect(_update_attention)
	EventBus.customer_queue_changed.connect(_update_queue)
	EventBus.customer_head_changed.connect(_on_customer_head_changed)
	EventBus.customer_desk_ready_changed.connect(_on_customer_desk_ready)
	EventBus.price_focus_requested.connect(_on_price_focus_requested)
	EventBus.rent_decision_requested.connect(_on_rent_decision_requested)
	EventBus.rent_decision_resolved.connect(_on_rent_decision_resolved)
	EventBus.showcase_choice_requested.connect(_on_showcase_choice_requested)
	EventBus.showcase_choice_resolved.connect(_on_showcase_choice_resolved)
	EventBus.showcase_choice_failed.connect(_on_showcase_choice_failed)
	EventBus.beat_decision_requested.connect(_on_beat_decision_requested)
	EventBus.beat_decision_resolved.connect(_on_beat_decision_resolved)
	EventBus.buy_focus_requested.connect(_on_buy_focus_requested)
	EventBus.staff_changed.connect(_on_staff_changed)
	phase_button.pressed.connect(_on_phase_pressed)
	%OpenBuyButton.pressed.connect(_open_buy_list)
	%BuyListCancelButton.pressed.connect(_close_buy)
	%BuyCancelButton.pressed.connect(_close_buy)
	inspect_button.pressed.connect(_inspect_buy)
	buy_button.pressed.connect(_open_buy_confirm)
	%BuyBackButton.pressed.connect(_back_to_buy_detail)
	%BuyConfirmButton.pressed.connect(_confirm_buy)
	%OpenPriceButton.pressed.connect(_open_price_list)
	%PriceListCancelButton.pressed.connect(_close_price)
	%PriceCancelButton.pressed.connect(_cancel_price)
	%PriceApplyButton.pressed.connect(_apply_price)
	price_input.text_changed.connect(_update_price_preview)
	%SellButton.pressed.connect(_sell_customer)
	%NegotiateButton.pressed.connect(_negotiate_customer)
	%RefuseButton.pressed.connect(_refuse_customer)
	rent_fire_sale_button.pressed.connect(_select_rent_path.bind(&"fire_sale"))
	rent_accessories_button.pressed.connect(
		_select_rent_path.bind(&"cut_accessories")
	)
	rent_loan_button.pressed.connect(_open_rent_loan_confirm)
	rent_dismiss_button.pressed.connect(_select_rent_path.bind(&"dismissed"))
	%RentLoanBackButton.pressed.connect(_close_rent_loan_confirm)
	%RentLoanConfirmButton.pressed.connect(
		_select_rent_path.bind(&"payday_loan")
	)
	showcase_slab_button.pressed.connect(_select_showcase_choice.bind(&"slab"))
	showcase_singles_button.pressed.connect(_select_showcase_choice.bind(&"singles"))
	beat_choice_a_button.pressed.connect(_select_beat_choice.bind(beat_choice_a_button))
	beat_choice_b_button.pressed.connect(_select_beat_choice.bind(beat_choice_b_button))
	beat_choice_c_button.pressed.connect(_select_beat_choice.bind(beat_choice_c_button))
	if beat_choice_d_button != null:
		beat_choice_d_button.pressed.connect(
			_select_beat_choice.bind(beat_choice_d_button)
		)
	if open_staff_button != null:
		open_staff_button.pressed.connect(_open_staff)
	var staff_cancel := get_node_or_null("%StaffListCancelButton") as Button
	if staff_cancel != null:
		staff_cancel.pressed.connect(_close_staff)
	if hire_cashier_button != null:
		hire_cashier_button.pressed.connect(_hire_from_panel.bind(&"cashier"))
	if hire_specialist_button != null:
		hire_specialist_button.pressed.connect(_hire_from_panel.bind(&"specialist"))
	%BeatConfirmBackButton.pressed.connect(_close_beat_confirm)
	%BeatConfirmButton.pressed.connect(_confirm_beat_choice)
	open_research_button.pressed.connect(_open_research_list)
	%ResearchListCancelButton.pressed.connect(_close_research)
	%ResearchConfirmBackButton.pressed.connect(_back_to_research_list)
	research_confirm_button.pressed.connect(_confirm_research)
	open_rearrange_button.pressed.connect(_open_rearrange)
	%RearrangeCancelButton.pressed.connect(_close_rearrange)
	rearrange_confirm_button.pressed.connect(_confirm_rearrange)
	set_process(false)
	_bind_seeded_status()
	_update_queue(0)


func _bind_seeded_status() -> void:
	if not GameState.is_game_active:
		GameState.start_new_game()
	_update_cash(Economy.balance_cents)
	_update_day(GameState.current_day)
	_update_phase(GameState.current_phase)
	_update_attention(GameState.attention_remaining)
	_sync_rotation_watch()


func _update_cash(balance_cents: int) -> void:
	cash_label.text = DemandSignalPresenter.format_cents(balance_cents)
	_sync_prep_action_buttons()


func _update_day(day: int) -> void:
	day_label.text = "Day %d" % day
	_sync_rotation_watch()


func _update_phase(phase: int) -> void:
	var phase_name: String = String(GameState.DayPhase.keys()[phase])
	phase_label.text = phase_name
	match phase:
		GameState.DayPhase.PREP:
			phase_chip.theme_type_variation = &"PhaseChipPrep"
			phase_label.theme_type_variation = &"ChipLabel"
			phase_button.text = "Open floor"
		GameState.DayPhase.FLOOR:
			phase_chip.theme_type_variation = &"PhaseChipFloor"
			phase_label.theme_type_variation = &"ChipLabelInverse"
			phase_button.text = "Close & settle"
		GameState.DayPhase.SETTLE:
			phase_chip.theme_type_variation = &"PhaseChipSettle"
			phase_label.theme_type_variation = &"ChipLabel"
			phase_button.text = "Next day"
	_close_buy()
	_close_price()
	_close_research()
	_close_rearrange()
	_close_staff()
	if phase == GameState.DayPhase.SETTLE and _showcase_choice_made:
		showcase_panel.hide()
	_sync_prep_action_buttons()
	_sync_modal_veil()


func _update_attention(remaining: int) -> void:
	attention_label.text = "Att %d/%d" % [
		remaining,
		GameState.balance_config.attention_pool,
	]
	_sync_inspect_button()
	_sync_prep_action_buttons()


func _update_queue(length: int) -> void:
	_queue_length = length
	queue_label.text = "Queue %d" % length
	_sync_prep_action_buttons()


func _on_phase_pressed() -> void:
	match GameState.current_phase:
		GameState.DayPhase.PREP:
			GameState.start_floor()
		GameState.DayPhase.FLOOR:
			GameState.start_settle()
		GameState.DayPhase.SETTLE:
			GameState.advance_day()


func _open_buy_list() -> void:
	_close_buy()
	for child: Node in buy_rows.get_children():
		buy_rows.remove_child(child)
		child.queue_free()
	var signals := DemandSignals.open_buy_signals()
	buy_empty_label.visible = signals.is_empty()
	for dto: BuyConfirmSignal in signals:
		var row := Button.new()
		row.text = DemandSignalPresenter.opportunity_row(dto)
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.custom_minimum_size = Vector2(0.0, 64.0)
		row.theme_type_variation = &"ListRowButton"
		row.pressed.connect(_select_buy_opportunity.bind(dto))
		buy_rows.add_child(row)
	buy_list_panel.show()
	_sync_modal_veil()


func _select_buy_opportunity(dto: BuyConfirmSignal) -> void:
	_buy_signal = dto
	buy_title.text = "BUY · %s · %s\n%s ×%d" % [
		String(_buy_signal.channel).capitalize(),
		_buy_signal.offer_label,
		_buy_signal.display_name,
		_buy_signal.quantity,
	]
	buy_summary.text = DemandSignalPresenter.buy_summary(_buy_signal)
	buy_button.disabled = not _buy_signal.can_confirm
	_sync_inspect_button()
	buy_list_panel.hide()
	buy_panel.show()
	buy_confirm_panel.hide()
	_sync_modal_veil()


func _open_buy_confirm() -> void:
	if _buy_signal == null:
		return
	buy_confirm_summary.text = (
		"%s ×%d @ %s\nTotal %s\n%s–%s · %s · %s"
		% [
			_buy_signal.display_name,
			_buy_signal.quantity,
			DemandSignalPresenter.format_cents(_buy_signal.unit_cost_cents),
			DemandSignalPresenter.format_cents(_buy_signal.lot_total_cents),
			DemandSignalPresenter.format_cents(_buy_signal.shown_comp_low_cents),
			DemandSignalPresenter.format_cents(_buy_signal.shown_comp_high_cents),
			DemandSignalPresenter.band_chip(_buy_signal.shown_demand_band),
			String(_buy_signal.confidence).to_upper(),
		]
	)
	buy_panel.hide()
	buy_confirm_panel.show()
	_sync_modal_veil()


func _confirm_buy() -> void:
	if _buy_signal == null or not _buy_signal.can_confirm:
		return
	if not _spend_for_floor(8):
		return
	if DemandSignals.confirm_buy(_buy_signal):
		_close_buy()


func _inspect_buy() -> void:
	if _buy_signal == null or _buy_signal.inspected:
		_sync_inspect_button()
		return
	if not DemandSignals.can_inspect(_buy_signal):
		_sync_inspect_button()
		return
	var cost := GameState.shop.inspect_attention_cost()
	if GameState.attention_remaining < cost:
		_sync_inspect_button()
		return
	if not GameState.consume_attention(cost):
		_sync_inspect_button()
		return
	DemandSignals.inspect_buy(_buy_signal)
	buy_summary.text = DemandSignalPresenter.buy_summary(_buy_signal)
	_sync_inspect_button()


func _sync_inspect_button() -> void:
	if inspect_button == null:
		return
	var cost := GameState.shop.inspect_attention_cost()
	inspect_button.text = DemandSignalPresenter.inspect_action_label(cost)
	var recommended := (
		_buy_signal != null
		and DemandSignalService.recommends_inspect(_buy_signal.channel)
	)
	inspect_button.visible = recommended
	if not recommended:
		return
	inspect_button.disabled = (
		_buy_signal.inspected
		or GameState.attention_remaining < cost
	)


func _back_to_buy_detail() -> void:
	buy_confirm_panel.hide()
	buy_panel.show()
	_sync_modal_veil()


func _close_buy() -> void:
	buy_list_panel.hide()
	buy_panel.hide()
	buy_confirm_panel.hide()
	_buy_signal = null
	_sync_inspect_button()
	_sync_modal_veil()


func _open_price_list() -> void:
	_close_price()
	for child: Node in price_rows.get_children():
		price_rows.remove_child(child)
		child.queue_free()
	var signals := DemandSignals.priceable_stock_signals()
	price_empty_label.visible = signals.is_empty()
	for dto: PriceConfirmSignal in signals:
		var row := Button.new()
		row.text = DemandSignalPresenter.priceable_stock_row(dto)
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.custom_minimum_size = Vector2(0.0, 64.0)
		row.theme_type_variation = &"ListRowButton"
		row.pressed.connect(_select_price_stock.bind(dto))
		price_rows.add_child(row)
	price_list_panel.show()
	_sync_modal_veil()


func _select_price_stock(dto: PriceConfirmSignal) -> void:
	_price_signal = dto
	price_title.text = "PRICE · %s\n%s" % [
		dto.display_name,
		dto.display_context,
	]
	price_input.text = DemandSignalPresenter.format_cents(
		dto.listed_price_cents
	)
	_bind_price_chips(dto)
	_update_price_preview(price_input.text)
	price_list_panel.hide()
	price_panel.show()
	_sync_modal_veil()


func _update_price_preview(value: String) -> void:
	if _price_signal == null:
		return
	var listed_price_cents := DemandSignalPresenter.parse_cents(value)
	_price_signal = DemandSignals.refresh_price_signal(
		_price_signal,
		listed_price_cents
	)
	if _price_signal == null:
		return
	price_summary.text = DemandSignalPresenter.price_summary(
		_price_signal,
		false
	)
	_bind_price_chips(_price_signal)
	%PriceApplyButton.disabled = listed_price_cents <= 0


func _apply_price() -> void:
	if _price_signal == null:
		return
	if not _spend_for_floor(5):
		return
	InventoryService.set_listed_price(
		_price_signal.sku_id,
		DemandSignalPresenter.parse_cents(price_input.text)
	)
	if not _active_price_beat_id.is_empty():
		EventBus.beat_ui_resolved.emit(_active_price_beat_id, &"applied")
	_close_price()


func _cancel_price() -> void:
	if not _active_price_beat_id.is_empty():
		EventBus.beat_ui_resolved.emit(_active_price_beat_id, &"cancelled")
	_close_price()


func _close_price() -> void:
	price_list_panel.hide()
	price_panel.hide()
	_price_signal = null
	_active_price_beat_id = &""
	_sync_modal_veil()


func _on_price_focus_requested(
	sku_id: StringName,
	beat_id: StringName,
	message: String,
	suggestion_mode: StringName
) -> void:
	beat_toast.text = message
	beat_toast.show()
	for dto: PriceConfirmSignal in DemandSignals.priceable_stock_signals():
		if dto.sku_id != sku_id:
			continue
		_active_price_beat_id = beat_id
		_select_price_stock(dto)
		if suggestion_mode == &"undercut":
			price_input.text = DemandSignalPresenter.format_cents(
				DemandSignalPresenter.undercut_fill_cents(
					_price_signal.suggested_price_cents
				)
			)
			_update_price_preview(price_input.text)
			assert(
				_price_signal != null
				and _price_signal.position == &"undercut",
				"Undercut focus must refresh to an undercut position."
			)
		price_input.grab_focus()
		return


func _on_rent_decision_requested(payload: Dictionary) -> void:
	_rent_beat_id = StringName(payload.get("beat_id", &""))
	rent_title.text = String(
		payload.get("title", "Rent due today — shelf is soft")
	)
	rent_summary.text = (
		"Due at SETTLE: %s\nProjected cash after rent: %s\n"
		+ "Choose a response before opening the floor."
	) % [
		DemandSignalPresenter.format_cents(int(payload.get("rent_cents", 0))),
		DemandSignalPresenter.format_cents(
			int(payload.get("projected_cash_cents", 0))
		),
	]
	rent_fire_sale_button.disabled = not bool(
		payload.get("fire_sale_enabled", false)
	)
	rent_accessories_button.disabled = not bool(
		payload.get("accessory_enabled", false)
	)
	rent_loan_button.visible = bool(payload.get("loan_enabled", false))
	rent_loan_terms.text = (
		"Receive %s now.\nPay %s daily for %d days; lose %d Rep."
		% [
			DemandSignalPresenter.format_cents(
				int(payload.get("loan_cash_cents", 0))
			),
			DemandSignalPresenter.format_cents(
				int(payload.get("loan_daily_cents", 0))
			),
			int(payload.get("loan_days", 0)),
			int(payload.get("loan_rep_hit", 0)),
		]
	)
	_close_rent_loan_confirm()
	phase_button.disabled = true
	rent_panel.show()
	_sync_modal_veil()


func _select_rent_path(choice: StringName) -> void:
	rent_panel.hide()
	_sync_modal_veil()
	EventBus.rent_decision_selected.emit(choice)


func _open_rent_loan_confirm() -> void:
	%RentChoices.hide()
	rent_loan_confirm.show()


func _close_rent_loan_confirm() -> void:
	rent_loan_confirm.hide()
	%RentChoices.show()


func _on_rent_decision_resolved(
	beat_id: StringName,
	outcome: StringName
) -> void:
	if beat_id != _rent_beat_id:
		return
	rent_panel.hide()
	_rent_beat_id = &""
	phase_button.disabled = false
	_sync_modal_veil()
	if outcome == &"dismissed":
		beat_toast.text = "Rent still due at SETTLE"
	elif outcome == &"payday_loan":
		beat_toast.text = "Payday loan accepted — rent still due at SETTLE"
	else:
		beat_toast.text = "Pricing path resolved — rent still due at SETTLE"
	beat_toast.show()


func _on_showcase_choice_requested(payload: Dictionary) -> void:
	_showcase_beat_id = StringName(payload.get("beat_id", &""))
	_showcase_choice_made = false
	showcase_title.text = String(payload.get("title", "Showcase choice"))
	showcase_summary.text = (
		"Case space: %d slot-weights free\nSlab costs 2; each single costs 1."
		% int(payload.get("free_slot_weight", 0))
	)
	showcase_slab_button.text = "Display slab\n%s" % payload.get("slab_label", "")
	showcase_singles_button.text = (
		"Display chase singles\n%s" % payload.get("singles_label", "")
	)
	showcase_panel.show()
	_sync_modal_veil()


func _select_showcase_choice(choice: StringName) -> void:
	EventBus.showcase_choice_selected.emit(choice)


func _on_showcase_choice_resolved(
	beat_id: StringName,
	choice: StringName
) -> void:
	if beat_id != _showcase_beat_id:
		return
	_showcase_choice_made = true
	showcase_summary.text = (
		"Displaying %s. You can switch this choice until the day ends."
		% ("the Empress slab" if choice == &"slab" else "both chase singles")
	)


func _on_showcase_choice_failed(message: String) -> void:
	showcase_summary.text = "Cannot change display: %s" % message


func _on_beat_decision_requested(payload: Dictionary) -> void:
	_beat_decision_id = StringName(payload.get("beat_id", &""))
	_beat_confirms = payload.get("confirms", {}) as Dictionary
	_pending_confirm_choice = &""
	beat_decision_title.text = String(payload.get("title", "Decision"))
	beat_decision_summary.text = String(payload.get("summary", ""))
	var choices: Array = payload.get("choices", [])
	var buttons: Array[Button] = [
		beat_choice_a_button,
		beat_choice_b_button,
		beat_choice_c_button,
	]
	if beat_choice_d_button != null:
		buttons.append(beat_choice_d_button)
	for index: int in buttons.size():
		var button := buttons[index]
		if index >= choices.size() or not choices[index] is Dictionary:
			button.hide()
			continue
		var choice := choices[index] as Dictionary
		button.text = String(choice.get("label", "Option"))
		button.disabled = not bool(choice.get("enabled", true))
		button.set_meta("choice_id", StringName(choice.get("id", &"")))
		button.show()
	_close_beat_confirm()
	phase_button.disabled = true
	beat_decision_panel.show()
	_sync_modal_veil()


func _select_beat_choice(button: Button) -> void:
	var choice := StringName(button.get_meta("choice_id", &""))
	if choice.is_empty():
		return
	var confirm_key := String(choice)
	if _beat_confirms.has(confirm_key):
		var confirm: Dictionary = _beat_confirms[confirm_key]
		_pending_confirm_choice = choice
		beat_confirm_title.text = String(confirm.get("title", "Confirm?"))
		beat_confirm_body.text = String(confirm.get("body", ""))
		%BeatChoices.hide()
		beat_confirm.show()
		return
	EventBus.beat_decision_selected.emit(choice)


func _close_beat_confirm() -> void:
	beat_confirm.hide()
	%BeatChoices.show()
	_pending_confirm_choice = &""


func _confirm_beat_choice() -> void:
	if _pending_confirm_choice.is_empty():
		return
	var choice := _pending_confirm_choice
	_close_beat_confirm()
	EventBus.beat_decision_selected.emit(choice)


func _on_beat_decision_resolved(
	beat_id: StringName,
	outcome: StringName
) -> void:
	if beat_id != _beat_decision_id:
		return
	beat_decision_panel.hide()
	_beat_decision_id = &""
	_beat_confirms = {}
	_pending_confirm_choice = &""
	phase_button.disabled = false
	_sync_modal_veil()
	match outcome:
		&"drive_out":
			beat_toast.text = "Left the floor — shorter FLOOR window today"
		&"courier":
			beat_toast.text = "Courier fee paid — FLOOR stays open"
		&"skip":
			beat_toast.text = "Passed on the off-site lot"
		&"hire_cashier", &"hire_cheap", &"hire_specialist":
			beat_toast.text = "Hire booked — wage posts at SETTLE"
		&"keep_solo":
			beat_toast.text = "Staying solo today"
		&"sign_lease":
			beat_toast.text = "Medium lease signed — floor unlocked, rent changes next week"
		&"wait_for_rep":
			beat_toast.text = "Waiting on reputation — still Small"
		&"stay_small":
			beat_toast.text = "Staying Small"
		&"buy":
			beat_toast.text = "Reviewing the trunk lot"
		&"report":
			beat_toast.text = "Reported the trunk sale"
		&"ignore":
			beat_toast.text = "Ignored the trunk sale"
		_:
			beat_toast.text = "Decision recorded"
	beat_toast.show()


func _on_buy_focus_requested(
	opportunity_id: StringName,
	_beat_id: StringName,
	message: String
) -> void:
	if not message.is_empty():
		beat_toast.text = message
		beat_toast.show()
	for dto: BuyConfirmSignal in DemandSignals.open_buy_signals():
		if dto.opportunity_id != opportunity_id:
			continue
		_select_buy_opportunity(dto)
		return


func _on_customer_head_changed(customer: CustomerProfile) -> void:
	_current_customer = customer
	if _current_customer == null:
		_desk_customer_ready = false
		_serve_dismissed = false
	_sync_customer_serve()


func _on_customer_desk_ready(customer: CustomerProfile, ready: bool) -> void:
	if customer != null and customer != _current_customer:
		return
	_desk_customer_ready = ready
	if ready:
		_serve_dismissed = false
	_sync_customer_serve()


func dismiss_customer_serve() -> void:
	if not serve_panel.visible:
		return
	_serve_dismissed = true
	serve_panel.hide()
	set_process(false)
	_sync_modal_veil()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo or key.keycode != KEY_ESCAPE:
		return
	if serve_panel.visible:
		dismiss_customer_serve()
		get_viewport().set_input_as_handled()


func _sync_customer_serve() -> void:
	if (
		_current_customer == null
		or not _desk_customer_ready
		or _serve_dismissed
	):
		serve_panel.hide()
		set_process(false)
		_sync_modal_veil()
		return
	serve_panel.show()
	set_process(true)
	_sync_patience_bar(_current_customer)
	_sync_modal_veil()
	if (
		_current_customer.trade_intent
		== CustomerProfile.TradeIntent.SELLING_TO_SHOP
	):
		customer_title.text = "SELLER · %s" % _current_customer.display_name
		customer_summary.text = DemandSignalPresenter.buylist_seller_summary(
			_current_customer.buylist_signal
		)
		%NegotiateButton.hide()
		%SellButton.text = "Buy at offer"
		%SellButton.disabled = (
			_current_customer.buylist_signal == null
			or not _current_customer.buylist_signal.can_confirm
		)
		return
	customer_title.text = "CUSTOMER · %s" % _current_customer.display_name
	var signal_dto := DemandSignals.price_signal(
		_current_customer.target_sku,
		_current_customer.listed_price_cents,
		InventoryService.location_for(_current_customer.target_sku)
	)
	customer_summary.text = (
		"Wants: %s\n%s: %s\n%s"
		% [
			_customer_wants_label(_current_customer),
			DemandSignalPresenter.price_label(
				DemandSignalPresenter.PriceContext.CUSTOMER_BUYING_FROM_SHOP
			),
			DemandSignalPresenter.format_cents(_current_customer.listed_price_cents),
			DemandSignalPresenter.price_summary(signal_dto),
		]
	)
	%NegotiateButton.show()
	%NegotiateButton.disabled = _current_customer.has_negotiated
	%SellButton.text = "Sell at list"
	%SellButton.disabled = false


func _sell_customer() -> void:
	if (
		_current_customer != null
		and _current_customer.trade_intent
		== CustomerProfile.TradeIntent.SELLING_TO_SHOP
	):
		EventBus.customer_action_requested.emit(&"accept_buylist")
		return
	EventBus.customer_action_requested.emit(&"sell_listed")


func _negotiate_customer() -> void:
	EventBus.customer_action_requested.emit(&"negotiate")


func _refuse_customer() -> void:
	EventBus.customer_action_requested.emit(&"refuse")


func _spend_for_floor(cost: int) -> bool:
	if GameState.current_phase != GameState.DayPhase.FLOOR:
		return true
	return GameState.spend_attention(cost)


func _customer_wants_label(customer: CustomerProfile) -> String:
	var sku_id := customer.target_sku
	var sku := InventoryService.model.get_sku(sku_id)
	var display_name := sku.display_name if sku != null else ""
	var slab := InventoryService.get_slab(sku_id)
	if slab != null:
		return DemandSignalPresenter.wants_label(
			display_name,
			sku_id,
			"",
			String(slab.grader),
			slab.grade
		)
	var card := InventoryService.get_card(sku_id)
	var condition := ""
	if card != null:
		condition = CardInstance.Condition.keys()[card.condition]
	elif (
		sku != null
		and sku.product_class == ProductSKU.ProductClass.SINGLE
	):
		condition = CardInstance.Condition.keys()[CardInstance.Condition.NM]
	return DemandSignalPresenter.wants_label(display_name, sku_id, condition)


func _bind_price_chips(dto: PriceConfirmSignal) -> void:
	price_position_chip.text = DemandSignalPresenter.position_chip(dto.position)
	price_demand_chip.text = DemandSignalPresenter.band_chip(
		dto.shown_demand_band
	)
	price_move_chip.text = DemandSignalPresenter.move_feel_chip(dto.move_feel)


func _sync_patience_bar(customer: CustomerProfile) -> void:
	patience_bar.max_value = maxf(customer.patience_seconds, 0.001)
	patience_bar.value = maxf(
		customer.patience_seconds - customer.waited_seconds,
		0.0
	)


func _sync_prep_action_buttons() -> void:
	_sync_staff_panel()
	if open_research_button == null or open_rearrange_button == null:
		return
	var research_att := GameState.shop.research_attention_cost()
	var research_cash := GameState.shop.research_cash_cost_cents()
	var rearrange_att := GameState.shop.rearrange_attention_cost()
	open_research_button.text = DemandSignalPresenter.research_action_label(
		research_cash,
		research_att
	)
	open_rearrange_button.text = DemandSignalPresenter.rearrange_action_label(
		rearrange_att
	)
	research_hint.text = (
		"Spend %s and Att %d to narrow comps and demand bands for one set. "
		+ "Rotation watch lasts 1–3 days. Does not reveal condition or certs."
	) % [
		DemandSignalPresenter.format_cents(research_cash),
		research_att,
	]
	research_confirm_button.text = DemandSignalPresenter.research_action_label(
		research_cash,
		research_att
	)
	rearrange_hint.text = (
		"Move a fixture. Costs Att %d. Rejected if the path from entrance "
		+ "to displays to counter breaks."
	) % rearrange_att
	rearrange_confirm_button.text = DemandSignalPresenter.rearrange_action_label(
		rearrange_att
	)
	var research_ok := (
		GameState.can_research()
		and GameState.attention_remaining >= research_att
		and Economy.can_afford(research_cash)
	)
	if GameState.current_phase == GameState.DayPhase.FLOOR and _queue_length > 0:
		research_ok = false
	open_research_button.disabled = not research_ok
	open_rearrange_button.disabled = (
		not GameState.can_rearrange()
		or GameState.attention_remaining < rearrange_att
	)
	if research_confirm_panel.visible:
		research_confirm_button.disabled = not DemandSignals.can_research_set(
			_pending_research_set
		)
	if rearrange_panel.visible:
		var preview := (
			GameState.shop.layout.preview_move(
				_selected_rearrange_fixture,
				_selected_rearrange_origin
			)
			if not _selected_rearrange_fixture.is_empty()
			and _selected_rearrange_origin != Vector2i(-1, -1)
			else &"unchanged"
		)
		rearrange_confirm_button.disabled = (
			preview != &"ok"
			or GameState.attention_remaining < rearrange_att
			or not GameState.can_rearrange()
		)


func _open_research_list() -> void:
	if open_research_button.disabled:
		return
	_close_research()
	for child: Node in research_rows.get_children():
		research_rows.remove_child(child)
		child.queue_free()
	var research_att := GameState.shop.research_attention_cost()
	var research_cash := GameState.shop.research_cash_cost_cents()
	for snapshot: Dictionary in DemandSignals.researchable_sets():
		var set_id := StringName(snapshot.get("set_id", &""))
		var row := Button.new()
		var informed := bool(snapshot.get("informed", false))
		row.text = "%s\n%s" % [
			String(snapshot.get("display_name", String(set_id))),
			(
				"Active through day %d" % int(snapshot.get("through_day", 0))
				if informed
				else DemandSignalPresenter.research_action_label(
					research_cash,
					research_att
				)
			),
		]
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.custom_minimum_size = Vector2(0.0, 56.0)
		row.theme_type_variation = &"ListRowButton"
		row.disabled = informed or not DemandSignals.can_research_set(set_id)
		row.pressed.connect(_select_research_set.bind(snapshot))
		research_rows.add_child(row)
	research_list_panel.show()
	_sync_modal_veil()


func _select_research_set(snapshot: Dictionary) -> void:
	_pending_research_set = StringName(snapshot.get("set_id", &""))
	var research_att := GameState.shop.research_attention_cost()
	var research_cash := GameState.shop.research_cash_cost_cents()
	research_confirm_title.text = "RESEARCH · %s" % snapshot.get("display_name", "")
	research_confirm_body.text = "\n".join([
		DemandSignalPresenter.research_action_label(research_cash, research_att),
		"Narrows comps (×%.2f) and demand-band σ for this set." % (
			GameState.balance_config.research_comp_narrow_factor
		),
		"Soft telegraph: Rotation watch: %s (1–3 days)." % snapshot.get(
			"display_name",
			""
		),
		"Condition grade and certification stay hidden.",
	])
	research_confirm_button.disabled = not DemandSignals.can_research_set(
		_pending_research_set
	)
	research_list_panel.hide()
	research_confirm_panel.show()
	_sync_modal_veil()


func _confirm_research() -> void:
	if _pending_research_set.is_empty():
		return
	if not DemandSignals.can_research_set(_pending_research_set):
		_sync_prep_action_buttons()
		return
	var result := DemandSignals.research_set(_pending_research_set)
	if not bool(result.get("ok", false)):
		beat_toast.text = "Research blocked"
		beat_toast.show()
		_sync_prep_action_buttons()
		return
	beat_toast.text = String(result.get("rotation_watch", "Research complete"))
	beat_toast.show()
	_sync_rotation_watch()
	_close_research()


func _back_to_research_list() -> void:
	research_confirm_panel.hide()
	research_list_panel.show()
	_sync_modal_veil()


func _close_research() -> void:
	if research_list_panel != null:
		research_list_panel.hide()
	if research_confirm_panel != null:
		research_confirm_panel.hide()
	_pending_research_set = &""
	_sync_modal_veil()


func _sync_rotation_watch() -> void:
	if rotation_watch_label == null:
		return
	var text := DemandSignals.rotation_watch_text()
	rotation_watch_label.text = text
	rotation_watch_label.visible = not text.is_empty()


func _open_rearrange() -> void:
	if open_rearrange_button.disabled:
		return
	_selected_rearrange_fixture = &""
	_selected_rearrange_origin = Vector2i(-1, -1)
	_rebuild_rearrange_fixtures()
	_rebuild_rearrange_grid()
	rearrange_status.text = "Select a fixture, then a destination tile."
	rearrange_panel.show()
	_sync_prep_action_buttons()
	_sync_modal_veil()


func _rebuild_rearrange_fixtures() -> void:
	for child: Node in rearrange_fixture_rows.get_children():
		rearrange_fixture_rows.remove_child(child)
		child.queue_free()
	for fixture: ShopFixture in GameState.shop.layout.movable_fixtures():
		var row := Button.new()
		row.text = "%s\n(%d, %d)" % [
			fixture.display_name,
			fixture.origin.x,
			fixture.origin.y,
		]
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.custom_minimum_size = Vector2(0.0, 56.0)
		row.theme_type_variation = &"ListRowButton"
		row.pressed.connect(_select_rearrange_fixture.bind(fixture.id))
		rearrange_fixture_rows.add_child(row)


func _rebuild_rearrange_grid() -> void:
	for child: Node in rearrange_grid.get_children():
		rearrange_grid.remove_child(child)
		child.queue_free()
	var layout := GameState.shop.layout
	rearrange_grid.columns = layout.width
	for y: int in layout.height:
		for x: int in layout.width:
			var cell := Vector2i(x, y)
			var tile := Button.new()
			tile.custom_minimum_size = Vector2(28, 28)
			tile.text = _rearrange_tile_label(cell)
			tile.pressed.connect(_select_rearrange_tile.bind(cell))
			rearrange_grid.add_child(tile)


func _rearrange_tile_label(cell: Vector2i) -> String:
	var layout := GameState.shop.layout
	if cell == layout.entrance:
		return "E"
	for fixture: ShopFixture in layout.fixtures:
		if fixture.occupies(cell):
			if fixture.is_counter:
				return "C"
			if fixture.kind == &"architecture":
				return "■"
			return fixture.display_name.left(1)
	return ""


func _select_rearrange_fixture(fixture_id: StringName) -> void:
	_selected_rearrange_fixture = fixture_id
	var fixture := GameState.shop.layout.fixture_by_id(fixture_id)
	if fixture == null:
		return
	rearrange_status.text = "Moving %s from (%d, %d). Pick a destination." % [
		fixture.display_name,
		fixture.origin.x,
		fixture.origin.y,
	]
	_sync_prep_action_buttons()


func _select_rearrange_tile(cell: Vector2i) -> void:
	if _selected_rearrange_fixture.is_empty():
		rearrange_status.text = "Select a fixture first."
		return
	_selected_rearrange_origin = cell
	var preview := GameState.shop.layout.preview_move(
		_selected_rearrange_fixture,
		cell
	)
	rearrange_status.text = _rearrange_preview_text(preview, cell)
	_sync_prep_action_buttons()


func _rearrange_preview_text(reason: StringName, cell: Vector2i) -> String:
	match reason:
		&"ok":
			return "Move to (%d, %d). Confirm spends Att %d." % [
				cell.x,
				cell.y,
				GameState.shop.rearrange_attention_cost(),
			]
		&"blocked_path":
			return "Illegal pathing: entrance must reach displays then counter."
		&"overlap":
			return "That tile is occupied."
		&"out_of_bounds":
			return "That destination does not fit on the grid."
		&"immovable":
			return "That fixture cannot be moved."
		&"unchanged":
			return "Already at (%d, %d)." % [cell.x, cell.y]
	return "Cannot move there (%s)." % String(reason)


func _confirm_rearrange() -> void:
	if _selected_rearrange_fixture.is_empty():
		return
	if GameState.attention_remaining < GameState.shop.rearrange_attention_cost():
		_sync_prep_action_buttons()
		return
	var result := GameState.rearrange_fixture(
		_selected_rearrange_fixture,
		_selected_rearrange_origin
	)
	if not bool(result.get("ok", false)):
		rearrange_status.text = _rearrange_preview_text(
			StringName(result.get("reason", &"blocked_path")),
			_selected_rearrange_origin
		)
		beat_toast.text = rearrange_status.text
		beat_toast.show()
		_sync_prep_action_buttons()
		return
	beat_toast.text = "Layout updated · Att %d" % int(result.get("attention_spent", 0))
	beat_toast.show()
	_close_rearrange()


func _close_rearrange() -> void:
	if rearrange_panel != null:
		rearrange_panel.hide()
	_selected_rearrange_fixture = &""
	_selected_rearrange_origin = Vector2i(-1, -1)
	_sync_modal_veil()


func _on_staff_changed() -> void:
	_sync_inspect_button()
	_sync_prep_action_buttons()


func _open_staff() -> void:
	if open_staff_button == null or open_staff_button.disabled:
		return
	_close_research()
	_close_rearrange()
	_sync_staff_panel()
	if staff_panel != null:
		staff_panel.show()
	_sync_modal_veil()


func _close_staff() -> void:
	if staff_panel != null:
		staff_panel.hide()
	_sync_modal_veil()


func _hire_from_panel(role: StringName) -> void:
	if not _can_hire_from_panel():
		_sync_staff_panel()
		return
	var hired: StaffMember = null
	match role:
		&"cashier":
			hired = GameState.shop.hire_cashier(false)
		&"specialist":
			hired = GameState.shop.hire_specialist()
		_:
			return
	if hired == null:
		_sync_staff_panel()
		return
	beat_toast.text = "Hire booked — wage posts at SETTLE"
	beat_toast.show()
	_sync_staff_panel()


func _can_hire_from_panel() -> bool:
	return (
		GameState.is_game_active
		and GameState.current_phase == GameState.DayPhase.PREP
		and GameState.shop.can_hire()
	)


func _sync_staff_panel() -> void:
	if open_staff_button != null:
		open_staff_button.disabled = (
			not GameState.is_game_active
			or GameState.current_phase != GameState.DayPhase.PREP
		)
	if staff_hint != null:
		staff_hint.text = (
			"Roster %d / %d. Wages post at SETTLE. Specialist lowers Inspect and Research Attention."
			% [GameState.shop.hired_count(), GameState.shop.staff_cap()]
		)
	if hire_cashier_button != null:
		hire_cashier_button.text = (
			"Hire Cashier · %s/day"
			% DemandSignalPresenter.format_cents(ShopState.CASHIER_WAGE_CENTS)
		)
		hire_cashier_button.disabled = not _can_hire_from_panel()
	if hire_specialist_button != null:
		hire_specialist_button.text = (
			"Hire Specialist · %s/day"
			% DemandSignalPresenter.format_cents(GameState.shop.specialist_wage_cents())
		)
		hire_specialist_button.disabled = not _can_hire_from_panel()
	if staff_rows == null:
		return
	for child: Node in staff_rows.get_children():
		staff_rows.remove_child(child)
		child.queue_free()
	if GameState.shop.staff.is_empty():
		var empty := Label.new()
		empty.text = "Owner only — no hired staff."
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		staff_rows.add_child(empty)
		return
	for index: int in GameState.shop.staff.size():
		var member := GameState.shop.staff[index]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "%s · %s/day" % [
			member.display_name,
			DemandSignalPresenter.format_cents(member.wage_cents),
		]
		var fire := Button.new()
		fire.text = "Fire"
		fire.custom_minimum_size = Vector2(72, 40)
		fire.disabled = GameState.current_phase != GameState.DayPhase.PREP
		fire.pressed.connect(_fire_from_panel.bind(index))
		row.add_child(label)
		row.add_child(fire)
		staff_rows.add_child(row)


func _fire_from_panel(index: int) -> void:
	if GameState.current_phase != GameState.DayPhase.PREP:
		return
	var member := GameState.shop.fire_staff(index)
	if member == null:
		return
	beat_toast.text = "Fired %s — wage stops" % member.display_name
	beat_toast.show()
	_sync_staff_panel()


func _process(_delta: float) -> void:
	if _current_customer != null and serve_panel.visible:
		_sync_patience_bar(_current_customer)


func _sync_modal_veil() -> void:
	%ModalVeil.visible = (
		buy_list_panel.visible
		or buy_panel.visible
		or buy_confirm_panel.visible
		or price_list_panel.visible
		or price_panel.visible
		or serve_panel.visible
		or rent_panel.visible
		or showcase_panel.visible
		or beat_decision_panel.visible
		or research_list_panel.visible
		or research_confirm_panel.visible
		or rearrange_panel.visible
		or (staff_panel != null and staff_panel.visible)
	)
