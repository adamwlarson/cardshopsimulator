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
@onready var showcase_panel: PanelContainer = %ShowcaseChoice
@onready var showcase_title: Label = %ShowcaseTitle
@onready var showcase_summary: Label = %ShowcaseSummary
@onready var showcase_slab_button: Button = %ShowcaseSlabButton
@onready var showcase_singles_button: Button = %ShowcaseSinglesButton

var _buy_signal: BuyConfirmSignal
var _price_signal: PriceConfirmSignal
var _current_customer: CustomerProfile
var _active_price_beat_id: StringName = &""
var _showcase_beat_id: StringName = &""


func _ready() -> void:
	EventBus.cash_changed.connect(_update_cash)
	EventBus.day_started.connect(_update_day)
	EventBus.day_phase_changed.connect(_update_phase)
	EventBus.attention_changed.connect(_update_attention)
	EventBus.customer_queue_changed.connect(_update_queue)
	EventBus.customer_head_changed.connect(_on_customer_head_changed)
	EventBus.price_focus_requested.connect(_on_price_focus_requested)
	EventBus.showcase_choice_requested.connect(_on_showcase_choice_requested)
	EventBus.showcase_choice_resolved.connect(_on_showcase_choice_resolved)
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
	showcase_slab_button.pressed.connect(_select_showcase_choice.bind(&"slab"))
	showcase_singles_button.pressed.connect(_select_showcase_choice.bind(&"singles"))
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
	showcase_panel.hide()


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
		row.pressed.connect(_select_price_stock.bind(dto))
		price_rows.add_child(row)
	price_list_panel.show()


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


func _on_price_focus_requested(
	sku_id: StringName,
	beat_id: StringName,
	message: String
) -> void:
	beat_toast.text = message
	beat_toast.show()
	for dto: PriceConfirmSignal in DemandSignals.priceable_stock_signals():
		if dto.sku_id != sku_id:
			continue
		_active_price_beat_id = beat_id
		_select_price_stock(dto)
		price_input.grab_focus()
		return


func _on_showcase_choice_requested(payload: Dictionary) -> void:
	_showcase_beat_id = StringName(payload.get("beat_id", &""))
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


func _select_showcase_choice(choice: StringName) -> void:
	EventBus.showcase_choice_selected.emit(choice)


func _on_showcase_choice_resolved(
	beat_id: StringName,
	choice: StringName
) -> void:
	if beat_id != _showcase_beat_id:
		return
	showcase_summary.text = (
		"Displaying %s. You can switch this choice until the day ends."
		% ("the Empress slab" if choice == &"slab" else "both chase singles")
	)


func _on_customer_head_changed(customer: CustomerProfile) -> void:
	_current_customer = customer
	if _current_customer == null:
		serve_panel.hide()
		return
	serve_panel.show()
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
			String(_current_customer.target_sku),
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
