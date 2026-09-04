class_name CustomerSpawner
extends Node

@export_range(1.0, 300.0, 1.0) var spawn_interval_seconds: float = 12.0

var _timer: Timer
var _queue: CustomerQueue
var _catalog := CustomerArchetypeCatalog.new()
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = GameState.current_day * 10_007
	_queue = CustomerQueue.new()
	_queue.configure(
		InventoryService,
		GameState.adjust_reputation,
		GameState.spend_attention
	)
	_queue.queue_changed.connect(_on_queue_changed)
	add_child(_queue)
	_timer = Timer.new()
	_timer.wait_time = (
		spawn_interval_seconds
		/ maxf(0.01, GameState.balance_config.customer_spawn_mult)
	)
	_timer.timeout.connect(spawn_customer)
	add_child(_timer)
	EventBus.day_phase_changed.connect(_on_phase_changed)
	EventBus.customer_action_requested.connect(_on_customer_action_requested)
	EventBus.scripted_customer_requested.connect(_on_scripted_customer_requested)
	_queue.customer_finished.connect(_on_customer_finished)
	_on_phase_changed(GameState.current_phase)


func _process(delta: float) -> void:
	if GameState.current_phase == GameState.DayPhase.FLOOR:
		_queue.tick_waiting(delta)


func spawn_customer() -> bool:
	if not can_spawn_for_phase(GameState.current_phase):
		return false
	var archetype := _catalog.pick_weighted(
		GameState.current_reputation,
		GameState.balance_config,
		_rng
	)
	if archetype.is_empty():
		return false
	var customer := _profile_from_archetype(archetype)
	EventBus.customer_arrived.emit(customer)
	return _queue.enqueue(customer)


func get_queue() -> CustomerQueue:
	return _queue


func enqueue_scripted_customer(customer: CustomerProfile) -> bool:
	if not can_spawn_for_phase(GameState.current_phase):
		return false
	EventBus.customer_arrived.emit(customer)
	return _queue.enqueue(customer)


static func can_spawn_for_phase(phase: int) -> bool:
	return CustomerSpawnPolicy.can_spawn(phase)


func _profile_from_archetype(archetype: Dictionary) -> CustomerProfile:
	var customer := CustomerProfile.new()
	customer.archetype_id = StringName(archetype.get("id", "regular"))
	customer.display_name = String(archetype.get("display_name", "Shopper"))
	var budget_range: Array = archetype.get("budget_range_cents", [500, 5000])
	customer.budget_cents = _rng.randi_range(
		int(budget_range[0]),
		int(budget_range[1])
	)
	var patience_range: Array = archetype.get(
		"patience_range_seconds",
		[45, 90]
	)
	customer.patience_seconds = _rng.randf_range(
		float(patience_range[0]),
		float(patience_range[1])
	)
	for tag: Variant in archetype.get("interest_tags", []):
		customer.interest_tags.append(StringName(tag))
	if customer.archetype_id == &"flipper":
		customer.trade_intent = CustomerProfile.TradeIntent.SELLING_TO_SHOP
		customer.buylist_signal = _create_buylist_signal(customer.interest_tags)
	return customer


func _create_buylist_signal(
	interest_tags: Array[StringName]
) -> BuyConfirmSignal:
	var candidates: Array[ProductSKU] = []
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku == null or sku.product_class not in [
			ProductSKU.ProductClass.SEALED,
			ProductSKU.ProductClass.ACCESSORY,
		]:
			continue
		var class_tag := StringName(
			ProductSKU.ProductClass.keys()[sku.product_class].to_lower()
		)
		if class_tag in interest_tags:
			candidates.append(sku)
	if candidates.is_empty():
		return null
	var selected := candidates[_rng.randi_range(0, candidates.size() - 1)]
	return DemandSignals.buylist_signal(selected.id)


func _on_phase_changed(phase: int) -> void:
	if can_spawn_for_phase(phase):
		_timer.start()
		spawn_customer()
	else:
		_timer.stop()
		if phase == GameState.DayPhase.SETTLE:
			_queue.clear()


func _on_queue_changed(length: int) -> void:
	EventBus.customer_queue_changed.emit(length)
	EventBus.customer_head_changed.emit(_queue.queue_head())


func _on_customer_action_requested(action: StringName) -> void:
	match action:
		&"sell_listed":
			_queue.sell_listed()
		&"accept_buylist":
			_queue.accept_buylist_offer()
		&"negotiate":
			_queue.negotiate(-0.10)
			EventBus.customer_head_changed.emit(_queue.queue_head())
		&"refuse":
			_queue.refuse()


func _on_scripted_customer_requested(customer: CustomerProfile) -> void:
	enqueue_scripted_customer(customer)


func _on_customer_finished(
	customer: CustomerProfile,
	outcome: StringName
) -> void:
	EventBus.customer_resolved.emit(customer, outcome)
