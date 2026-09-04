class_name MarketEventService
extends RefCounted

const CATALOG_PATH := "res://data/events.json"
const EVENT_RNG_SEED := 20260904
const FOG_SIGMA_MULT := 1.5
const HYPE_MARKET_MULT := 1.35
const HYPE_DEMAND_SCORE := 0.95
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


func roll_definition(config: BalanceConfig) -> Dictionary:
	var total := 0.0
	var weighted: Array[Dictionary] = []
	for def: Dictionary in defs:
		var weight := _weight_for(def, config)
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


func roll_duration(def: Dictionary) -> int:
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


func _weight_for(def: Dictionary, config: BalanceConfig) -> float:
	var weight := float(def.get("weight", 1.0))
	if bool(def.get("negative", false)) and config != null:
		weight *= config.negative_event_weight_mult
	return maxf(0.0, weight)


func _load_catalog() -> void:
	defs.clear()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if parsed is Dictionary:
		for entry_value: Variant in (parsed as Dictionary).get("events", []):
			if entry_value is Dictionary:
				defs.append(entry_value as Dictionary)
	if defs.size() >= 3:
		return
	defs = [
		_fallback_def(&"hype_spike", "Hype spike", false, 1, 3),
		_fallback_def(&"soft_rotation_leak", "Soft rotation leak", true, 1, 3),
		_fallback_def(&"fog_day", "Fog day", true, 1, 1),
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
