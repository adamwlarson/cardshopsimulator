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


func find_listed_offer(
	interest_tags: Array[StringName],
	budget_cents: int
) -> Dictionary:
	for lot: StockLot in model.stock_lots:
		if (
			lot.qty > 0
			and lot.listed_price_cents > 0
			and lot.listed_price_cents <= budget_cents
			and _matches_interest(lot.sku, interest_tags)
		):
			return _offer_for(
				lot.sku,
				lot.listed_price_cents,
				lot.location
			)
	for card: CardInstance in model.cards:
		var sku := model.get_sku(card.sku_id)
		if (
			card.listed_price_cents > 0
			and card.listed_price_cents <= budget_cents
			and _matches_interest(sku, interest_tags)
		):
			return _offer_for(sku, card.listed_price_cents, card.location)
	return {}


func confirm_customer_sale(sku_id: StringName, sale_price_cents: int) -> bool:
	if sale_price_cents <= 0:
		return false
	for card: CardInstance in model.cards:
		if card.sku_id == sku_id and card.listed_price_cents > 0:
			if not model.remove_card(card):
				return false
			Economy.record_income(sale_price_cents, &"customer_sale", "Customer sale")
			EventBus.publish_inventory_changed(sku_id, _total_quantity(sku_id))
			return true
	if not remove_stock(sku_id, 1):
		return false
	Economy.record_income(sale_price_cents, &"customer_sale", "Customer sale")
	return true


func set_listed_price(sku_id: StringName, listed_price_cents: int) -> bool:
	if listed_price_cents <= 0:
		return false
	var lot := get_lot(sku_id)
	if lot != null:
		lot.listed_price_cents = listed_price_cents
		return true
	for card: CardInstance in model.cards:
		if card.sku_id == sku_id:
			card.listed_price_cents = listed_price_cents
			return true
	return false


func listed_price_for(sku_id: StringName) -> int:
	var lot := get_lot(sku_id)
	if lot != null:
		return lot.listed_price_cents
	for card: CardInstance in model.cards:
		if card.sku_id == sku_id:
			return card.listed_price_cents
	return 0


func location_for(sku_id: StringName) -> InventoryLocation:
	var lot := get_lot(sku_id)
	if lot != null:
		return lot.location
	for card: CardInstance in model.cards:
		if card.sku_id == sku_id:
			return card.location
	return null


func _matches_interest(
	sku: ProductSKU,
	interest_tags: Array[StringName]
) -> bool:
	if sku == null:
		return false
	var class_tag := StringName(ProductSKU.ProductClass.keys()[sku.product_class].to_lower())
	if class_tag in interest_tags:
		return true
	for tag: StringName in sku.tags:
		if tag in interest_tags:
			return true
	return false


func _offer_for(
	sku: ProductSKU,
	listed_price_cents: int,
	location: InventoryLocation
) -> Dictionary:
	return {
		"sku_id": sku.id,
		"display_name": sku.display_name,
		"listed_price_cents": listed_price_cents,
		"location": location,
	}


func _total_quantity(sku_id: StringName) -> int:
	var total := model.get_stock_quantity(sku_id)
	for card: CardInstance in model.cards:
		if card.sku_id == sku_id:
			total += 1
	return total
