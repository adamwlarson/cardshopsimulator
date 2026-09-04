extends Node

var model: InventoryModel


func _ready() -> void:
	reset()


func reset() -> void:
	model = InventoryModel.new(GameState.balance_config)
	model.reset_and_seed()
	for lot: StockLot in model.stock_lots:
		EventBus.publish_inventory_changed(lot.sku.id, lot.qty)


func receive_stock(
	sku_id: StringName,
	quantity: int,
	unit_cost_cents: int,
	location: InventoryLocation
) -> bool:
	var received := model.add_stock(sku_id, quantity, unit_cost_cents, location)
	if received:
		EventBus.publish_inventory_changed(sku_id, model.get_stock_quantity(sku_id))
	return received


func confirm_stock_purchase(
	sku_id: StringName,
	quantity: int,
	unit_cost_cents: int,
	expected_margin_cents: int,
	location: InventoryLocation
) -> bool:
	var total_cost_cents := quantity * unit_cost_cents
	if quantity <= 0 or unit_cost_cents <= 0 or not Economy.can_afford(total_cost_cents):
		return false
	if not receive_stock(sku_id, quantity, unit_cost_cents, location):
		return false
	if not Economy.record_expense(total_cost_cents, &"inventory", "Stock purchase"):
		remove_stock(sku_id, quantity)
		return false
	QaInstrumentation.record_buy_confirm(
		sku_id,
		quantity,
		unit_cost_cents,
		expected_margin_cents
	)
	return true


func remove_stock(sku_id: StringName, quantity: int) -> bool:
	var removed := model.remove_stock(sku_id, quantity)
	if removed:
		EventBus.publish_inventory_changed(sku_id, model.get_stock_quantity(sku_id))
	return removed


func has_stock(sku_id: StringName, quantity: int = 1) -> bool:
	return quantity > 0 and model.get_stock_quantity(sku_id) >= quantity


func get_lot(sku_id: StringName) -> StockLot:
	for lot: StockLot in model.stock_lots:
		if lot.sku.id == sku_id:
			return lot
	return null


func get_lots(sku_id: StringName) -> Array[StockLot]:
	var result: Array[StockLot] = []
	for lot: StockLot in model.stock_lots:
		if lot.sku.id == sku_id:
			result.append(lot)
	return result


func get_all_stock() -> Array[StockLot]:
	return model.stock_lots.duplicate()
