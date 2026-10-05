class_name OnlineListingService
extends RefCounted

var _listings: Array[OnlineListing] = []
var _cancel_day: int = 0
var _cancels_today: int = 0
var _next_id: int = 1
var _rng := RandomNumberGenerator.new()


func _init(rng_seed: int = 1) -> void:
	_rng.seed = rng_seed


func reset(rng_seed: int = 1) -> void:
	_listings.clear()
	_cancel_day = 0
	_cancels_today = 0
	_next_id = 1
	_rng.seed = rng_seed


func cancel_day() -> int:
	return _cancel_day


func cancels_today() -> int:
	return _cancels_today


func cancel_day_to_save() -> Dictionary:
	return OnlineCancelPolicy.snapshot(_cancel_day, _cancels_today)


func apply_cancel_day_save(data: Dictionary) -> void:
	_cancel_day = OnlineCancelPolicy.cancel_day_from_save(data)
	_cancels_today = OnlineCancelPolicy.cancels_today_from_save(data)


func listings_to_save() -> Dictionary:
	return OnlineListingSavePolicy.snapshot(_next_id, active_listings())


func apply_listings_save(data: Dictionary) -> void:
	_listings.clear()
	if data.is_empty():
		_next_id = 1
		return
	_next_id = OnlineListingSavePolicy.next_id_from_save(data)
	for row: Dictionary in OnlineListingSavePolicy.listing_rows_from_save(data):
		var listing := OnlineListingSavePolicy.listing_from_save(row)
		if listing == null or not listing.is_active() or listing.remaining_days <= 0:
			continue
		if not _restore_held_membership(listing, row):
			continue
		if String(listing.id).is_empty():
			listing.id = StringName("online-%d" % _next_id)
			_next_id += 1
		_listings.append(listing)
		_advance_next_id_past(listing.id)


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


func concurrent_hold_count() -> int:
	return active_listings().size()


func hold_cap(reputation: int = -1) -> int:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return OnlineHoldCapPolicy.cap_for_config(resolved, _config())


