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
@onready var serve_panel: PanelContainer = %CustomerServe
@onready var customer_title: Label = %CustomerTitle
@onready var customer_summary: Label = %CustomerSummary
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

var _buy_signal: BuyConfirmSignal
var _price_signal: PriceConfirmSignal
var _current_customer: CustomerProfile
var _active_price_beat_id: StringName = &""
var _rent_beat_id: StringName = &""
var _showcase_beat_id: StringName = &""
var _showcase_choice_made: bool = false


func _ready() -> void:
	EventBus.cash_changed.connect(_update_cash)
	EventBus.day_started.connect(_update_day)
	EventBus.day_phase_changed.connect(_update_phase)
	EventBus.attention_changed.connect(_update_attention)
	EventBus.customer_queue_changed.connect(_update_queue)
	EventBus.customer_head_changed.connect(_on_customer_head_changed)
	EventBus.price_focus_requested.connect(_on_price_focus_requested)
	EventBus.rent_decision_requested.connect(_on_rent_decision_requested)
	EventBus.rent_decision_resolved.connect(_on_rent_decision_resolved)
	EventBus.showcase_choice_requested.connect(_on_showcase_choice_requested)
	EventBus.showcase_choice_resolved.connect(_on_showcase_choice_resolved)
	EventBus.showcase_choice_failed.connect(_on_showcase_choice_failed)
	phase_button.pressed.connect(_on_phase_pressed)
	%OpenBuyButton.pressed.connect(_open_buy_list)
	%BuyListCancelButton.pressed.connect(_close_buy)
	%BuyCancelButton.pressed.connect(_close_buy)
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
	_bind_seeded_status()
	_update_queue(0)


func _bind_seeded_status() -> void:
	if not GameState.is_game_active:
		GameState.start_new_game()
	_update_cash(Economy.balance_cents)
	_update_day(GameState.current_day)
	_update_phase(GameState.current_phase)
	_update_attention(GameState.attention_remaining)


func _update_cash(balance_cents: int) -> void:
	cash_label.text = DemandSignalPresenter.format_cents(balance_cents)


func _update_day(day: int) -> void:
	day_label.text = "Day %d" % day


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
	if phase == GameState.DayPhase.SETTLE and _showcase_choice_made:
		showcase_panel.hide()
	_sync_modal_veil()


func _update_attention(remaining: int) -> void:
	attention_label.text = "Att %d/%d" % [
		remaining,
		GameState.balance_config.attention_pool,
	]


func _update_queue(length: int) -> void:
	queue_label.text = "Queue %d" % length


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


func _back_to_buy_detail() -> void:
	buy_confirm_panel.hide()
	buy_panel.show()
	_sync_modal_veil()


func _close_buy() -> void:
	buy_list_panel.hide()
	buy_panel.hide()
	buy_confirm_panel.hide()
	_buy_signal = null
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
	price_summary.text = DemandSignalPresenter.price_summary(_price_signal)
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


func _on_customer_head_changed(customer: CustomerProfile) -> void:
	_current_customer = customer
	if _current_customer == null:
		serve_panel.hide()
		_sync_modal_veil()
		return
	serve_panel.show()
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
		%SellButton.disabled = not _current_customer.buylist_signal.can_confirm
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
	)
