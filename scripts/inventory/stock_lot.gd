class_name StockLot
extends Resource

enum ProductType {
	SEALED,
	SINGLE,
	GRADED,
	ACCESSORY,
}

enum Condition {
	SEALED,
	MINT,
	NEAR_MINT,
	PLAYED,
	DAMAGED,
}

@export var sku: StringName
@export var display_name: String
@export var product_type: ProductType = ProductType.SEALED
@export var condition: Condition = Condition.SEALED
@export_range(0, 1_000_000, 1) var quantity: int = 0
@export_range(0, 100_000_000, 1) var cost_basis_cents: int = 0


func unit_cost_cents() -> int:
	if quantity <= 0:
		return 0
	return cost_basis_cents / quantity
