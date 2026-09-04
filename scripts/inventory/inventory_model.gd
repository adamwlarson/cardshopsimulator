class_name InventoryModel
extends RefCounted

const CASE_CARD_WEIGHT := 1
const CASE_SLAB_WEIGHT := 2

var balance_config: BalanceConfig
var catalog: Dictionary = {}
var stock_lots: Array[StockLot] = []
var cards: Array[CardInstance] = []
var slabs: Array[SlabInstance] = []


func _init(config: BalanceConfig) -> void:
	balance_config = config
	_build_canon_catalog()


func reset_and_seed() -> void:
	stock_lots.clear()
	cards.clear()
	slabs.clear()
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
		balance_config.seed_sleeves,
		250,
		InventoryLocation.new(InventoryLocation.Type.SHELF)
	)
	add_stock(
		&"ACC-TOP-25",
		balance_config.seed_toploaders,
		300,
		InventoryLocation.new(InventoryLocation.Type.SHELF)
	)

	var staple_skus: Array[StringName] = [
		&"AA-BASE-088",
		&"AA-BASE-078",
		&"AA-SKIE-047",
		&"AA-SKIE-052",
	]
	for index: int in balance_config.seed_named_staples:
		var sku_id := staple_skus[index % staple_skus.size()]
		var sku := get_sku(sku_id)
		var card := CardInstance.new(
			sku_id,
			sku.base_market_cents / 2,
			InventoryLocation.new(InventoryLocation.Type.BINDER)
		)
		add_card(card)


func get_sku(sku_id: StringName) -> ProductSKU:
	return catalog.get(sku_id) as ProductSKU


func get_stock_quantity(sku_id: StringName) -> int:
	var lot := _find_stock_lot(sku_id)
	return lot.qty if lot != null else 0


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
		or not StockLot.new().accepts_product(product)
	):
		return false

	var lot := _find_stock_lot(sku_id)
	if lot == null:
		if not can_place(product.product_class, location):
			return false
		lot = StockLot.new()
		lot.sku = product
		lot.location = location.duplicate_location()
		lot.qty = quantity
		lot.acquired_cost_avg_cents = unit_cost_cents
		stock_lots.append(lot)
	else:
		if lot.location.type != location.type or lot.location.slot_id != location.slot_id:
			return false
		var new_qty := lot.qty + quantity
		lot.acquired_cost_avg_cents = (
			(lot.total_cost_cents() + quantity * unit_cost_cents) / new_qty
		)
		lot.qty = new_qty
	return true


func remove_stock(sku_id: StringName, quantity: int) -> bool:
	var lot := _find_stock_lot(sku_id)
	if lot == null or quantity <= 0 or lot.qty < quantity:
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


func add_slab(slab: SlabInstance) -> bool:
	if slab == null or slab.card_ref == null:
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
			return case_slots_used(excluding) + weight <= balance_config.case_slots
		InventoryLocation.Type.BINDER:
			return product_class == ProductSKU.ProductClass.SINGLE
		InventoryLocation.Type.SHELF:
			return product_class in [
				ProductSKU.ProductClass.SEALED,
				ProductSKU.ProductClass.ACCESSORY,
			]
		InventoryLocation.Type.BACKSTOCK:
			return backstock_bins_used(excluding) < balance_config.backstock_bins
		InventoryLocation.Type.ONLINE_HOLD:
			return true
	return false


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


func _find_stock_lot(sku_id: StringName) -> StockLot:
	for lot: StockLot in stock_lots:
		if lot.sku.id == sku_id:
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
	_register_sku(&"AA-DUST-ETB", ProductSKU.ProductClass.SEALED, "Dustway Chronicles Explorer Box", 4_499, &"AA-DUST", [&"sealed", &"cooling"])
	_register_sku(&"AA-SKIE-ETB", ProductSKU.ProductClass.SEALED, "Skiefall Ascension Explorer Box", 4_999, &"AA-SKIE", [&"sealed", &"current"])
	_register_sku(&"AA-SKIE-BLST", ProductSKU.ProductClass.SEALED, "Skiefall Ascension Blaster", 2_999, &"AA-SKIE", [&"sealed", &"current"])
	_register_sku(&"AA-BASE-088", ProductSKU.ProductClass.SINGLE, "Bastion Captain", 500, &"AA-BASE", [&"staple", &"archetype:mid"])
	_register_sku(&"AA-BASE-078", ProductSKU.ProductClass.SINGLE, "Arcbolt Adept", 450, &"AA-BASE", [&"staple", &"archetype:aggro"])
	_register_sku(&"AA-SKIE-047", ProductSKU.ProductClass.SINGLE, "Skiefall Titan", 2_200, &"AA-SKIE", [&"chase", &"staple"])
	_register_sku(&"AA-SKIE-052", ProductSKU.ProductClass.SINGLE, "Empress of Updrafts", 7_500, &"AA-SKIE", [&"chase", &"legendary"])
	_register_sku(&"ACC-SLV-60", ProductSKU.ProductClass.ACCESSORY, "Soft Sleeves 60ct", 599, &"", [&"accessory"])
	_register_sku(&"ACC-TOP-25", ProductSKU.ProductClass.ACCESSORY, "Toploaders 25ct", 699, &"", [&"accessory"])
