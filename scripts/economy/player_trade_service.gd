class_name PlayerTradeService
extends RefCounted

var _closed_for_day: int = -1
var _rolled_day: int = -1
var _unlock_rep: int = PlayerTradePolicy.UNLOCK_REP


func reset() -> void:
	_closed_for_day = -1
	_rolled_day = -1
	_unlock_rep = PlayerTradePolicy.UNLOCK_REP


func configure(unlock_rep: int) -> void:
	_unlock_rep = unlock_rep


func unlock_rep() -> int:
	return PlayerTradePolicy.unlock_rep(_unlock_rep)


func closed_for_day() -> int:
	return _closed_for_day


func apply_closed_day_save(value: Variant) -> void:
	_closed_for_day = PlayerTradePolicy.closed_day_from_save(value)


func expire_open(day: int) -> void:
	_sync_day(day)
	_closed_for_day = day


func roll_open(seed: int, reputation: int, day: int) -> PlayerTradeOffer:
	_sync_day(day)
	if _closed_for_day == day:
		return null
	if not PlayerTradePolicy.can_offer(reputation, _unlock_rep):
		return null
	var offer := seeded_offer(seed, day)
	if offer == null or not offer.is_valid():
		return null
	if not _owns_give_lot(offer):
		return null
	return offer


func seeded_offer(seed: int, day: int = 1) -> PlayerTradeOffer:
	var catalog := {}
	if InventoryService.model != null:
		catalog = InventoryService.model.catalog
	var pair := PlayerTradePolicy.pick_pair(
		seed,
		day,
		_give_pool(catalog),
		PlayerTradePolicy.pool_sku_ids(catalog)
	)
	if pair.is_empty():
		return null
	return _offer_from_pair(
		day,
		pair.get("give_sku_id", &"") as StringName,
		pair.get("receive_sku_id", &"") as StringName
	)


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
	var give_sku := _sku_of(offer.give_sku_id)
	if give_sku != null and give_sku.product_class == ProductSKU.ProductClass.SINGLE:
		if not _accept_single_give(offer):
			return false
		_closed_for_day = day
		return true
	var give_lot := InventoryService.get_lot(offer.give_sku_id)
	var unit_cost := give_lot.unit_cost_cents() if give_lot != null else 0
	if not InventoryService.remove_stock(offer.give_sku_id, offer.give_qty):
		return false
	if not _receive_trade_lot(offer, unit_cost):
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


func _accept_single_give(offer: PlayerTradeOffer) -> bool:
	var give_card := InventoryService.first_in_store_card(offer.give_sku_id)
	if give_card == null:
		return false
	var unit_cost := give_card.acquired_cost_cents
	var listed := give_card.listed_price_cents
	var restore_at := (
		give_card.location.duplicate_location()
		if give_card.location != null
		else InventoryLocation.new(InventoryLocation.Type.BINDER)
	)
	if not InventoryService.remove_card(give_card):
		return false
	if _receive_trade_lot(offer, unit_cost):
		return true
	InventoryService.receive_card(offer.give_sku_id, unit_cost, restore_at, listed)
	return false


func _receive_trade_lot(offer: PlayerTradeOffer, unit_cost: int) -> bool:
	var destination := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	var receive_sku := _sku_of(offer.receive_sku_id)
	if receive_sku != null and receive_sku.product_class == ProductSKU.ProductClass.SINGLE:
		return InventoryService.receive_card(
			offer.receive_sku_id,
			unit_cost,
			destination
		) != null
	return InventoryService.receive_stock(
		offer.receive_sku_id,
		offer.receive_qty,
		unit_cost,
		destination
	)


func _sync_day(day: int) -> void:
	if _rolled_day == day:
		return
	_rolled_day = day
	if _closed_for_day != day:
		_closed_for_day = -1


func _owns_give_lot(offer: PlayerTradeOffer) -> bool:
	return _owned_give_qty(offer.give_sku_id) >= offer.give_qty


func _can_receive_in_backstock(offer: PlayerTradeOffer) -> bool:
	var destination := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	var receive_sku := _sku_of(offer.receive_sku_id)
	if receive_sku == null or receive_sku.product_class != ProductSKU.ProductClass.SINGLE:
		for lot: StockLot in InventoryService.get_lots(offer.receive_sku_id):
			if lot != null and lot.location != null and lot.location.type == destination.type:
				return true
	return InventoryService.backstock_free_bins() >= 1


func _give_pool(catalog: Dictionary) -> Array[StringName]:
	var ids: Array[StringName] = []
	for sku_id: StringName in PlayerTradePolicy.pool_sku_ids(catalog):
		if _owned_give_qty(sku_id) >= PlayerTradePolicy.GIVE_QTY:
			ids.append(sku_id)
	return ids


func _owned_give_qty(sku_id: StringName) -> int:
	var sku := _sku_of(sku_id)
	if sku == null or not PlayerTradePolicy.is_trade_sku(sku):
		return 0
	if sku.product_class == ProductSKU.ProductClass.SEALED:
		var qty := 0
		for lot: StockLot in InventoryService.get_lots(sku_id):
			if lot == null or lot.qty <= 0:
				continue
			if not InventoryService.is_in_store_sellable(lot.location):
				continue
			qty += lot.qty
		return qty
	var count := 0
	if InventoryService.model == null:
		return 0
	for card: CardInstance in InventoryService.model.cards:
		if card == null or card.sku_id != sku_id:
			continue
		if InventoryService.is_in_store_sellable(card.location):
			count += 1
	return count


func _offer_from_pair(
	day: int,
	give_sku_id: StringName,
	receive_sku_id: StringName
) -> PlayerTradeOffer:
	if give_sku_id.is_empty() or receive_sku_id.is_empty():
		return null
	var offer := PlayerTradeOffer.new()
	offer.id = PlayerTradePolicy.offer_id(day)
	offer.offer_label = PlayerTradePolicy.OFFER_LABEL
	offer.give_sku_id = give_sku_id
	offer.give_qty = PlayerTradePolicy.GIVE_QTY
	offer.give_condition = _condition_for(give_sku_id, true)
	offer.receive_sku_id = receive_sku_id
	offer.receive_qty = PlayerTradePolicy.RECEIVE_QTY
	offer.receive_condition = _condition_for(receive_sku_id, false)
	offer.counterparty_label = PlayerTradePolicy.COUNTERPARTY
	_fill_display_names(offer)
	return offer


func _condition_for(sku_id: StringName, is_give: bool) -> String:
	var sku := _sku_of(sku_id)
	var card: CardInstance = null
	if is_give and sku != null and sku.product_class == ProductSKU.ProductClass.SINGLE:
		card = InventoryService.first_in_store_card(sku_id)
	return PlayerTradePolicy.condition_for(sku, card)


func _sku_of(sku_id: StringName) -> ProductSKU:
	if InventoryService.model == null:
		return null
	return InventoryService.model.get_sku(sku_id)


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
