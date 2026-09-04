class_name CardInstance
extends Resource

enum Finish {
	NORMAL,
	FOIL,
}

enum Condition {
	NM,
	LP,
	MP,
	HP,
	DMG,
}

@export var sku_id: StringName
@export var finish: Finish = Finish.NORMAL
@export var condition: Condition = Condition.NM
@export_range(0, 100_000_000, 1) var acquired_cost_cents: int = 0
@export_range(0, 100_000_000, 1) var listed_price_cents: int = 0
@export var location: InventoryLocation = InventoryLocation.new()


func _init(
	card_sku_id: StringName = &"",
	card_cost_cents: int = 0,
	card_location: InventoryLocation = null
) -> void:
	sku_id = card_sku_id
	acquired_cost_cents = card_cost_cents
	if card_location != null:
		location = card_location
