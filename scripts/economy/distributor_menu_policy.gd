class_name DistributorMenuPolicy
extends RefCounted

## BT1: systems §3 Distributor weekly restock menu.
## Recurring PREP lines for live-catalog SEALED / ACCESSORY SKUs.
## Missing first day → 8. Missing interval → 7. Missing sealed min → 6.
## Missing accessory min → 10. ≤0 falls back. Lines last that menu day
## only. Not a sell weight. Soft catalog closed.
const FIRST_DAY := 8
const INTERVAL_DAYS := 7
const MOQ_SEALED := 6
const MOQ_ACCESSORY := 10
const SPACE_REQUIRED := 1
const OFFER_PREFIX := "distributor-weekly-"
const OFFER_LABEL := "Weekly restock"
const TOAST := "Distributor weekly sheet is in"
const SAVE_KEY := "closed_opportunity_ids"


static func first_day(configured: int = 0) -> int:
	if configured <= 0:
		return FIRST_DAY
	return configured


static func first_day_for(config: BalanceConfig = null) -> int:
	if config == null:
		return FIRST_DAY
	return first_day(config.distributor_menu_first_day)


static func interval_days(configured: int = 0) -> int:
	if configured <= 0:
		return INTERVAL_DAYS
	return configured


static func interval_days_for(config: BalanceConfig = null) -> int:
	if config == null:
		return INTERVAL_DAYS
	return interval_days(config.distributor_menu_interval_days)


static func moq_sealed(configured: int = 0) -> int:
	if configured <= 0:
		return MOQ_SEALED
	return configured


static func moq_sealed_for(config: BalanceConfig = null) -> int:
	if config == null:
		return MOQ_SEALED
	return moq_sealed(config.distributor_menu_moq_sealed)


static func moq_accessory(configured: int = 0) -> int:
	if configured <= 0:
		return MOQ_ACCESSORY
	return configured


static func moq_accessory_for(config: BalanceConfig = null) -> int:
	if config == null:
		return MOQ_ACCESSORY
	return moq_accessory(config.distributor_menu_moq_accessory)


static func is_menu_day(day: int, config: BalanceConfig = null) -> bool:
	var first := first_day_for(config)
	var interval := interval_days_for(config)
	if day < first or interval <= 0:
		return false
	return (day - first) % interval == 0


static func is_menu_sku(sku: ProductSKU) -> bool:
	if sku == null:
		return false
	return sku.product_class in [
		ProductSKU.ProductClass.SEALED,
		ProductSKU.ProductClass.ACCESSORY,
	]


static func base_moq_for(
	product_class: ProductSKU.ProductClass,
	config: BalanceConfig = null
) -> int:
	match product_class:
		ProductSKU.ProductClass.SEALED:
			return moq_sealed_for(config)
		ProductSKU.ProductClass.ACCESSORY:
			return moq_accessory_for(config)
		_:
			return 0


static func menu_sku_ids(catalog: Dictionary) -> Array[StringName]:
	var ids: Array[StringName] = []
	for value: Variant in catalog.values():
		var sku := value as ProductSKU
		if is_menu_sku(sku):
			ids.append(sku.id)
	return ids


static func offer_id(day: int, sku_id: StringName) -> StringName:
	return StringName("%sd%d-%s" % [OFFER_PREFIX, day, String(sku_id)])


static func is_menu_id(opportunity_id: StringName) -> bool:
	return String(opportunity_id).begins_with(OFFER_PREFIX)


static func closed_ids_to_save(closed: Dictionary) -> Array:
	var ids: Array = []
	for key: Variant in closed.keys():
		var raw := String(key)
		if not raw.is_empty():
			ids.append(raw)
	ids.sort()
	return ids


static func closed_ids_from_save(value: Variant) -> Dictionary:
	var closed: Dictionary = {}
	if not value is Array:
		return closed
	for item: Variant in value as Array:
		var raw := String(item)
		if raw.is_empty():
			continue
		closed[StringName(raw)] = true
	return closed
