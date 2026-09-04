extends Control

@onready var cash_label: Label = %CashLabel
@onready var day_label: Label = %DayLabel
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
@onready var price_panel: PanelContainer = %PriceEditor
@onready var price_input: LineEdit = %PriceInput
@onready var price_summary: Label = %PriceSummary
@onready var serve_panel: PanelContainer = %CustomerServe
@onready var customer_title: Label = %CustomerTitle
@onready var customer_summary: Label = %CustomerSummary

var _buy_signal: BuyConfirmSignal
var _price_signal: PriceConfirmSignal
var _current_customer: CustomerProfile


func _ready() -> void:
	EventBus.cash_changed.connect(_update_cash)
	EventBus.day_started.connect(_update_day)
	EventBus.day_phase_changed.connect(_update_phase)
	EventBus.attention_changed.connect(_update_attention)
	EventBus.customer_queue_changed.connect(_update_queue)
	EventBus.customer_head_changed.connect(_on_customer_head_changed)
	phase_button.pressed.connect(_on_phase_pressed)
	%OpenBuyButton.pressed.connect(_open_buy_list)
	%BuyListCancelButton.pressed.connect(_close_buy)
	%BuyCancelButton.pressed.connect(_close_buy)
	buy_button.pressed.connect(_open_buy_confirm)
	%BuyBackButton.pressed.connect(_back_to_buy_detail)
	%BuyConfirmButton.pressed.connect(_confirm_buy)
	%OpenPriceButton.pressed.connect(_open_price_editor)
	%PriceCancelButton.pressed.connect(_close_price)
	%PriceApplyButton.pressed.connect(_apply_price)
	price_input.text_changed.connect(_update_price_preview)
	%SellButton.pressed.connect(_sell_customer)
	%NegotiateButton.pressed.connect(_negotiate_customer)
	%RefuseButton.pressed.connect(_refuse_customer)
	_update_cash(Economy.balance_cents)
	_update_day(GameState.current_day)
	_update_phase(GameState.current_phase)
	_update_attention(GameState.attention_remaining)
	_update_queue(0)


func _update_cash(balance_cents: int) -> void:
	cash_label.text = "Cash  %s" % DemandSignalPresenter.format_cents(balance_cents)


func _update_day(day: int) -> void:
	day_label.text = "Day %d" % day


func _update_phase(phase: int) -> void:
	var phase_name: String = String(GameState.DayPhase.keys()[phase]).capitalize()
	phase_label.text = "Phase  %s" % phase_name
	match phase:
		GameState.DayPhase.PREP:
			phase_button.text = "Open floor"
		GameState.DayPhase.FLOOR:
			phase_button.text = "Close & settle"
		GameState.DayPhase.SETTLE:
			phase_button.text = "Next day"
	_close_buy()
	_close_price()


func _update_attention(remaining: int) -> void:
	attention_label.text = "Attention  %d" % remaining


func _update_queue(length: int) -> void:
	queue_label.text = "Queue  %d" % length


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
		row.pressed.connect(_select_buy_opportunity.bind(dto))
		buy_rows.add_child(row)
	buy_list_panel.show()


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
			String(_buy_signal.shown_demand_band).to_upper(),
			String(_buy_signal.confidence).to_upper(),
		]
	)
	buy_panel.hide()
	buy_confirm_panel.show()


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


func _close_buy() -> void:
	buy_list_panel.hide()
	buy_panel.hide()
	buy_confirm_panel.hide()
	_buy_signal = null


func _open_price_editor() -> void:
	var current_price := InventoryService.listed_price_for(&"AA-DUST-ETB")
	price_input.text = DemandSignalPresenter.format_cents(current_price)
	_update_price_preview(price_input.text)
	price_panel.show()


func _update_price_preview(value: String) -> void:
	var location := InventoryService.location_for(&"AA-DUST-ETB")
	if location == null:
		return
	var listed_price_cents := DemandSignalPresenter.parse_cents(value)
	_price_signal = DemandSignals.price_signal(
		&"AA-DUST-ETB",
		listed_price_cents,
		location
	)
	price_summary.text = DemandSignalPresenter.price_summary(_price_signal)
	%PriceApplyButton.disabled = listed_price_cents <= 0


func _apply_price() -> void:
	if not _spend_for_floor(5):
		return
	InventoryService.set_listed_price(
		&"AA-DUST-ETB",
		DemandSignalPresenter.parse_cents(price_input.text)
	)
	_close_price()


func _close_price() -> void:
	price_panel.hide()


func _on_customer_head_changed(customer: CustomerProfile) -> void:
	_current_customer = customer
	if _current_customer == null:
		serve_panel.hide()
		return
	serve_panel.show()
	customer_title.text = "CUSTOMER · %s" % _current_customer.display_name
	var signal_dto := DemandSignals.price_signal(
		_current_customer.target_sku,
		_current_customer.listed_price_cents,
		InventoryService.location_for(_current_customer.target_sku)
	)
	customer_summary.text = (
		"Wants: %s\n%s: %s\n%s"
		% [
			String(_current_customer.target_sku),
			DemandSignalPresenter.price_label(
				DemandSignalPresenter.PriceContext.CUSTOMER_BUYING_FROM_SHOP
			),
			DemandSignalPresenter.format_cents(_current_customer.listed_price_cents),
			DemandSignalPresenter.price_summary(signal_dto),
		]
	)
	%NegotiateButton.disabled = _current_customer.has_negotiated


func _sell_customer() -> void:
	EventBus.customer_action_requested.emit(&"sell_listed")


func _negotiate_customer() -> void:
	EventBus.customer_action_requested.emit(&"negotiate")


func _refuse_customer() -> void:
	EventBus.customer_action_requested.emit(&"refuse")


func _spend_for_floor(cost: int) -> bool:
	if GameState.current_phase != GameState.DayPhase.FLOOR:
		return true
	return GameState.spend_attention(cost)
