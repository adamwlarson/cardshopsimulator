class_name ShopCapacity
extends Resource

@export_range(1, 1_000, 1) var display_slots: int = 12
@export_range(1, 100_000, 1) var storage_units: int = 100


func can_allocate_display(used_slots: int, requested_slots: int) -> bool:
	return used_slots >= 0 and requested_slots > 0 and used_slots + requested_slots <= display_slots


func can_store(used_units: int, requested_units: int) -> bool:
	return used_units >= 0 and requested_units > 0 and used_units + requested_units <= storage_units