func is_at_hold_cap() -> bool:
	return OnlineHoldCapPolicy.is_at_cap(
		concurrent_hold_count(),
		hold_cap(),
		is_unlocked()
	)


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
	if concurrent_hold_count() >= hold_cap():
		return _hold_cap_result()
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
	listing.fee_cents = fee_cents_for(listed_price_cents, _fee_rate(config))
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
	var config := _config()
	var cancels_today := _note_cancel(GameState.current_day)
	var free_count := OnlineCancelPolicy.free_per_day_for(config)
	var frequent := OnlineCancelPolicy.is_frequent(cancels_today, free_count)
	var rep_delta := 0
	if frequent:
		rep_delta = OnlineCancelPolicy.rep_delta_for(config)
		GameState.adjust_reputation(rep_delta)
		QaInstrumentation.record_online_cancel_rep_hit({
			"listing_id": String(listing.id),
			"sku_id": String(listing.sku_id),
			"cancels_today": cancels_today,
			"free_per_day": free_count,
			"rep_delta": rep_delta,
			"reputation": GameState.current_reputation,
		})
	QaInstrumentation.record_online_cancelled({
		"listing_id": String(listing.id),
		"sku_id": String(listing.sku_id),
		"frequent": frequent,
		"rep_delta": rep_delta,
		"cancels_today": cancels_today,
		"free_per_day": free_count,
	})
	return {
		"ok": true,
		"reason": &"ok",
		"listing": listing,
		"frequent": frequent,
		"rep_delta": rep_delta,
		"cancels_today": cancels_today,
		"free_per_day": free_count,
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
	var rate := _fee_rate()
	listing.fee_cents = fee_cents_for(listing.listed_price_cents, rate)
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
			"Online listing fee %d%%" % roundi(rate * 100.0)
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


func _restore_held_membership(listing: OnlineListing, row: Dictionary) -> bool:
	var hold := InventoryLocation.new(InventoryLocation.Type.ONLINE_HOLD)
	var cost := OnlineListingSavePolicy.acquired_cost_from_save(row)
	var ask := listing.listed_price_cents
	match listing.kind:
		OnlineListing.Kind.LOT:
			return _restore_lot_membership(listing, hold, cost, ask)
		OnlineListing.Kind.CARD:
			return _restore_card_membership(listing, hold, cost, ask)
		OnlineListing.Kind.SLAB:
			return _restore_slab_membership(listing, row, hold, cost, ask)
	return false


func _restore_lot_membership(
	listing: OnlineListing,
	hold: InventoryLocation,
	cost: int,
	ask: int
) -> bool:
	if InventoryService.model == null:
		return false
	var claimed := _claimed_hold_quantity(listing.sku_id, OnlineListing.Kind.LOT)
	var on_hold := _hold_lot_quantity(listing.sku_id)
	var missing := listing.quantity - maxi(0, on_hold - claimed)
	if missing > 0:
		if not InventoryService.receive_stock(
			listing.sku_id,
			missing,
			cost,
			hold.duplicate_location()
		):
			return false
	if ask > 0:
		for lot: StockLot in InventoryService.model.stock_lots:
			if (
				lot.sku != null
				and lot.sku.id == listing.sku_id
				and lot.location != null
				and lot.location.type == InventoryLocation.Type.ONLINE_HOLD
			):
				lot.listed_price_cents = ask
				break
	return _hold_lot_quantity(listing.sku_id) >= claimed + listing.quantity


func _restore_card_membership(
	listing: OnlineListing,
	hold: InventoryLocation,
	cost: int,
	ask: int
) -> bool:
	var existing := _unbound_hold_card(listing.sku_id)
	if existing != null:
		listing.card = existing
		if ask > 0:
			existing.listed_price_cents = ask
		return true
	var card := InventoryService.receive_card(
		listing.sku_id,
		cost,
		hold.duplicate_location(),
		ask
	)
	listing.card = card
	return card != null


func _restore_slab_membership(
	listing: OnlineListing,
	row: Dictionary,
	hold: InventoryLocation,
	cost: int,
	ask: int
) -> bool:
	var existing := _unbound_hold_slab(listing.sku_id)
	if existing != null:
		listing.slab = existing
		if ask > 0:
			existing.listed_price_cents = ask
		return true
	var grader := StringName(row.get(OnlineListingSavePolicy.GRADER_KEY, &""))
	var grade := float(row.get(OnlineListingSavePolicy.GRADE_KEY, 0.0))
	var slab := InventoryService.receive_slab(
		listing.sku_id,
		grader,
		grade,
		cost,
		hold.duplicate_location()
	)
	if slab == null:
		return false
	var cert_id := String(row.get(OnlineListingSavePolicy.CERT_ID_KEY, ""))
	if not cert_id.is_empty():
		slab.cert_id = cert_id
	if ask > 0:
		slab.listed_price_cents = ask
	listing.slab = slab
	return true


func _unbound_hold_card(sku_id: StringName) -> CardInstance:
	if InventoryService.model == null:
		return null
	for card: CardInstance in InventoryService.model.cards:
		if (
			card != null
			and card.sku_id == sku_id
			and card.location != null
			and card.location.type == InventoryLocation.Type.ONLINE_HOLD
			and not _card_is_bound(card)
		):
			return card
	return null


func _unbound_hold_slab(sku_id: StringName) -> SlabInstance:
	if InventoryService.model == null:
		return null
	for slab: SlabInstance in InventoryService.model.slabs:
		if (
			slab != null
			and slab.card_ref != null
			and slab.card_ref.sku_id == sku_id
			and slab.location != null
			and slab.location.type == InventoryLocation.Type.ONLINE_HOLD
			and not _slab_is_bound(slab)
		):
			return slab
	return null


func _card_is_bound(card: CardInstance) -> bool:
	for listing: OnlineListing in _listings:
		if listing.card == card:
			return true
	return false


func _slab_is_bound(slab: SlabInstance) -> bool:
	for listing: OnlineListing in _listings:
		if listing.slab == slab:
			return true
	return false


func _claimed_hold_quantity(sku_id: StringName, kind: OnlineListing.Kind) -> int:
	var claimed := 0
	for listing: OnlineListing in _listings:
		if listing.kind == kind and listing.sku_id == sku_id and listing.is_active():
			claimed += listing.quantity
	return claimed


func _hold_lot_quantity(sku_id: StringName) -> int:
	if InventoryService.model == null:
		return 0
	var total := 0
	for lot: StockLot in InventoryService.model.stock_lots:
		if (
			lot != null
			and lot.sku != null
			and lot.sku.id == sku_id
			and lot.location != null
			and lot.location.type == InventoryLocation.Type.ONLINE_HOLD
		):
			total += lot.qty
	return total


func _advance_next_id_past(listing_id: StringName) -> void:
	var text := String(listing_id)
	const PREFIX := "online-"
	if not text.begins_with(PREFIX):
		return
	var seq := int(text.substr(PREFIX.length()))
	_next_id = maxi(_next_id, seq + 1)


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


func _note_cancel(day: int) -> int:
	if day != _cancel_day:
		_cancel_day = day
		_cancels_today = 0
	_cancels_today += 1
	return _cancels_today


func _fee_rate(config: BalanceConfig = null) -> float:
	var resolved := config if config != null else _config()
	return OnlineFeePolicy.fee_rate_for(GameState.current_reputation, resolved)


func _config() -> BalanceConfig:
	return GameState.balance_config


func _hold_cap_result() -> Dictionary:
	return {
		"ok": false,
		"reason": &"hold_cap",
		"listing": null,
		"hold_count": concurrent_hold_count(),
		"hold_cap": hold_cap(),
	}


func _result(ok: bool, reason: StringName, listing: OnlineListing = null) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"listing": listing,
	}
