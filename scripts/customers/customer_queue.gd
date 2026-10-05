class_name CustomerQueue
extends Node

signal queue_changed(length: int)
signal customer_ready(customer: CustomerProfile)
signal customer_finished(customer: CustomerProfile, outcome: StringName)

const NEGOTIATE_ATTENTION_COST := NegotiatePolicy.ATTENTION_COST
const PULL_ATTENTION_COST := 5

var last_negotiate_result: StringName = &""

var _customers: Array[CustomerProfile] = []
var _inventory_service: Node
var _reputation_hook: Callable
var _attention_hook: Callable
var _coverage_hook: Callable
var _walkout_rep_hook: Callable


func configure(
	inventory_service: Node,
	reputation_hook: Callable = Callable(),
	attention_hook: Callable = Callable(),
	coverage_hook: Callable = Callable(),
	walkout_rep_hook: Callable = Callable()
) -> void:
	_inventory_service = inventory_service
	_reputation_hook = reputation_hook
	_attention_hook = attention_hook
	_coverage_hook = coverage_hook
	_walkout_rep_hook = walkout_rep_hook


func enqueue(customer: CustomerProfile) -> bool:
	if customer == null or _inventory_service == null:
		return false
	if customer.trade_intent == CustomerProfile.TradeIntent.SELLING_TO_SHOP:
		if customer.buylist_signal == null:
			customer.state = CustomerProfile.State.LEFT
			customer_finished.emit(customer, &"no_buylist_offer")
			return false
		customer.target_sku = customer.buylist_signal.sku_id
		customer.begin_waiting()
		_customers.append(customer)
		queue_changed.emit(_customers.size())
		customer_ready.emit(customer)
		return true
	if customer.desired_skus.is_empty() and not customer.wants_sku.is_empty():
		customer.desired_skus = [customer.wants_sku]
	if not customer.desired_skus.is_empty():
		return enqueue_targeted(customer, customer.desired_skus[0])
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


func enqueue_targeted(customer: CustomerProfile, sku_id: StringName) -> bool:
	if customer == null or _inventory_service == null or sku_id.is_empty():
		return false
	var offer: Dictionary = _inventory_service.call(
		"find_listed_sku_offer",
		sku_id,
		customer.budget_cents
	)
	if offer.is_empty():
		customer.state = CustomerProfile.State.LEFT
		customer_finished.emit(customer, &"no_stock")
		return false
	customer.target_sku = sku_id
	customer.listed_price_cents = int(offer["listed_price_cents"])
	customer.desired_skus = [sku_id]
	customer.begin_waiting()
	_customers.append(customer)
	queue_changed.emit(_customers.size())
	customer_ready.emit(customer)
	return true


func tick_waiting(delta: float) -> void:
	resolve_register_walkouts()
	for customer: CustomerProfile in _customers.duplicate():
		if customer.tick_wait(delta):
			_customers.erase(customer)
			if _reputation_hook.is_valid():
				_reputation_hook.call(-1)
			customer_finished.emit(customer, &"timeout")
			queue_changed.emit(_customers.size())


func is_register_covered() -> bool:
	if not _coverage_hook.is_valid():
		return true
	return bool(_coverage_hook.call())


func resolve_register_walkouts() -> int:
	# AH1: a customer who needs service and finds no coverage leaves
	# that step. Patience timeout stays a separate &"timeout" path.
	if is_register_covered():
		return 0
	var walked := 0
	for customer: CustomerProfile in _customers.duplicate():
		if customer == null or customer.state != CustomerProfile.State.WAITING:
			continue
		if _walkout_rep_hook.is_valid():
			_walkout_rep_hook.call()
		_complete(customer, &"walkout")
		walked += 1
	return walked


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


func accept_buylist_offer() -> bool:
	var customer := begin_serving_head()
	if (
		customer == null
		or customer.trade_intent != CustomerProfile.TradeIntent.SELLING_TO_SHOP
		or customer.buylist_signal == null
	):
		return false
	var dto := customer.buylist_signal
	BuylistPolicy.ensure_lot_condition(dto, _serve_day())
	if not bool(_inventory_service.call("confirm_buylist_purchase", dto)):
		return false
	_complete(customer, &"bought")
	return true


func inspect_buylist(acting_role: StringName = BuylistPolicy.ACTOR_OWNER) -> bool:
	var customer := begin_serving_head()
	if not BuylistPolicy.can_inspect(customer, acting_role):
		return false
	var cost := BuylistPolicy.attention_cost()
	if _attention_hook.is_valid() and not bool(_attention_hook.call(cost)):
		return false
	if not BuylistPolicy.apply_inspect(customer.buylist_signal, _serve_day()):
		return false
	customer.has_inspected = true
	return true


