extends Control

signal start_requested


func _on_start_button_pressed() -> void:
	start_requested.emit()
