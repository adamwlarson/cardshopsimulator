class_name ProductSKU
extends Resource

enum ProductClass {
	SEALED,
	SINGLE,
	GRADED,
	ACCESSORY,
}

@export var id: StringName
@export var product_class: ProductClass = ProductClass.SEALED
@export var display_name: String
@export var set_id: StringName
@export_range(0, 100_000_000, 1) var msrp_cents: int = 0
@export_range(0, 100_000_000, 1) var base_market_cents: int = 0
@export var tags: Array[StringName] = []


func _init(
	sku_id: StringName = &"",
	sku_class: ProductClass = ProductClass.SEALED,
	sku_name: String = "",
	market_cents: int = 0,
	sku_set_id: StringName = &"",
	sku_tags: Array[StringName] = []
) -> void:
	id = sku_id
	product_class = sku_class
	display_name = sku_name
	base_market_cents = market_cents
	set_id = sku_set_id
	tags = sku_tags