func change_buylist_offer(offer_cents: int) -> bool:
	var customer := begin_serving_head()
	if not BuylistPolicy.can_change_offer(customer):
		return false
	if not BuylistPolicy.is_valid_change(offer_cents):
		return false
	BuylistPolicy.apply_offer_cents(customer.buylist_signal, offer_cents)
	customer.has_changed_offer = true
	_refresh_buylist_affordability(customer.buylist_signal)
	return true


func walk_buylist() -> bool:
	var customer := begin_serving_head()
	if (
		customer == null
		or customer.trade_intent != CustomerProfile.TradeIntent.SELLING_TO_SHOP
	):
		return false
	var dto := customer.buylist_signal
	if (
		dto != null
		and BuylistPolicy.is_stingy(
			dto.unit_cost_cents,
			BuylistPolicy.listed_comp_cents(dto)
		)
		and _reputation_hook.is_valid()
	):
		_reputation_hook.call(BuylistPolicy.miss_rep_delta())
	_complete(customer, &"walked")
	return true


func pull_from_backstock() -> bool:
	var customer := begin_serving_head()
	if customer == null or customer.target_sku.is_empty():
		return false
	if _inventory_service == null:
		return false
	if not bool(_inventory_service.call("has_backstock", customer.target_sku)):
		return false
	if _attention_hook.is_valid() and not bool(
		_attention_hook.call(PULL_ATTENTION_COST)
	):
		return false
	return bool(_inventory_service.call("pull_from_backstock", customer.target_sku))


func negotiate(
	percent_from_list: float = NegotiatePolicy.DIRECTION_MINUS,
	acting_role: StringName = NegotiatePolicy.ACTOR_OWNER
) -> bool:
	last_negotiate_result = NegotiatePolicy.RESULT_REFUSED
	var customer := begin_serving_head()
	if customer == null or customer.has_negotiated:
		return false
	if not NegotiatePolicy.can_negotiate_customer(customer):
		return false
	if not NegotiatePolicy.can_actor_negotiate(acting_role):
		return false
	var cost := NegotiatePolicy.attention_cost()
	if _attention_hook.is_valid() and not bool(_attention_hook.call(cost)):
		return false
	customer.has_negotiated = true
	var direction := NegotiatePolicy.direction_percent(percent_from_list)
	var listed := customer.listed_price_cents
	var negotiated := negotiated_price_cents(listed, direction)
	var reputation := _serve_reputation()
	var seed := NegotiatePolicy.roll_seed(
		NegotiatePolicy.customer_seed_key(customer),
		_serve_day(),
		direction
	)
	if NegotiatePolicy.roll_accept(
		seed,
		direction,
		reputation,
		customer.archetype_id
	):
		if (
			_inventory_service == null
			or not bool(_inventory_service.call(
				"confirm_customer_sale",
				customer.target_sku,
				negotiated
			))
		):
			return false
		last_negotiate_result = NegotiatePolicy.RESULT_SOLD
		_complete(customer, &"sold")
		return true
	if _reputation_hook.is_valid():
		_reputation_hook.call(NegotiatePolicy.miss_rep_delta())
	last_negotiate_result = NegotiatePolicy.RESULT_WALKED
	_complete(customer, &"walked")
	return true


func refuse() -> bool:
	var customer := begin_serving_head()
	if customer == null:
		return false
	if customer.trade_intent == CustomerProfile.TradeIntent.SELLING_TO_SHOP:
		return walk_buylist()
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


func all_customers() -> Array[CustomerProfile]:
	return _customers.duplicate()


static func negotiated_price_cents(
	listed_price_cents: int,
	percent_from_list: float
) -> int:
	var direction := NegotiatePolicy.direction_percent(percent_from_list)
	return maxi(1, roundi(float(listed_price_cents) * (1.0 + direction)))


func _serve_reputation() -> int:
	return _read_game_state_int("current_reputation", 0)


func _serve_day() -> int:
	return _read_game_state_int("current_day", 1)


func _read_game_state_int(property: String, fallback: int) -> int:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return fallback
	var game_state := tree.root.get_node_or_null("GameState")
	if game_state == null:
		return fallback
	return int(game_state.get(property))


func _refresh_buylist_affordability(dto: BuyConfirmSignal) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	var demand := tree.root.get_node_or_null("DemandSignals")
	if demand == null:
		return
	demand.call("refresh_buylist_affordability", dto)


func _complete(customer: CustomerProfile, outcome: StringName) -> void:
	customer.state = (
		CustomerProfile.State.DONE
		if outcome in [&"sold", &"bought"]
		else CustomerProfile.State.LEFT
	)
	_customers.erase(customer)
	customer_finished.emit(customer, outcome)
	queue_changed.emit(_customers.size())
