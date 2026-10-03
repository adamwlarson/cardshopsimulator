class_name PlayerTradeService
extends RefCounted

var _closed_for_day: int = -1
var _rolled_day: int = -1


func reset() -> void:
	_closed_for_day = -1
	_rolled_day = -1


func roll_open(seed: int, reputation: int, day: int) -> PlayerTradeOffer:
	_sync_day(day)
	if _closed_for_day == day:
		return null
	if not PlayerTradePolicy.can_offer(reputation):
		return null
	var offer := seeded_offer(seed)
	if offer == null or not offer.is_valid():
		return null
	if not _owns_give_lot(offer):
		return null
	return offer


func seeded_offer(_seed: int) -> PlayerTradeOffer:
	var offer := PlayerTradeOffer.new()
	offer.id = PlayerTradePolicy.SEEDED_OFFER_ID
	offer.give_sku_id = PlayerTradePolicy.SEEDED_GIVE_SKU
	offer.give_qty = PlayerTradePolicy.SEEDED_GIVE_QTY
	offer.give_condition = PlayerTradePolicy.SEEDED_CONDITION
	offer.receive_sku_id = PlayerTradePolicy.SEEDED_RECEIVE_SKU
	offer.receive_qty = PlayerTradePolicy.SEEDED_RECEIVE_QTY
	offer.receive_condition = PlayerTradePolicy.SEEDED_CONDITION
	offer.counterparty_label = PlayerTradePolicy.SEEDED_COUNTERPARTY
	_fill_display_names(offer)
	return offer


func can_accept(offer: PlayerTradeOffer) -> bool:
	if offer == null or not offer.is_valid():
		return false
	if not _owns_give_lot(offer):
		return false
	return _can_receive_in_backstock(offer)


func accept(offer: PlayerTradeOffer, day: int) -> bool:
	_sync_day(day)
	if _closed_for_day == day:
		return false
	if not can_accept(offer):
		return false
	var give_lot := InventoryService.get_lot(offer.give_sku_id)
	var unit_cost := give_lot.unit_cost_cents() if give_lot != null else 0
	if not InventoryService.remove_stock(offer.give_sku_id, offer.give_qty):
		return false
	var received := InventoryService.receive_stock(
		offer.receive_sku_id,
		offer.receive_qty,
		unit_cost,
		InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	)
	if not received:
		InventoryService.receive_stock(
			offer.give_sku_id,
			offer.give_qty,
			unit_cost,
			InventoryLocation.new(InventoryLocation.Type.SHELF)
		)
		return false
	_closed_for_day = day
	return true


func decline(offer: PlayerTradeOffer, day: int) -> bool:
	_sync_day(day)
	if offer == null or not offer.is_valid():
		return false
	if _closed_for_day == day:
		return false
	_closed_for_day = day
	return true


func _sync_day(day: int) -> void:
	if _rolled_day == day:
		return
	_rolled_day = day
	if _closed_for_day != day:
		_closed_for_day = -1


func _owns_give_lot(offer: PlayerTradeOffer) -> bool:
	return InventoryService.has_stock(offer.give_sku_id, offer.give_qty)


func _can_receive_in_backstock(offer: PlayerTradeOffer) -> bool:
	var destination := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	for lot: StockLot in InventoryService.get_lots(offer.receive_sku_id):
		if lot != null and lot.location != null and lot.location.type == destination.type:
			return true
	return InventoryService.backstock_free_bins() >= 1


func _fill_display_names(offer: PlayerTradeOffer) -> void:
	if InventoryService.model == null:
		offer.give_display_name = String(offer.give_sku_id)
		offer.receive_display_name = String(offer.receive_sku_id)
		return
	var give_sku := InventoryService.model.get_sku(offer.give_sku_id)
	var receive_sku := InventoryService.model.get_sku(offer.receive_sku_id)
	offer.give_display_name = (
		give_sku.display_name if give_sku != null else String(offer.give_sku_id)
	)
	offer.receive_display_name = (
		receive_sku.display_name if receive_sku != null else String(offer.receive_sku_id)
	)
