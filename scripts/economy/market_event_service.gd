class_name MarketEventService
extends RefCounted

const CATALOG_PATH := "res://data/events.json"
const EVENT_RNG_SEED := 20260904
const FOG_SIGMA_MULT := 1.5
const HYPE_MARKET_MULT := 1.35
const HYPE_DEMAND_SCORE := 0.95
const COUNTERFEIT_TRUST_MULT := 0.55
const COUNTERFEIT_SHADY_FAKE_MULT := 2.5
const COUNTERFEIT_SHADY_WIDTH_MULT := 1.35
const CONVENTION_TRAFFIC_MULT := 2.0
const CONVENTION_WHALE_WEIGHT_MULT := 2.5
const CONVENTION_CALENDAR_WEIGHT_MULT := 2.5
## AB1 event nights: weekend calendar days (one FLOOR session = the night).
## Modest vs convention ×2 / ×2.5. Only applied while a play table is placed.
const EVENT_NIGHT_TRAFFIC_MULT := 1.25
const EVENT_NIGHT_WHALE_WEIGHT_MULT := 1.4
## systems §7.2: blocked entrance → displays → counter cuts traffic.
const BLOCKED_PATH_TRAFFIC_MULT := 0.7
## Existing timeout leave (−Rep) ticks faster when the aisle is blocked.
const BLOCKED_PATH_PATIENCE_SCALE := 2.0
## systems §8 Theft ring: Shrink ×3 for 3 days. Staff coverage on the floor
## dampens the base loss rate; wait out still ends the window. Security cameras
## (shop unlock) reduce the theft multiplier while owned/active.
const THEFT_RING_SHRINK_MULT := 3.0
## systems §8 Recession week: all demand ↓, buylist sellers ↑. One week only —
## multi-week depression arc is out. Loan-shark stays bankruptcy-only.
const RECESSION_DEMAND_MULT := 0.65
const RECESSION_BUYLIST_MULT := 2.0
## systems §8 Supply glut: sealed wholesale ↓, retail race. Short window only —
## multi-distributor war and long glut seasons are out.
const SUPPLY_GLUT_WHOLESALE_MULT := 0.75
const SUPPLY_GLUT_SEALED_RACE_MULT := 0.90
const SET_RELEASE_CALENDAR_WEIGHT_MULT := 2.5
const TITAN_SKU := &"AA-SKIE-047"
const ROTATION_SET_ID := &"AA-DUST"

var defs: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()


func _init(rng_seed: int = EVENT_RNG_SEED) -> void:
	rng.seed = rng_seed
	_load_catalog()


func reset(rng_seed: int = EVENT_RNG_SEED) -> void:
	rng.seed = rng_seed
	if defs.is_empty():
		_load_catalog()


func settle_chance(config: BalanceConfig) -> float:
	if config == null:
		return 0.18
	return config.event_chance_settle


func should_roll(config: BalanceConfig) -> bool:
	return rng.randf() < settle_chance(config)


func roll_definition(config: BalanceConfig, day: int = 0) -> Dictionary:
	var total := 0.0
	var weighted: Array[Dictionary] = []
	for def: Dictionary in defs:
		var weight := _weight_for(def, config, day)
		if weight <= 0.0:
			continue
		total += weight
		weighted.append({"def": def, "weight": weight})
	if total <= 0.0 or weighted.is_empty():
		return {}
	var pick := rng.randf() * total
	var cursor := 0.0
	for row: Dictionary in weighted:
		cursor += float(row["weight"])
		if pick <= cursor:
			return row["def"]
	return weighted[weighted.size() - 1]["def"]


func roll_duration(def: Dictionary, config: BalanceConfig = null) -> int:
	var kind := StringName(def.get("type", ""))
	if kind == MarketEvent.KIND_SET_RELEASE:
		return SetReleaseHypePolicy.duration_days_for(config)
	if kind == MarketEvent.KIND_PRO_TOUR:
		return ProTourSpikePolicy.duration_days_for(config)
	if kind == MarketEvent.KIND_ROTATION_CRASH:
		return RotationCrashPolicy.duration_days_for(config)
	var min_days := maxi(1, int(def.get("duration_days_min", 1)))
	var max_days := maxi(min_days, int(def.get("duration_days_max", min_days)))
	if max_days == min_days:
		return min_days
	return rng.randi_range(min_days, max_days)


func definition_for(kind: StringName) -> Dictionary:
	for def: Dictionary in defs:
		if StringName(def.get("type", "")) == kind:
			return def
	return {}


static func is_convention_calendar_day(day: int) -> bool:
	var weekday := posmod(day, 7)
	return weekday == 0 or weekday == 6


static func is_convention_telegraph_day(day: int) -> bool:
	return posmod(day, 7) == 5


static func convention_calendar_weight_mult(day: int) -> float:
	if is_convention_calendar_day(day) or is_convention_telegraph_day(day):
		return CONVENTION_CALENDAR_WEIGHT_MULT
	return 1.0


static func is_set_release_calendar_day(day: int, config: BalanceConfig = null) -> bool:
	return SetReleaseHypePolicy.is_calendar_day(day, config)


static func is_set_release_telegraph_day(day: int, config: BalanceConfig = null) -> bool:
	return SetReleaseHypePolicy.is_telegraph_day(day, config)


static func set_release_calendar_weight_mult(
	day: int,
	config: BalanceConfig = null
) -> float:
	return SetReleaseHypePolicy.calendar_weight_mult(day, config)


