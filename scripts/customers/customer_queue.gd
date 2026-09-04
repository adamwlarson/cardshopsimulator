class_name CustomerQueue
extends Node

signal queue_changed(length: int)
signal customer_ready(customer: CustomerProfile)
signal customer_finished(customer: CustomerProfile, outcome: StringName)

const NEGOTIATE_ATTENTION_COST := 8

var _customers: Array[CustomerProfile] = []
var _inventory_service: Node
var _reputation_hook: Callable
var _attention_hook: Callable


func configure(
	inventory_service: Node,
	reputation_hook: Callable = Callable(),
	attention_hook: Callable = Callable()
) -> void:
	_inventory_service = inventory_service
	_reputation_hook = reputation_hook
	_attention_hook = attention_hook


func enqueue(customer: CustomerProfile) -> bool:
	if customer == null or _inventory_service == null:
		return false
	var offer: Dictionary = _inventory_service.call(
		"find_listed_offer",
		customer.interest_tags,
		customer.budget_cents
	)
	if offer.is_empty():
		customer.state = CustomerProfile.State.LEFT
		customer_finished.emit(customer, &"no_stock")
		return false
	customer.target_sku = StringName(offer["sku_id"])
	customer.listed_price_cents = int(offer["listed_price_cents"])
	customer.desired_skus = [customer.target_sku]
	customer.begin_waiting()
	_customers.append(customer)
	queue_changed.emit(_customers.size())
	customer_ready.emit(customer)
	return true


func tick_waiting(delta: float) -> void:
	for customer: CustomerProfile in _customers.duplicate():
		if customer.tick_wait(delta):
			_customers.erase(customer)
			if _reputation_hook.is_valid():
				_reputation_hook.call(-1)
			customer_finished.emit(customer, &"timeout")
			queue_changed.emit(_customers.size())


func queue_head() -> CustomerProfile:
	for customer: CustomerProfile in _customers:
		if customer.state == CustomerProfile.State.SERVING:
			return customer
	for customer: CustomerProfile in _customers:
		if customer.state == CustomerProfile.State.WAITING:
			return customer
	return null


func begin_serving_head() -> CustomerProfile:
	var customer := queue_head()
	if customer != null and customer.state == CustomerProfile.State.WAITING:
		customer.begin_service()
	return customer


func sell_listed() -> bool:
	var customer := begin_serving_head()
	if customer == null or not customer.can_afford(
		customer.target_sku,
		customer.listed_price_cents
	):
		return false
	if not bool(_inventory_service.call(
		"confirm_customer_sale",
		customer.target_sku,
		customer.listed_price_cents
	)):
		return false
	_complete(customer, &"sold")
	return true


func negotiate(percent_from_list: float = -0.10) -> bool:
	var customer := begin_serving_head()
	if customer == null or customer.has_negotiated:
		return false
	if _attention_hook.is_valid() and not bool(
		_attention_hook.call(NEGOTIATE_ATTENTION_COST)
	):
		return false
	customer.has_negotiated = true
	var negotiated := negotiated_price_cents(
		customer.listed_price_cents,
		percent_from_list
	)
	if not customer.can_afford(customer.target_sku, negotiated):
		return false
	customer.listed_price_cents = negotiated
	return true


func refuse() -> bool:
	var customer := begin_serving_head()
	if customer == null:
		return false
	customer.state = CustomerProfile.State.LEFT
	if _reputation_hook.is_valid():
		_reputation_hook.call(-1)
	_complete(customer, &"refused")
	return true


func clear() -> void:
	_customers.clear()
	queue_changed.emit(0)


func size() -> int:
	return _customers.size()


static func negotiated_price_cents(
	listed_price_cents: int,
	percent_from_list: float
) -> int:
	var clamped_percent := clampf(percent_from_list, -0.10, 0.10)
	return maxi(1, roundi(listed_price_cents * (1.0 + clamped_percent)))


func _complete(customer: CustomerProfile, outcome: StringName) -> void:
	customer.state = (
		CustomerProfile.State.DONE
		if outcome == &"sold"
		else CustomerProfile.State.LEFT
	)
	_customers.erase(customer)
	customer_finished.emit(customer, outcome)
	queue_changed.emit(_customers.size())
