class_name DayClock
extends Node

signal time_changed(progress: float)

@export_range(10.0, 3600.0, 1.0) var day_length_seconds: float = 180.0
@export var paused: bool = false

var elapsed_seconds: float = 0.0


func _ready() -> void:
	EventBus.day_phase_changed.connect(_on_phase_changed)


func _process(delta: float) -> void:
	if (
		paused
		or not GameState.is_game_active
		or GameState.current_phase != GameState.DayPhase.FLOOR
	):
		return

	elapsed_seconds += delta
	time_changed.emit(clampf(elapsed_seconds / day_length_seconds, 0.0, 1.0))
	if elapsed_seconds >= day_length_seconds:
		elapsed_seconds = 0.0
		GameState.start_settle()


func set_paused(value: bool) -> void:
	paused = value


func finish_floor() -> bool:
	if GameState.current_phase != GameState.DayPhase.FLOOR:
		return false
	elapsed_seconds = 0.0
	return GameState.start_settle()


func _on_phase_changed(phase: int) -> void:
	if phase != GameState.DayPhase.FLOOR:
		elapsed_seconds = 0.0
		time_changed.emit(0.0)
