extends Node

const FIRST_DAY := 1
const NORMAL_BALANCE_CONFIG: BalanceConfig = preload("res://data/balance/normal.tres")

var current_day: int = FIRST_DAY
var current_reputation: int = 0
var is_game_active: bool = false
var balance_config: BalanceConfig = NORMAL_BALANCE_CONFIG


func set_balance_config(config: BalanceConfig) -> void:
	if config == null:
		push_error("BalanceConfig cannot be null.")
		return
	balance_config = config


func start_new_game() -> void:
	current_day = FIRST_DAY
	current_reputation = balance_config.start_reputation
	is_game_active = true
	Economy.reset()
	InventoryService.reset()
	EventBus.day_started.emit(current_day)


func advance_day() -> void:
	if not is_game_active:
		return
	current_day += 1
	EventBus.day_started.emit(current_day)


func return_to_menu() -> void:
	is_game_active = false
