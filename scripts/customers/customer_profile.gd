class_name CustomerProfile
extends Resource

@export var display_name: String = "Shopper"
@export var desired_skus: Array[StringName] = []
@export_range(0, 1_000_000, 1) var budget_cents: int = 5_000
@export_range(0.0, 1.0, 0.01) var patience: float = 0.5


func find_desired_stock() -> StockLot:
	for sku: StringName in desired_skus:
		var lot := InventoryService.get_lot(sku)
		if lot != null and lot.qty > 0:
			return lot
	return null


func matches_offer(sku: StringName, asking_price_cents: int) -> bool:
	return (
		sku in desired_skus
		and asking_price_cents > 0
		and asking_price_cents <= budget_cents
		and InventoryService.has_stock(sku)
	)