func pick_set_release_targets(
	new_set_id: StringName = &"",
	old_set_id: StringName = &""
) -> Dictionary:
	var sealed_sets := live_sealed_set_ids()
	if sealed_sets.size() < 2:
		return {}
	var new_id := new_set_id
	var old_id := old_set_id
	if new_id.is_empty() or not sealed_sets.has(new_id):
		new_id = sealed_sets[rng.randi() % sealed_sets.size()]
	if old_id.is_empty() or old_id == new_id or not sealed_sets.has(old_id):
		var rest: Array[StringName] = []
		for set_id: StringName in sealed_sets:
			if set_id != new_id:
				rest.append(set_id)
		if rest.is_empty():
			return {}
		old_id = rest[rng.randi() % rest.size()]
	return {"set_id": new_id, "old_set_id": old_id}


func pick_pro_tour_target(archetype_tag: StringName = &"") -> Dictionary:
	var tags := live_archetype_tags()
	if tags.is_empty():
		return {}
	var tag := archetype_tag
	if tag.is_empty() or not (tag in tags):
		tag = tags[rng.randi() % tags.size()]
	if tag.is_empty():
		return {}
	return {"archetype_tag": tag}


func roll_pro_tour_mult(config: BalanceConfig = null) -> float:
	return ProTourSpikePolicy.roll_mult(rng, config)


func pick_rotation_crash_target(set_id: StringName = &"") -> Dictionary:
	if RotationCrashPolicy.is_base_set(set_id):
		return {}
	if not set_id.is_empty():
		return {"set_id": set_id}
	var oldest := RotationCrashPolicy.oldest_non_base_set(live_set_ids())
	if oldest.is_empty() or RotationCrashPolicy.is_base_set(oldest):
		return {}
	return {"set_id": oldest}


func roll_rotation_crash_mult(config: BalanceConfig = null) -> float:
	return RotationCrashPolicy.roll_crash_mult(rng, config)


func live_set_ids() -> Array[StringName]:
	var seen := {}
	var names: PackedStringArray = []
	if InventoryService.model == null:
		return []
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku == null or sku.set_id.is_empty() or seen.has(String(sku.set_id)):
			continue
		seen[String(sku.set_id)] = true
		names.append(String(sku.set_id))
	names.sort()
	var ids: Array[StringName] = []
	for name: String in names:
		ids.append(StringName(name))
	return ids


func live_archetype_tags() -> Array[StringName]:
	var seen := {}
	var names: PackedStringArray = []
	if InventoryService.model == null:
		return []
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku == null or sku.product_class != ProductSKU.ProductClass.SINGLE:
			continue
		for tag: StringName in sku.tags:
			if not ProTourSpikePolicy.is_archetype_tag(tag):
				continue
			var key := String(tag)
			if seen.has(key):
				continue
			seen[key] = true
			names.append(key)
	names.sort()
	var ids: Array[StringName] = []
	for name: String in names:
		ids.append(StringName(name))
	return ids


func live_sealed_set_ids() -> Array[StringName]:
	var seen := {}
	var names: PackedStringArray = []
	if InventoryService.model == null:
		return []
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku == null or sku.product_class != ProductSKU.ProductClass.SEALED:
			continue
		if sku.set_id.is_empty() or seen.has(String(sku.set_id)):
			continue
		seen[String(sku.set_id)] = true
		names.append(String(sku.set_id))
	names.sort()
	var ids: Array[StringName] = []
	for name: String in names:
		ids.append(StringName(name))
	return ids


static func is_event_night_day(day: int) -> bool:
	# Weekend evenings share the Sat/Sun calendar used by convention.
	return is_convention_calendar_day(day)


func _weight_for(def: Dictionary, config: BalanceConfig, day: int = 0) -> float:
	var weight := float(def.get("weight", 1.0))
	if bool(def.get("negative", false)) and config != null:
		weight *= config.negative_event_weight_mult
	var kind := StringName(def.get("type", ""))
	if kind == MarketEvent.KIND_CONVENTION:
		weight *= convention_calendar_weight_mult(day)
	elif kind == MarketEvent.KIND_SET_RELEASE:
		weight *= set_release_calendar_weight_mult(day, config)
	elif kind == MarketEvent.KIND_ROTATION_CRASH:
		weight *= RotationCrashPolicy.surprise_weight_for(config)
	return maxf(0.0, weight)


func _load_catalog() -> void:
	defs.clear()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if parsed is Dictionary:
		for entry_value: Variant in (parsed as Dictionary).get("events", []):
			if entry_value is Dictionary:
				defs.append(entry_value as Dictionary)
	if defs.size() >= 11:
		return
	defs = [
		_fallback_def(&"hype_spike", "Hype spike", false, 1, 3),
		_fallback_def(&"soft_rotation_leak", "Soft rotation leak", true, 1, 3),
		_fallback_def(&"fog_day", "Fog day", true, 1, 1),
		_fallback_def(&"counterfeit_scare", "Counterfeit scare", true, 1, 3),
		_fallback_def(&"convention_weekend", "Convention weekend", false, 2, 2),
		_fallback_def(&"theft_ring", "Theft ring", true, 3, 3),
		_fallback_def(&"recession_week", "Recession week", true, 7, 7),
		_fallback_def(&"supply_glut", "Supply glut", false, 3, 3),
		_fallback_def(&"set_release_hype", "Set release hype", false, 5, 5),
		_fallback_def(&"pro_tour_spike", "Pro tour spike", false, 2, 2),
		_fallback_def(&"rotation_crash", "Rotation crash", true, 5, 5),
	]


func _fallback_def(
	kind: StringName,
	title: String,
	negative: bool,
	min_days: int,
	max_days: int
) -> Dictionary:
	return {
		"id": String(kind),
		"type": String(kind),
		"title": title,
		"weight": 1.0,
		"negative": negative,
		"duration_days_min": min_days,
		"duration_days_max": max_days,
		"fog_flag": kind == MarketEvent.KIND_FOG,
	}
