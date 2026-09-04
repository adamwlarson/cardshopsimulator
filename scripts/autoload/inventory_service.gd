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


func receive_card(
	sku_id: StringName,
	acquired_cost_cents: int,
	location: InventoryLocation,
	listed_price_cents: int = 0
) -> CardInstance:
	var sku := model.get_sku(sku_id)
	if sku == null or sku.product_class != ProductSKU.ProductClass.SINGLE:
		return null
	var card := CardInstance.new(sku_id, acquired_cost_cents, location)
	card.condition = CardInstance.Condition.NM
	card.listed_price_cents = (
		listed_price_cents if listed_price_cents > 0 else sku.base_market_cents
	)
	if not model.add_card(card):
		return null
	EventBus.publish_inventory_changed(sku_id, total_owned(sku_id))
	return card


func receive_slab(
	sku_id: StringName,
	grader: StringName,
	grade: float,
	acquired_cost_cents: int,
	location: InventoryLocation
) -> SlabInstance:
	var sku := model.get_sku(sku_id)
	if sku == null or sku.product_class != ProductSKU.ProductClass.SINGLE:
		return null
	var card := CardInstance.new(sku_id, acquired_cost_cents)
	card.condition = CardInstance.Condition.NM
	card.listed_price_cents = sku.base_market_cents
	var slab := SlabInstance.new(
		card,
		grader,
		grade,
		"BEAT-%s-%d" % [sku_id, model.slabs.size() + 1],
		acquired_cost_cents,
		location
	)
	slab.listed_price_cents = sku.base_market_cents
	if not model.add_slab(slab):
		return null
	EventBus.publish_inventory_changed(sku_id, total_owned(sku_id))
	return slab


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


func get_card(
	sku_id: StringName,
	condition: CardInstance.Condition = CardInstance.Condition.NM
) -> CardInstance:
	for card: CardInstance in model.cards:
		if card.sku_id == sku_id and card.condition == condition:
			return card
	return null


func get_cards(
	sku_id: StringName,
	condition: CardInstance.Condition = CardInstance.Condition.NM
) -> Array[CardInstance]:
	var result: Array[CardInstance] = []
	for card: CardInstance in model.cards:
		if card.sku_id == sku_id and card.condition == condition:
			result.append(card)
	return result


func displayable_card_count(sku_id: StringName) -> int:
	var count := 0
	for card: CardInstance in get_cards(sku_id):
		if card.location.type in [
			InventoryLocation.Type.CASE,
			InventoryLocation.Type.BINDER,
		]:
			count += 1
	return count


func get_slab(sku_id: StringName) -> SlabInstance:
	for slab: SlabInstance in model.slabs:
		if slab.card_ref != null and slab.card_ref.sku_id == sku_id:
			return slab
	return null


func card_count(
	sku_id: StringName,
	condition: CardInstance.Condition = CardInstance.Condition.NM
) -> int:
	var count := 0
	for card: CardInstance in model.cards:
		if card.sku_id == sku_id and card.condition == condition:
			count += 1
	return count


func total_owned(sku_id: StringName) -> int:
	var total := model.get_stock_quantity(sku_id)
	for card: CardInstance in model.cards:
		if card.sku_id == sku_id:
			total += 1
	for slab: SlabInstance in model.slabs:
		if slab.card_ref != null and slab.card_ref.sku_id == sku_id:
			total += 1
	return total


func case_free_slot_weight() -> int:
	return model.case_slot_limit() - model.case_slots_used()


func backstock_free_bins() -> int:
	return model.backstock_bin_limit() - model.backstock_bins_used()


func apply_medium_capacity(case_bonus: int, backstock_bonus: int) -> void:
	model.case_slot_bonus = maxi(0, case_bonus)
	model.backstock_bin_bonus = maxi(0, backstock_bonus)


func move_card_to(card: CardInstance, destination: InventoryLocation) -> bool:
	if not model.move_card(card, destination):
		return false
	EventBus.publish_inventory_changed(card.sku_id, total_owned(card.sku_id))
	return true


func move_slab_to(slab: SlabInstance, destination: InventoryLocation) -> bool:
	if not model.move_slab(slab, destination):
		return false
	EventBus.publish_inventory_changed(slab.card_ref.sku_id, total_owned(slab.card_ref.sku_id))
	return true


func get_priceable_stock() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for lot: StockLot in model.stock_lots:
		if lot.qty <= 0:
			continue
		result.append({
			"sku_id": lot.sku.id,
			"display_name": lot.sku.display_name,
			"quantity": lot.qty,
			"listed_price_cents": lot.listed_price_cents,
			"location": lot.location,
		})
	for card: CardInstance in model.cards:
		var sku := model.get_sku(card.sku_id)
		if sku == null:
			continue
		result.append({
			"sku_id": card.sku_id,
			"display_name": sku.display_name,
			"quantity": 1,
			"listed_price_cents": card.listed_price_cents,
			"location": card.location,
		})
	for slab: SlabInstance in model.slabs:
		if slab.card_ref == null:
			continue
		var sku := model.get_sku(slab.card_ref.sku_id)
		if sku == null:
			continue
		result.append({
			"sku_id": slab.card_ref.sku_id,
			"display_name": "%s (%s %.1f)" % [
				sku.display_name, slab.grader, slab.grade,
			],
			"quantity": 1,
			"listed_price_cents": slab.listed_price_cents,
			"location": slab.location,
		})
	return result


func find_listed_sku_offer(sku_id: StringName, budget_cents: int) -> Dictionary:
	for card: CardInstance in model.cards:
		if (
			card.sku_id == sku_id
			and card.listed_price_cents > 0
			and card.listed_price_cents <= budget_cents
			and card.location.type in [
				InventoryLocation.Type.CASE,
				InventoryLocation.Type.BINDER,
			]
		):
			return _offer_for(
				model.get_sku(card.sku_id),
				card.listed_price_cents,
				card.location
			)
	return {}


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
	for slab: SlabInstance in model.slabs:
		if slab.card_ref != null and slab.card_ref.sku_id == sku_id:
			return slab.location
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
