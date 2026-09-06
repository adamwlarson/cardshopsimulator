class_name OnlineListingService
extends RefCounted

var _listings: Array[OnlineListing] = []
var _cancel_days: Array[int] = []
var _next_id: int = 1
var _rng := RandomNumberGenerator.new()


func _init(rng_seed: int = 1) -> void:
	_rng.seed = rng_seed


func reset(rng_seed: int = 1) -> void:
	_listings.clear()
	_cancel_days.clear()
	_next_id = 1
	_rng.seed = rng_seed


func is_unlocked() -> bool:
	var config := _config()
	return (
		GameState.is_game_active
		and GameState.current_reputation >= config.online_unlock_rep
	)


func unlock_rep() -> int:
	return _config().online_unlock_rep


func can_list() -> bool:
	return is_unlocked()


func active_listings() -> Array[OnlineListing]:
	var result: Array[OnlineListing] = []
	for listing: OnlineListing in _listings:
		if listing.is_active():
			result.append(listing)
	return result


func listing_by_id(listing_id: StringName) -> OnlineListing:
	for listing: OnlineListing in _listings:
		if listing.id == listing_id:
			return listing
	return null


static func fee_cents_for(listed_price_cents: int, fee_rate: float) -> int:
	if listed_price_cents <= 0 or fee_rate <= 0.0:
		return 0
	return maxi(1, roundi(float(listed_price_cents) * fee_rate))


func listable_targets() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if InventoryService.model == null:
		return result
	for item: Dictionary in InventoryService.get_priceable_stock():
		var location := item.get("location") as InventoryLocation
		if not InventoryService.is_in_store_sellable(location):
			continue
		result.append(item)
	return result


func list_target(target: Dictionary, listed_price_cents: int, opts: Dictionary = {}) -> Dictionary:
	if not can_list():
		return _result(false, &"locked")
	if target.is_empty() or listed_price_cents <= 0:
		return _result(false, &"invalid")
	var location := target.get("location") as InventoryLocation
	if not InventoryService.is_in_store_sellable(location):
		return _result(false, &"already_held")
	var sku_id := StringName(target.get("sku_id", &""))
	var card := target.get("card") as CardInstance
	var slab := target.get("slab") as SlabInstance
	var kind := _kind_for(target)
	if kind == OnlineListing.Kind.CARD and card == null:
		card = InventoryService.first_in_store_card(sku_id)
	if kind == OnlineListing.Kind.SLAB and slab == null:
		slab = InventoryService.first_in_store_slab(sku_id)
	var hold := InventoryLocation.new(InventoryLocation.Type.ONLINE_HOLD)
	var moved := false
	match kind:
		OnlineListing.Kind.LOT:
			moved = InventoryService.move_stock_to(sku_id, location, hold, 1)
		OnlineListing.Kind.CARD:
			moved = card != null and InventoryService.move_card_to(card, hold)
		OnlineListing.Kind.SLAB:
			moved = slab != null and InventoryService.move_slab_to(slab, hold)
	if not moved:
		return _result(false, &"move_failed")
	var config := _config()
	var listing := OnlineListing.new()
	listing.id = StringName("online-%d" % _next_id)
	_next_id += 1
	listing.kind = kind
	listing.sku_id = sku_id
	listing.display_name = String(target.get("display_name", String(sku_id)))
	listing.quantity = 1
	listing.listed_price_cents = listed_price_cents
	listing.fee_cents = fee_cents_for(listed_price_cents, config.online_fee)
	listing.ship_days = _ship_days_from(opts, config)
	listing.remaining_days = listing.ship_days
	listing.listed_on_day = GameState.current_day
	listing.previous_location = location.duplicate_location() if location != null else null
	listing.card = card
	listing.slab = slab
	listing.status = OnlineListing.Status.ACTIVE
	_listings.append(listing)
	QaInstrumentation.record_online_listed({
		"listing_id": String(listing.id),
		"sku_id": String(sku_id),
		"listed_price_cents": listed_price_cents,
		"fee_cents": listing.fee_cents,
		"ship_days": listing.ship_days,
	})
	return _result(true, &"ok", listing)


func cancel_listing(listing_id: StringName) -> Dictionary:
	var listing := listing_by_id(listing_id)
	if listing == null or not listing.is_active():
		return _result(false, &"not_active")
	if not _restore_held(listing):
		return _result(false, &"restore_failed", listing)
	listing.status = OnlineListing.Status.CANCELLED
	var day := GameState.current_day
	_cancel_days.append(day)
	var cancels := _cancels_in_window(day)
	var frequent := cancels >= _config().online_cancel_frequent_threshold
	var rep_delta := 0
	if frequent:
		rep_delta = -_config().online_cancel_rep_hit
		GameState.adjust_reputation(rep_delta)
		QaInstrumentation.record_online_cancel_rep_hit({
			"listing_id": String(listing.id),
			"sku_id": String(listing.sku_id),
			"cancels_in_window": cancels,
			"window_days": _config().online_cancel_window_days,
			"rep_delta": rep_delta,
			"reputation": GameState.current_reputation,
		})
	QaInstrumentation.record_online_cancelled({
		"listing_id": String(listing.id),
		"sku_id": String(listing.sku_id),
		"frequent": frequent,
		"rep_delta": rep_delta,
		"cancels_in_window": cancels,
	})
	return {
		"ok": true,
		"reason": &"ok",
		"listing": listing,
		"frequent": frequent,
		"rep_delta": rep_delta,
		"cancels_in_window": cancels,
	}


