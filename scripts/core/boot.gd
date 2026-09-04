extends Node

const MAIN_MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")


func _ready() -> void:
	var menu := MAIN_MENU_SCENE.instantiate()
	menu.start_requested.connect(_enter_shop)
	add_child(menu)


func _enter_shop() -> void:
	GameState.start_new_game()
	var error := get_tree().change_scene_to_file("res://scenes/shop/shop_floor.tscn")
	if error != OK:
		push_error("Could not open the shop scene: %s" % error_string(error))
