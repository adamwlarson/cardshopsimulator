class_name CustomerSpawner
extends Node

@export_range(1.0, 300.0, 1.0) var spawn_interval_seconds: float = 30.0

var _timer: Timer


func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = spawn_interval_seconds / GameState.balance_config.customer_spawn_mult
	_timer.timeout.connect(_spawn_customer_stub)
	add_child(_timer)
	_timer.start()


func _spawn_customer_stub() -> void:
	var customer := CustomerProfile.new()
	customer.display_name = "Window Shopper"
	customer.desired_skus = [&"AA-SKIE-ETB"]

	# TODO: Load weighted customer archetypes and physically navigate an NPC into the shop.
	EventBus.customer_arrived.emit(customer)