func tick_shipping() -> Array[OnlineListing]:
	var filled: Array[OnlineListing] = []
	for listing: OnlineListing in _listings:
		if not listing.is_active():
			continue
		listing.remaining_days -= 1
		if listing.remaining_days > 0:
			continue
		if _fill_listing(listing):
			filled.append(listing)
	return filled


func _fill_listing(listing: OnlineListing) -> bool:
	if not _remove_held(listing):
		return false
	if listing.listed_price_cents > 0:
		Economy.record_income(
			listing.listed_price_cents,
			&"online_sale",
			"Online sale"
		)
	if listing.fee_cents > 0:
		Economy.record_expense(
			listing.fee_cents,
			&"online_fee",
			"Online listing fee 8%"
		)
	listing.status = OnlineListing.Status.FILLED
	listing.remaining_days = 0
	QaInstrumentation.record_online_filled({
		"listing_id": String(listing.id),
		"sku_id": String(listing.sku_id),
		"listed_price_cents": listing.listed_price_cents,
		"fee_cents": listing.fee_cents,
		"net_cents": listing.net_proceeds_cents(),
	})
	return true


func _restore_held(listing: OnlineListing) -> bool:
	var hold := InventoryLocation.new(InventoryLocation.Type.ONLINE_HOLD)
	var dest := listing.previous_location
	if dest == null:
		dest = _fallback_location(listing)
	if _move_held(listing, hold, dest):
		return true
	var fallback := _fallback_location(listing)
	if fallback != null and dest != null and fallback.type != dest.type:
		return _move_held(listing, hold, fallback)
	return false


func _move_held(
	listing: OnlineListing,
	source: InventoryLocation,
	destination: InventoryLocation
) -> bool:
	if destination == null:
		return false
	match listing.kind:
		OnlineListing.Kind.LOT:
			return InventoryService.move_stock_to(
				listing.sku_id,
				source,
				destination,
				listing.quantity
			)
		OnlineListing.Kind.CARD:
			return listing.card != null and InventoryService.move_card_to(
				listing.card,
				destination
			)
		OnlineListing.Kind.SLAB:
			return listing.slab != null and InventoryService.move_slab_to(
				listing.slab,
				destination
			)
	return false


func _remove_held(listing: OnlineListing) -> bool:
	var hold := InventoryLocation.new(InventoryLocation.Type.ONLINE_HOLD)
	match listing.kind:
		OnlineListing.Kind.LOT:
			return InventoryService.remove_stock_from(
				listing.sku_id,
				hold,
				listing.quantity
			)
		OnlineListing.Kind.CARD:
			return listing.card != null and InventoryService.remove_card(listing.card)
		OnlineListing.Kind.SLAB:
			return listing.slab != null and InventoryService.remove_slab(listing.slab)
	return false


func _fallback_location(listing: OnlineListing) -> InventoryLocation:
	match listing.kind:
		OnlineListing.Kind.LOT:
			return InventoryLocation.new(InventoryLocation.Type.SHELF)
		OnlineListing.Kind.CARD:
			return InventoryLocation.new(InventoryLocation.Type.BINDER)
		OnlineListing.Kind.SLAB:
			return InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	return InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)


func _kind_for(target: Dictionary) -> OnlineListing.Kind:
	if target.get("slab") != null:
		return OnlineListing.Kind.SLAB
	if target.get("card") != null:
		return OnlineListing.Kind.CARD
	var sku := InventoryService.model.get_sku(StringName(target.get("sku_id", &"")))
	if sku != null and sku.product_class == ProductSKU.ProductClass.SINGLE:
		return OnlineListing.Kind.CARD
	if sku != null and sku.product_class == ProductSKU.ProductClass.GRADED:
		return OnlineListing.Kind.SLAB
	return OnlineListing.Kind.LOT


func _ship_days_from(opts: Dictionary, config: BalanceConfig) -> int:
	if opts.has("ship_days"):
		return clampi(
			int(opts.get("ship_days", config.online_ship_days_min)),
			config.online_ship_days_min,
			config.online_ship_days_max
		)
	return _rng.randi_range(config.online_ship_days_min, config.online_ship_days_max)


func _cancels_in_window(day: int) -> int:
	var window := _config().online_cancel_window_days
	var earliest := day - window + 1
	var count := 0
	for cancel_day: int in _cancel_days:
		if cancel_day >= earliest:
			count += 1
	return count


func _config() -> BalanceConfig:
	return GameState.balance_config


func _result(ok: bool, reason: StringName, listing: OnlineListing = null) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"listing": listing,
	}
