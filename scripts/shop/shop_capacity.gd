class_name ShopCapacity
extends Resource

const DEFAULT_CONFIG: BalanceConfig = preload("res://data/balance/normal.tres")

@export_range(1, 1_000, 1) var display_slots: int
@export_range(1, 100_000, 1) var storage_units: int


func _init(config: BalanceConfig = DEFAULT_CONFIG) -> void:
	apply_balance_config(config)


func apply_balance_config(config: BalanceConfig) -> void:
	if config == null:
		push_error("BalanceConfig cannot be null.")
		return
	display_slots = config.case_slots
	storage_units = config.backstock_bins


func apply_medium_upgrade() -> void:
	display_slots += ShopState.MEDIUM_CASE_SLOT_BONUS
	storage_units += ShopState.MEDIUM_BACKSTOCK_BONUS


func can_allocate_display(used_slots: int, requested_slots: int) -> bool:
	return used_slots >= 0 and requested_slots > 0 and used_slots + requested_slots <= display_slots


func can_store(used_units: int, requested_units: int) -> bool:
	return used_units >= 0 and requested_units > 0 and used_units + requested_units <= storage_units
