class_name InventoryModel
extends RefCounted

const CASE_CARD_WEIGHT := 1
const CASE_SLAB_WEIGHT := 2

var balance_config: BalanceConfig
var catalog: Dictionary = {}
var stock_lots: Array[StockLot] = []
var cards: Array[CardInstance] = []
var slabs: Array[SlabInstance] = []
var case_slot_bonus: int = 0
var backstock_bin_bonus: int = 0


func _init(config: BalanceConfig) -> void:
	balance_config = config
	_build_canon_catalog()


func reset_and_seed() -> void:
	stock_lots.clear()
	cards.clear()
	slabs.clear()
	case_slot_bonus = 0
	backstock_bin_bonus = 0
	seed_from_balance()


func seed_from_balance() -> void:
	add_stock(
		&"AA-SKIE-BLST",
		balance_config.seed_blasters + balance_config.seed_skie_blasters,
		2_000,
		InventoryLocation.new(InventoryLocation.Type.SHELF)
	)
	add_stock(
		&"AA-DUST-ETB",
		balance_config.seed_dust_etbs,
		2_500,
		InventoryLocation.new(InventoryLocation.Type.SHELF)
	)
	add_stock(
		&"ACC-SLV-60",
		ceili(balance_config.seed_sleeves / 60.0),
		250,
		InventoryLocation.new(InventoryLocation.Type.SHELF)
	)
	add_stock(
		&"ACC-TOP-25",
		ceili(balance_config.seed_toploaders / 25.0),
		300,
		InventoryLocation.new(InventoryLocation.Type.SHELF)
	)

	var staple_skus: Array[StringName] = [
		&"AA-BASE-088",
		&"AA-BASE-078",
		&"AA-SKIE-047",
	]
	for index: int in balance_config.seed_named_staples:
		var sku_id := staple_skus[index % staple_skus.size()]
		var sku := get_sku(sku_id)
		var card := CardInstance.new(
			sku_id,
			sku.base_market_cents / 2,
			InventoryLocation.new(InventoryLocation.Type.BINDER)
		)
		card.listed_price_cents = sku.base_market_cents
		add_card(card)
	for index: int in balance_config.seed_bulk_cards:
		add_card(CardInstance.new(
			&"AA-BASE-BULK",
			25,
			InventoryLocation.new(InventoryLocation.Type.BINDER, index)
		))


func get_sku(sku_id: StringName) -> ProductSKU:
	return catalog.get(sku_id) as ProductSKU


func get_stock_quantity(sku_id: StringName) -> int:
	var quantity := 0
	for lot: StockLot in stock_lots:
		if lot.sku.id == sku_id:
			quantity += lot.qty
	return quantity


func inventory_cogs_cents() -> int:
	var total := 0
	for lot: StockLot in stock_lots:
		total += lot.total_cost_cents()
	for card: CardInstance in cards:
		total += card.acquired_cost_cents
	for slab: SlabInstance in slabs:
		total += slab.acquired_cost_cents
	return total


func unit_count() -> int:
	var total := 0
	for lot: StockLot in stock_lots:
		total += lot.qty
	total += cards.size()
	total += slabs.size()
	return total


func apply_shrink_loss(loss_cents: int) -> Dictionary:
	var removed_cents := 0
	var units_removed := 0
	if loss_cents <= 0:
		return {
			"loss_cents": 0,
			"units_removed": 0,
		}
	var remaining := loss_cents
	while remaining > 0 and unit_count() > 1:
		var target := _cheapest_shrink_target()
		if target.is_empty():
			break
		var kind := StringName(target.get("kind", &""))
		var cost := int(target.get("cost_cents", 0))
		if kind == &"lot":
			var lot := target.get("lot") as StockLot
			if lot == null or lot.qty <= 0:
				break
			if not remove_stock(lot.sku.id, 1):
				break
		elif kind == &"card":
			var card := target.get("card") as CardInstance
			if card == null or not remove_card(card):
				break
		elif kind == &"slab":
			var slab := target.get("slab") as SlabInstance
			if slab == null or not remove_slab(slab):
				break
		else:
			break
		removed_cents += maxi(1, cost)
		units_removed += 1
		remaining -= maxi(1, cost)
	return {
		"loss_cents": removed_cents,
		"units_removed": units_removed,
	}


func has_backstock(sku_id: StringName) -> bool:
	return _first_backstock_target(sku_id) != null


func pull_from_backstock(sku_id: StringName) -> bool:
	var target := _first_backstock_target(sku_id)
	if target == null:
		return false
	if target is StockLot:
		var lot := target as StockLot
		var dest := InventoryLocation.new(InventoryLocation.Type.SHELF)
		return move_stock(lot.sku.id, lot.location, dest, 1)
	if target is CardInstance:
		return move_card(
			target as CardInstance,
			InventoryLocation.new(InventoryLocation.Type.BINDER)
		)
	if target is SlabInstance:
		return move_slab(
			target as SlabInstance,
			InventoryLocation.new(InventoryLocation.Type.CASE)
		)
	return false


