class_name SlabInstance
extends Resource

@export var card_ref: CardInstance
@export var grader: StringName
@export_range(0.0, 10.0, 0.5) var grade: float = 0.0
@export var cert_id: String
@export var cert_valid: bool = true
@export_range(0, 100_000_000, 1) var acquired_cost_cents: int = 0
@export_range(0, 100_000_000, 1) var listed_price_cents: int = 0
@export var location: InventoryLocation = InventoryLocation.new()


func _init(
	slab_card: CardInstance = null,
	slab_grader: StringName = &"",
	slab_grade: float = 0.0,
	slab_cert_id: String = "",
	slab_cost_cents: int = 0,
	slab_location: InventoryLocation = null
) -> void:
	card_ref = slab_card
	grader = slab_grader
	grade = slab_grade
	cert_id = slab_cert_id
	acquired_cost_cents = slab_cost_cents
	if slab_location != null:
		location = slab_location
