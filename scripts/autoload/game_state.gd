extends Node

const FIRST_DAY := 1

var current_day: int = FIRST_DAY
var is_game_active: bool = false


func start_new_game() -> void:
	current_day = FIRST_DAY
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