func _first_backstock_target(sku_id: StringName) -> Resource:
	for lot: StockLot in stock_lots:
		if (
			lot.sku.id == sku_id
			and lot.qty > 0
			and lot.location.type == InventoryLocation.Type.BACKSTOCK
		):
			return lot
	for card: CardInstance in cards:
		if (
			card.sku_id == sku_id
			and card.location.type == InventoryLocation.Type.BACKSTOCK
		):
			return card
	for slab: SlabInstance in slabs:
		if (
			slab.card_ref != null
			and slab.card_ref.sku_id == sku_id
			and slab.location.type == InventoryLocation.Type.BACKSTOCK
		):
			return slab
	return null


func _cheapest_shrink_target() -> Dictionary:
	var best: Dictionary = {}
	var best_cost := 1_000_000_000
	for lot: StockLot in stock_lots:
		if lot.qty <= 0:
			continue
		var cost := maxi(1, lot.unit_cost_cents())
		if cost < best_cost:
			best_cost = cost
			best = {"kind": &"lot", "lot": lot, "cost_cents": cost}
	for card: CardInstance in cards:
		var cost := maxi(1, card.acquired_cost_cents)
		if cost < best_cost:
			best_cost = cost
			best = {"kind": &"card", "card": card, "cost_cents": cost}
	for slab: SlabInstance in slabs:
		var cost := maxi(1, slab.acquired_cost_cents)
		if cost < best_cost:
			best_cost = cost
			best = {"kind": &"slab", "slab": slab, "cost_cents": cost}
	return best


func add_stock(
	sku_id: StringName,
	quantity: int,
	unit_cost_cents: int,
	location: InventoryLocation
) -> bool:
	var product := get_sku(sku_id)
	if (
		product == null
		or quantity <= 0
		or unit_cost_cents < 0
		or location == null
		or not StockLot.accepts_product(product)
	):
		return false

	var lot := _find_stock_lot(sku_id, location)
	if lot == null:
		if not can_place(product.product_class, location):
			return false
		lot = StockLot.new()
		lot.sku = product
		lot.location = location.duplicate_location()
		lot.qty = quantity
		lot.acquired_cost_avg_cents = unit_cost_cents
		lot.listed_price_cents = product.base_market_cents
		stock_lots.append(lot)
	else:
		var new_qty := lot.qty + quantity
		lot.acquired_cost_avg_cents = (
			(lot.total_cost_cents() + quantity * unit_cost_cents) / new_qty
		)
		lot.qty = new_qty
	return true


func remove_stock(sku_id: StringName, quantity: int) -> bool:
	if quantity <= 0 or get_stock_quantity(sku_id) < quantity:
		return false
	var remaining := quantity
	for lot: StockLot in stock_lots.duplicate():
		if lot.sku.id != sku_id:
			continue
		var removed := mini(lot.qty, remaining)
		lot.qty -= removed
		remaining -= removed
		if lot.qty == 0:
			stock_lots.erase(lot)
		if remaining == 0:
			break
	return true


func move_stock(
	sku_id: StringName,
	source: InventoryLocation,
	destination: InventoryLocation,
	quantity: int
) -> bool:
	var lot := _find_stock_lot(sku_id, source)
	if (
		lot == null
		or quantity <= 0
		or lot.qty < quantity
	):
		return false
	var destination_lot := _find_stock_lot(sku_id, destination)
	if destination_lot == null:
		var excluding: Resource = lot if quantity == lot.qty else null
		if not can_place(lot.sku.product_class, destination, excluding):
			return false
	if not add_stock(sku_id, quantity, lot.acquired_cost_avg_cents, destination):
		return false
	lot.qty -= quantity
	if lot.qty == 0:
		stock_lots.erase(lot)
	return true


func add_card(card: CardInstance) -> bool:
	var product := get_sku(card.sku_id) if card != null else null
	if (
		card == null
		or product == null
		or product.product_class != ProductSKU.ProductClass.SINGLE
		or not can_place(product.product_class, card.location)
	):
		return false
	cards.append(card)
	return true


func remove_card(card: CardInstance) -> bool:
	if card == null or not cards.has(card):
		return false
	cards.erase(card)
	return true


func add_slab(slab: SlabInstance) -> bool:
	if (
		slab == null
		or slab.card_ref == null
		or cards.has(slab.card_ref)
		or slabs.has(slab)
	):
		return false
	for existing_slab: SlabInstance in slabs:
		if existing_slab.card_ref == slab.card_ref:
			return false
	var product := get_sku(slab.card_ref.sku_id)
	if (
		product == null
		or product.product_class != ProductSKU.ProductClass.SINGLE
		or not can_place(ProductSKU.ProductClass.GRADED, slab.location)
	):
		return false
	slabs.append(slab)
	return true


