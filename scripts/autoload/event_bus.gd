extends Node

signal cash_changed(balance_cents: int)
signal transaction_recorded(entry: LedgerEntry)
signal inventory_changed(sku: StringName, quantity: int)
signal day_started(day: int)
signal day_phase_changed(phase: int)
signal attention_changed(remaining: int)
signal reputation_changed(reputation: int)
signal customer_arrived(customer: CustomerProfile)
signal customer_queue_changed(length: int)
signal customer_head_changed(customer: CustomerProfile)
signal customer_action_requested(action: StringName)
signal scripted_customer_requested(customer: CustomerProfile)
signal customer_resolved(customer: CustomerProfile, outcome: StringName)
signal customer_floor_state_changed(customer: CustomerProfile, state: StringName)
signal customer_desk_ready_changed(customer: CustomerProfile, ready: bool)
signal customer_intent_changed(customer: CustomerProfile, intent: StringName)
signal price_focus_requested(
	sku_id: StringName,
	beat_id: StringName,
	message: String,
	suggestion_mode: StringName
)
signal rent_decision_requested(payload: Dictionary)
signal rent_decision_selected(choice: StringName)
signal rent_decision_resolved(beat_id: StringName, outcome: StringName)
signal showcase_choice_requested(payload: Dictionary)
signal showcase_choice_selected(choice: StringName)
signal showcase_choice_resolved(beat_id: StringName, choice: StringName)
signal showcase_choice_failed(message: String)
signal beat_ui_resolved(beat_id: StringName, outcome: StringName)
signal beat_decision_requested(payload: Dictionary)
signal beat_decision_selected(choice: StringName)
signal beat_decision_resolved(beat_id: StringName, outcome: StringName)
signal buy_focus_requested(
	opportunity_id: StringName,
	beat_id: StringName,
	message: String
)
signal shop_layout_changed()
signal staff_changed()

func publish_cash_changed(balance_cents: int) -> void:
	cash_changed.emit(balance_cents)


func publish_transaction(entry: LedgerEntry) -> void:
	transaction_recorded.emit(entry)


func publish_inventory_changed(sku: StringName, quantity: int) -> void:
	inventory_changed.emit(sku, quantity)
