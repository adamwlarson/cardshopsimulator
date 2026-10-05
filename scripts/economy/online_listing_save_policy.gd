class_name OnlineListingSavePolicy
extends RefCounted

## BJ1: persist concurrent ONLINE_HOLD lots across save/load.
## Each active hold restores stock identity, listed ask, remaining
## ship days, and hold membership so the BI1 soft-cap count matches.
## Out: list/cancel verbs, fee ladder, BH1 cancel-day counter (separate
## snapshot). Never serializes true_market / p_buy / cert_valid.
const SAVE_NEXT_ID_KEY := "next_id"
const SAVE_LISTINGS_KEY := "listings"

const KIND_LOT := "lot"
const KIND_CARD := "card"
const KIND_SLAB := "slab"

const ID_KEY := "id"
const KIND_KEY := "kind"
const SKU_ID_KEY := "sku_id"
const DISPLAY_NAME_KEY := "display_name"
const QUANTITY_KEY := "quantity"
const LISTED_PRICE_KEY := "listed_price_cents"
const FEE_CENTS_KEY := "fee_cents"
const SHIP_DAYS_KEY := "ship_days"
const REMAINING_DAYS_KEY := "remaining_days"
const LISTED_ON_DAY_KEY := "listed_on_day"
const PREVIOUS_LOCATION_KEY := "previous_location"
const ACQUIRED_COST_KEY := "acquired_cost_cents"
const GRADER_KEY := "grader"
const GRADE_KEY := "grade"
const CERT_ID_KEY := "cert_id"
const LOCATION_TYPE_KEY := "type"
const LOCATION_SLOT_KEY := "slot_id"


static func snapshot(next_id: int, listings: Array[OnlineListing]) -> Dictionary:
	var rows: Array[Dictionary] = []
	for listing: OnlineListing in listings:
		if listing == null or not listing.is_active():
			continue
		if listing.remaining_days <= 0:
			continue
		rows.append(listing_to_save(listing))
	return {
		SAVE_NEXT_ID_KEY: maxi(1, next_id),
		SAVE_LISTINGS_KEY: rows,
	}


static func next_id_from_save(data: Dictionary) -> int:
	return maxi(1, int(data.get(SAVE_NEXT_ID_KEY, 1)))


static func listing_rows_from_save(data: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var rows: Variant = data.get(SAVE_LISTINGS_KEY, [])
	if not rows is Array:
		return result
	for row: Variant in rows as Array:
		if row is Dictionary:
			result.append(row as Dictionary)
	return result


static func listing_to_save(listing: OnlineListing) -> Dictionary:
	var row := {
		ID_KEY: String(listing.id),
		KIND_KEY: kind_to_save(listing.kind),
		SKU_ID_KEY: String(listing.sku_id),
		DISPLAY_NAME_KEY: listing.display_name,
		QUANTITY_KEY: maxi(1, listing.quantity),
		LISTED_PRICE_KEY: listing.listed_price_cents,
		FEE_CENTS_KEY: listing.fee_cents,
		SHIP_DAYS_KEY: listing.ship_days,
		REMAINING_DAYS_KEY: listing.remaining_days,
		LISTED_ON_DAY_KEY: listing.listed_on_day,
		PREVIOUS_LOCATION_KEY: location_to_save(listing.previous_location),
		ACQUIRED_COST_KEY: acquired_cost_of(listing),
	}
	if listing.kind == OnlineListing.Kind.SLAB and listing.slab != null:
		row[GRADER_KEY] = String(listing.slab.grader)
		row[GRADE_KEY] = listing.slab.grade
		row[CERT_ID_KEY] = listing.slab.cert_id
	return row


static func listing_from_save(data: Dictionary) -> OnlineListing:
	if data.is_empty():
		return null
	var sku_id := StringName(data.get(SKU_ID_KEY, ""))
	if String(sku_id).is_empty():
		return null
	var remaining := int(data.get(REMAINING_DAYS_KEY, 0))
	if remaining <= 0:
		return null
	var listing := OnlineListing.new()
	listing.id = StringName(data.get(ID_KEY, ""))
	listing.kind = kind_from_save(data.get(KIND_KEY, KIND_CARD))
	listing.sku_id = sku_id
	listing.display_name = String(data.get(DISPLAY_NAME_KEY, String(sku_id)))
	listing.quantity = maxi(1, int(data.get(QUANTITY_KEY, 1)))
	listing.listed_price_cents = int(data.get(LISTED_PRICE_KEY, 0))
	listing.fee_cents = maxi(0, int(data.get(FEE_CENTS_KEY, 0)))
	listing.ship_days = maxi(1, int(data.get(SHIP_DAYS_KEY, remaining)))
	listing.remaining_days = remaining
	listing.listed_on_day = int(data.get(LISTED_ON_DAY_KEY, 0))
	listing.previous_location = location_from_save(data.get(PREVIOUS_LOCATION_KEY, {}))
	listing.status = OnlineListing.Status.ACTIVE
	return listing


static func kind_to_save(kind: OnlineListing.Kind) -> String:
	match kind:
		OnlineListing.Kind.SLAB:
			return KIND_SLAB
		OnlineListing.Kind.LOT:
			return KIND_LOT
		_:
			return KIND_CARD


static func kind_from_save(value: Variant) -> OnlineListing.Kind:
	var named := String(value).to_lower()
	match named:
		KIND_SLAB:
			return OnlineListing.Kind.SLAB
		KIND_LOT:
			return OnlineListing.Kind.LOT
		KIND_CARD:
			return OnlineListing.Kind.CARD
	if value is int or value is float:
		var encoded := int(value)
		if encoded == int(OnlineListing.Kind.SLAB):
			return OnlineListing.Kind.SLAB
		if encoded == int(OnlineListing.Kind.LOT):
			return OnlineListing.Kind.LOT
	return OnlineListing.Kind.CARD


static func location_to_save(location: InventoryLocation) -> Dictionary:
	if location == null:
		return {}
	return {
		LOCATION_TYPE_KEY: int(location.type),
		LOCATION_SLOT_KEY: location.slot_id,
	}


static func location_from_save(value: Variant) -> InventoryLocation:
	if not value is Dictionary:
		return null
	var data := value as Dictionary
	if data.is_empty():
		return null
	var location_type := int(
		data.get(LOCATION_TYPE_KEY, int(InventoryLocation.Type.BACKSTOCK))
	) as InventoryLocation.Type
	return InventoryLocation.new(
		location_type,
		int(data.get(LOCATION_SLOT_KEY, -1))
	)


static func acquired_cost_of(listing: OnlineListing) -> int:
	if listing == null:
		return 0
	if listing.kind == OnlineListing.Kind.CARD and listing.card != null:
		return maxi(0, listing.card.acquired_cost_cents)
	if listing.kind == OnlineListing.Kind.SLAB and listing.slab != null:
		return maxi(0, listing.slab.acquired_cost_cents)
	return 0


static func acquired_cost_from_save(data: Dictionary) -> int:
	return maxi(0, int(data.get(ACQUIRED_COST_KEY, 0)))
