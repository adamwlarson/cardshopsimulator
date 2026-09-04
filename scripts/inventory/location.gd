class_name InventoryLocation
extends Resource

enum Type {
	CASE,
	BINDER,
	SHELF,
	BACKSTOCK,
	ONLINE_HOLD,
}

@export var type: Type = Type.BACKSTOCK
@export var slot_id: int = -1


func _init(location_type: Type = Type.BACKSTOCK, location_slot_id: int = -1) -> void:
	type = location_type
	slot_id = location_slot_id


func duplicate_location() -> InventoryLocation:
	return InventoryLocation.new(type, slot_id)
