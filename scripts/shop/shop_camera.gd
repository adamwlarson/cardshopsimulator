class_name ShopCamera
extends Camera3D

## Eye-height aisle camera for the 10×8 shop (shell origin SW, interior +X / −Z).
## Ceiling is at 2.80 m; keep the eye well below it and look into the floor, not the lights.
const EYE := Vector3(4.5, 1.62, -0.8)
const LOOK_TARGET := Vector3(4.5, 0.72, -4.15)
const FIELD_OF_VIEW := 68.0


func _ready() -> void:
	position = EYE
	look_at(LOOK_TARGET, Vector3.UP)
	fov = FIELD_OF_VIEW
	current = true
