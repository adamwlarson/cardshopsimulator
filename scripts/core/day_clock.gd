class_name DayClock
extends Node

signal time_changed(progress: float)

@export_range(10.0, 3600.0, 1.0) var day_length_seconds: float = 180.0
@export var paused: bool = false

var elapsed_seconds: float = 0.0


func _process(delta: float) -> void:
	if paused or not GameState.is_game_active:
		return

	elapsed_seconds += delta
	time_changed.emit(clampf(elapsed_seconds / day_length_seconds, 0.0, 1.0))
	if elapsed_seconds >= day_length_seconds:
		elapsed_seconds = 0.0
		GameState.advance_day()


func set_paused(value: bool) -> void:
	paused = value


func skip_to_next_day() -> void:
	# TODO: Gate this behind shop-closing checks and unresolved decisions.
	elapsed_seconds = 0.0
	GameState.advance_day()
