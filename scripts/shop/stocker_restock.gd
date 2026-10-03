class_name StockerRestock
extends RefCounted

## AF1: while a Stocker is on duty, haul eligible BACKSTOCK lots onto the
## floor within the daily lot budget. Placement only — does not change
## AC1/AD1/AE1 notice or rank numbers, and does not change sale cash.


func apply(shop: ShopState) -> int:
	if (
		shop == null
		or not shop.has_stocker_on_duty()
		or InventoryService == null
		or InventoryService.model == null
	):
		return 0
	var remaining := shop.stocker_restock_lots_per_day()
	if remaining <= 0:
		return 0
	var moved := 0
	if shop.has_impulse_shelf() and _shelf_is_empty():
		moved += _move_lots(
			ProductSKU.ProductClass.ACCESSORY,
			InventoryLocation.Type.SHELF,
			remaining - moved
		)
	moved += _move_slabs_to_case(remaining - moved)
	moved += _move_cards(InventoryLocation.Type.CASE, remaining - moved)
	moved += _move_lots(
		ProductSKU.ProductClass.ACCESSORY,
		InventoryLocation.Type.SHELF,
		remaining - moved
	)
	moved += _move_lots(
		ProductSKU.ProductClass.SEALED,
		InventoryLocation.Type.SHELF,
		remaining - moved
	)
	moved += _move_cards(InventoryLocation.Type.BINDER, remaining - moved)
	return moved


func _shelf_is_empty() -> bool:
	for lot: StockLot in InventoryService.model.stock_lots:
		if (
			lot != null
			and lot.qty > 0
			and lot.location != null
			and lot.location.type == InventoryLocation.Type.SHELF
		):
			return false
	return true


func _move_lots(
	product_class: ProductSKU.ProductClass,
	destination_type: InventoryLocation.Type,
	budget: int
) -> int:
	if budget <= 0:
		return 0
	var moved := 0
	for lot: StockLot in _backstock_lots(product_class):
		if moved >= budget:
			break
		if lot == null or lot.sku == null or lot.qty <= 0 or lot.location == null:
			continue
		if lot.location.type != InventoryLocation.Type.BACKSTOCK:
			continue
		var destination := InventoryLocation.new(destination_type)
		if InventoryService.move_stock_to(
			lot.sku.id,
			lot.location,
			destination,
			lot.qty
		):
			moved += 1
	return moved


func _move_cards(destination_type: InventoryLocation.Type, budget: int) -> int:
	if budget <= 0:
		return 0
	var moved := 0
	for card: CardInstance in _backstock_cards():
		if moved >= budget:
			break
		if card == null or card.location == null:
			continue
		if card.location.type != InventoryLocation.Type.BACKSTOCK:
			continue
		if InventoryService.move_card_to(
			card,
			InventoryLocation.new(destination_type)
		):
			moved += 1
	return moved


func _move_slabs_to_case(budget: int) -> int:
	if budget <= 0:
		return 0
	var moved := 0
	for slab: SlabInstance in _backstock_slabs():
		if moved >= budget:
			break
		if slab == null or slab.location == null:
			continue
		if slab.location.type != InventoryLocation.Type.BACKSTOCK:
			continue
		if InventoryService.move_slab_to(
			slab,
			InventoryLocation.new(InventoryLocation.Type.CASE)
		):
			moved += 1
	return moved


func _backstock_lots(product_class: ProductSKU.ProductClass) -> Array[StockLot]:
	var lots: Array[StockLot] = []
	for lot: StockLot in InventoryService.model.stock_lots:
		if (
			lot != null
			and lot.qty > 0
			and lot.sku != null
			and lot.sku.product_class == product_class
			and lot.location != null
			and lot.location.type == InventoryLocation.Type.BACKSTOCK
		):
			lots.append(lot)
	return lots


func _backstock_cards() -> Array[CardInstance]:
	var cards: Array[CardInstance] = []
	for card: CardInstance in InventoryService.model.cards:
		if (
			card != null
			and card.location != null
			and card.location.type == InventoryLocation.Type.BACKSTOCK
		):
			cards.append(card)
	return cards


func _backstock_slabs() -> Array[SlabInstance]:
	var slabs: Array[SlabInstance] = []
	for slab: SlabInstance in InventoryService.model.slabs:
		if (
			slab != null
			and slab.location != null
			and slab.location.type == InventoryLocation.Type.BACKSTOCK
		):
			slabs.append(slab)
	return slabs
