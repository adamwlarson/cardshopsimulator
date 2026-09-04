extends Node

var _stock_by_sku: Dictionary = {}


func reset() -> void:
	_stock_by_sku.clear()


func receive_stock(
	sku: StringName,
	display_name: String,
	product_type: StockLot.ProductType,
	condition: StockLot.Condition,
	quantity: int,
	total_cost_cents: int
) -> bool:
	if sku.is_empty() or quantity <= 0 or total_cost_cents < 0:
		return false

	var lot := get_lot(sku)
	if lot == null:
		lot = StockLot.new()
		lot.sku = sku
		lot.display_name = display_name
		lot.product_type = product_type
		lot.condition = condition
		_stock_by_sku[sku] = lot
	elif lot.product_type != product_type or lot.condition != condition:
		# TODO: Support multiple condition-specific lots under one catalog product.
		return false

	lot.quantity += quantity
	lot.cost_basis_cents += total_cost_cents
	EventBus.publish_inventory_changed(sku, lot.quantity)
	return true


func remove_stock(sku: StringName, quantity: int) -> bool:
	var lot := get_lot(sku)
	if lot == null or quantity <= 0 or lot.quantity < quantity:
		return false

	var removed_cost := lot.unit_cost_cents() * quantity
	lot.quantity -= quantity
	lot.cost_basis_cents = maxi(0, lot.cost_basis_cents - removed_cost)
	EventBus.publish_inventory_changed(sku, lot.quantity)
	return true


func has_stock(sku: StringName, quantity: int = 1) -> bool:
	var lot := get_lot(sku)
	return lot != null and quantity > 0 and lot.quantity >= quantity


func get_lot(sku: StringName) -> StockLot:
	return _stock_by_sku.get(sku) as StockLot


func get_all_stock() -> Array[StockLot]:
	var result: Array[StockLot] = []
	for value: Variant in _stock_by_sku.values():
		var lot := value as StockLot
		if lot != null:
			result.append(lot)
	return result