func remove_slab(slab: SlabInstance) -> bool:
	if slab == null or not slabs.has(slab):
		return false
	slabs.erase(slab)
	return true


func move_card(card: CardInstance, destination: InventoryLocation) -> bool:
	if card == null or not cards.has(card):
		return false
	if not can_place(ProductSKU.ProductClass.SINGLE, destination, card):
		return false
	card.location = destination.duplicate_location()
	return true


func move_slab(slab: SlabInstance, destination: InventoryLocation) -> bool:
	if slab == null or not slabs.has(slab):
		return false
	if not can_place(ProductSKU.ProductClass.GRADED, destination, slab):
		return false
	slab.location = destination.duplicate_location()
	return true


func can_place(
	product_class: ProductSKU.ProductClass,
	location: InventoryLocation,
	excluding: Resource = null
) -> bool:
	if location == null:
		return false
	match location.type:
		InventoryLocation.Type.CASE:
			if product_class not in [
				ProductSKU.ProductClass.SINGLE,
				ProductSKU.ProductClass.GRADED,
			]:
				return false
			var weight := CASE_SLAB_WEIGHT if product_class == ProductSKU.ProductClass.GRADED else CASE_CARD_WEIGHT
			return case_slots_used(excluding) + weight <= case_slot_limit()
		InventoryLocation.Type.BINDER:
			return product_class == ProductSKU.ProductClass.SINGLE
		InventoryLocation.Type.SHELF:
			return product_class in [
				ProductSKU.ProductClass.SEALED,
				ProductSKU.ProductClass.ACCESSORY,
			]
		InventoryLocation.Type.BACKSTOCK:
			return backstock_bins_used(excluding) < backstock_bin_limit()
		InventoryLocation.Type.ONLINE_HOLD:
			return true
	return false


func case_slot_limit() -> int:
	return balance_config.case_slots + case_slot_bonus


func backstock_bin_limit() -> int:
	return balance_config.backstock_bins + backstock_bin_bonus


func case_slots_used(excluding: Resource = null) -> int:
	var used := 0
	for card: CardInstance in cards:
		if card != excluding and card.location.type == InventoryLocation.Type.CASE:
			used += CASE_CARD_WEIGHT
	for slab: SlabInstance in slabs:
		if slab != excluding and slab.location.type == InventoryLocation.Type.CASE:
			used += CASE_SLAB_WEIGHT
	return used


func backstock_bins_used(excluding: Resource = null) -> int:
	var used := 0
	for lot: StockLot in stock_lots:
		if lot != excluding and lot.location.type == InventoryLocation.Type.BACKSTOCK:
			used += 1
	for card: CardInstance in cards:
		if card != excluding and card.location.type == InventoryLocation.Type.BACKSTOCK:
			used += 1
	for slab: SlabInstance in slabs:
		if slab != excluding and slab.location.type == InventoryLocation.Type.BACKSTOCK:
			used += 1
	return used


func _find_stock_lot(
	sku_id: StringName,
	location: InventoryLocation = null
) -> StockLot:
	for lot: StockLot in stock_lots:
		if (
			lot.sku.id == sku_id
			and (
				location == null
				or (
					lot.location.type == location.type
					and lot.location.slot_id == location.slot_id
				)
			)
		):
			return lot
	return null


func _register_sku(
	sku_id: StringName,
	product_class: ProductSKU.ProductClass,
	display_name: String,
	market_cents: int,
	set_id: StringName = &"",
	tags: Array[StringName] = []
) -> void:
	catalog[sku_id] = ProductSKU.new(
		sku_id,
		product_class,
		display_name,
		market_cents,
		set_id,
		tags
	)


func _build_canon_catalog() -> void:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/products.json")
	)
	if not parsed is Dictionary:
		push_error("Could not load product catalog.")
		return
	for entry_value: Variant in (parsed as Dictionary).get("products", []):
		var entry := entry_value as Dictionary
		var sku_id := StringName(entry.get("sku", ""))
		var type_name := String(entry.get("product_type", ""))
		var product_class := ProductSKU.ProductClass.SEALED
		match type_name:
			"single":
				product_class = ProductSKU.ProductClass.SINGLE
			"accessory":
				product_class = ProductSKU.ProductClass.ACCESSORY
			"graded":
				product_class = ProductSKU.ProductClass.GRADED
		var set_id := StringName(String(sku_id).substr(0, 7)) if String(sku_id).begins_with("AA-") else &""
		var tags: Array[StringName] = []
		for tag: Variant in entry.get("tags", []):
			tags.append(StringName(tag))
		_register_sku(
			sku_id,
			product_class,
			String(entry.get("display_name", "")),
			int(entry.get("market_price_cents", 0)),
			set_id,
			tags
		)
