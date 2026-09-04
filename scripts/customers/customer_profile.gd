class_name CustomerProfile
extends Resource

enum State {
	ARRIVED,
	WAITING,
	SERVING,
	DONE,
	LEFT,
}

enum TradeIntent {
	BUYING_FROM_SHOP,
	SELLING_TO_SHOP,
}

@export var archetype_id: StringName = &"regular"
@export var display_name: String = "Shopper"
@export var trade_intent: TradeIntent = TradeIntent.BUYING_FROM_SHOP
@export var desired_skus: Array[StringName] = []
@export_range(0, 1_000_000, 1) var budget_cents: int = 5_000
@export_range(1.0, 600.0, 1.0) var patience_seconds: float = 60.0
@export var interest_tags: Array[StringName] = []
@export var state: State = State.ARRIVED
@export var target_sku: StringName = &""
@export_range(0, 100_000_000, 1) var listed_price_cents: int = 0
@export var buylist_signal: BuyConfirmSignal

var waited_seconds: float = 0.0
var has_negotiated: bool = false


func can_afford(sku: StringName, price_cents: int) -> bool:
	return (
		sku in desired_skus
		and price_cents > 0
		and price_cents <= budget_cents
	)


func begin_waiting() -> void:
	state = State.WAITING


func begin_service() -> bool:
	if state != State.WAITING:
		return false
	state = State.SERVING
	return true


func tick_wait(delta: float) -> bool:
	if state != State.WAITING:
		return false
	waited_seconds += delta
	if waited_seconds < patience_seconds:
		return false
	state = State.LEFT
	return true
