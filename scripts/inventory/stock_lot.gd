class_name StockLot
extends Resource

@export var sku: ProductSKU
@export_range(0, 1_000_000, 1) var qty: int = 0
@export_range(0, 100_000_000, 1) var acquired_cost_avg_cents: int = 0
@export_range(0, 100_000_000, 1) var listed_price_cents: int = 0
@export var location: InventoryLocation = InventoryLocation.new()


func unit_cost_cents() -> int:
	return acquired_cost_avg_cents


func total_cost_cents() -> int:
	return acquired_cost_avg_cents * qty


static func accepts_product(product: ProductSKU) -> bool:
	return (
		product != null
		and product.product_class in [
			ProductSKU.ProductClass.SEALED,
			ProductSKU.ProductClass.ACCESSORY,
		]
	)
