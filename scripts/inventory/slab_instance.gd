class_name SlabInstance
extends Resource

@export var card_ref: CardInstance
@export var grader: StringName
@export_range(0.0, 10.0, 0.5) var grade: float = 0.0
@export var cert_id: String
@export var cert_valid: bool = true
@export var inspected: bool = false
@export var source_channel: StringName = &""
@export var shown_cert_cue: String = "Slab — inspect recommended"
@export_range(0, 100_000_000, 1) var acquired_cost_cents: int = 0
@export_range(0, 100_000_000, 1) var listed_price_cents: int = 0
@export var location: InventoryLocation = InventoryLocation.new()

const CERT_FOG_CUE := "Slab — inspect recommended"
const CERT_CLEAN_CUE := "Hologram looks clean"
const CERT_OFF_CUE := "Hologram looks off"


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
	shown_cert_cue = CERT_FOG_CUE
	if slab_location != null:
		location = slab_location


func sku_id() -> StringName:
	if card_ref == null:
		return &""
	return card_ref.sku_id


func apply_inspect_cue(revealed_valid: bool) -> void:
	inspected = true
	shown_cert_cue = CERT_CLEAN_CUE if revealed_valid else CERT_OFF_CUE


static func cue_for_revealed(revealed_valid: bool) -> String:
	return CERT_CLEAN_CUE if revealed_valid else CERT_OFF_CUE
