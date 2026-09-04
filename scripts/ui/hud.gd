extends Control

@onready var cash_label: Label = %CashLabel
@onready var day_label: Label = %DayLabel
@onready var phase_label: Label = %PhaseLabel
@onready var attention_label: Label = %AttentionLabel
@onready var queue_label: Label = %QueueLabel
@onready var phase_button: Button = %PhaseButton
@onready var buy_panel: PanelContainer = %BuyOpportunityDetail
@onready var buy_summary: Label = %BuySummary
@onready var buy_button: Button = %BuyButton
@onready var buy_confirm_panel: PanelContainer = %BuyConfirm
@onready var buy_confirm_summary: Label = %BuyConfirmSummary
@onready var price_panel: PanelContainer = %PriceEditor
@onready var price_input: SpinBox = %PriceInput
@onready var price_summary: Label = %PriceSummary
@onready var serve_panel: PanelContainer = %CustomerServe
@onready var customer_title: Label = %CustomerTitle
@onready var customer_summary: Label = %CustomerSummary

var _buy_signal: BuyConfirmSignal
var _price_signal: PriceConfirmSignal
var _customer_queue: CustomerQueue


func _ready() -> void:
	EventBus.cash_changed.connect(_update_cash)
	EventBus.day_started.connect(_update_day)
	EventBus.day_phase_changed.connect(_update_phase)
	EventBus.attention_changed.connect(_update_attention)
	EventBus.customer_queue_changed.connect(_update_queue)
	phase_button.pressed.connect(_on_phase_pressed)
	%OpenBuyButton.pressed.connect(_open_buy_detail)
	%BuyCancelButton.pressed.connect(_close_buy)
	buy_button.pressed.connect(_open_buy_confirm)
	%BuyBackButton.pressed.connect(_back_to_buy_detail)
	%BuyConfirmButton.pressed.connect(_confirm_buy)
	%OpenPriceButton.pressed.connect(_open_price_editor)
	%PriceCancelButton.pressed.connect(_close_price)
	%PriceApplyButton.pressed.connect(_apply_price)
	price_input.value_changed.connect(_update_price_preview)
	%SellButton.pressed.connect(_sell_customer)
	%NegotiateButton.pressed.connect(_negotiate_customer)
	%RefuseButton.pressed.connect(_refuse_customer)
	_update_cash(Economy.balance_cents)
	_update_day(GameState.current_day)
	_update_phase(GameState.current_phase)
	_update_attention(GameState.attention_remaining)
	_update_queue(0)
	call_deferred("_bind_customer_queue")


func _update_cash(balance_cents: int) -> void:
	cash_label.text = "Cash  %s" % DemandSignalPresenter.format_cents(balance_cents)


func _update_day(day: int) -> void:
	day_label.text = "Day %d" % day


func _update_phase(phase: int) -> void:
	var phase_name := GameState.DayPhase.keys()[phase].capitalize()
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
	_refresh_customer()


func _on_phase_pressed() -> void:
	match GameState.current_phase:
		GameState.DayPhase.PREP:
			GameState.start_floor()
		GameState.DayPhase.FLOOR:
			GameState.start_settle()
		GameState.DayPhase.SETTLE:
			GameState.advance_day()


func _open_buy_detail() -> void:
	_buy_signal = DemandSignals.buy_signal(
		&"AA-SKIE-ETB",
		DemandSignalService.Channel.MARKETPLACE,
		3200,
		1
	)
	buy_summary.text = DemandSignalPresenter.buy_summary(_buy_signal)
	buy_button.disabled = not _buy_signal.can_confirm
	buy_panel.show()
	buy_confirm_panel.hide()


func _open_buy_confirm() -> void:
	if _buy_signal == null:
		return
	buy_confirm_summary.text = (
		"Skiefall Ascension Explorer Box ×1\nTotal %s\n%s–%s · %s · %s"
		% [
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
	var shown_midpoint := (
		_buy_signal.shown_comp_low_cents
		+ _buy_signal.shown_comp_high_cents
	) / 2
	InventoryService.confirm_stock_purchase(
		_buy_signal.sku_id,
		1,
		_buy_signal.unit_cost_cents,
		shown_midpoint - _buy_signal.unit_cost_cents,
		InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	)
	_close_buy()


func _back_to_buy_detail() -> void:
	buy_confirm_panel.hide()
	buy_panel.show()


func _close_buy() -> void:
	buy_panel.hide()
	buy_confirm_panel.hide()


func _open_price_editor() -> void:
	var current_price := InventoryService.listed_price_for(&"AA-DUST-ETB")
	price_input.set_value_no_signal(current_price)
	_update_price_preview(current_price)
	price_panel.show()


func _update_price_preview(value: float) -> void:
	var location := InventoryService.location_for(&"AA-DUST-ETB")
	if location == null:
		return
	_price_signal = DemandSignals.price_signal(
		&"AA-DUST-ETB",
		roundi(value),
		location
	)
	price_summary.text = DemandSignalPresenter.price_summary(_price_signal)


func _apply_price() -> void:
	if not _spend_for_floor(5):
		return
	InventoryService.set_listed_price(&"AA-DUST-ETB", roundi(price_input.value))
	_close_price()


func _close_price() -> void:
	price_panel.hide()


func _bind_customer_queue() -> void:
	var spawner := get_tree().get_first_node_in_group("customer_spawner") as CustomerSpawner
	if spawner == null:
		return
	_customer_queue = spawner.get_queue()
	_refresh_customer()


func _refresh_customer() -> void:
	if _customer_queue == null:
		serve_panel.hide()
		return
	var customer := _customer_queue.queue_head()
	if customer == null:
		serve_panel.hide()
		return
	serve_panel.show()
	customer_title.text = "CUSTOMER · %s" % customer.display_name
	var signal_dto := DemandSignals.price_signal(
		customer.target_sku,
		customer.asking_price_cents,
		InventoryService.location_for(customer.target_sku)
	)
	customer_summary.text = (
		"Wants: %s\nYour list: %s\n%s"
		% [
			String(customer.target_sku),
			DemandSignalPresenter.format_cents(customer.asking_price_cents),
			DemandSignalPresenter.price_summary(signal_dto),
		]
	)
	%NegotiateButton.disabled = customer.has_negotiated


func _sell_customer() -> void:
	if _customer_queue != null:
		_customer_queue.sell_listed()
		_refresh_customer()


func _negotiate_customer() -> void:
	if _customer_queue != null:
		_customer_queue.negotiate(-0.10)
		_refresh_customer()


func _refuse_customer() -> void:
	if _customer_queue != null:
		_customer_queue.refuse()
		_refresh_customer()


func _spend_for_floor(cost: int) -> bool:
	if GameState.current_phase != GameState.DayPhase.FLOOR:
		return true
	return GameState.spend_attention(cost)
