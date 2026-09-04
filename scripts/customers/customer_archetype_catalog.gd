class_name CustomerArchetypeCatalog
extends RefCounted

const DATA_PATH := "res://data/customers.json"

var archetypes: Array[Dictionary] = []


func _init(data_path: String = DATA_PATH) -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(data_path))
	if not parsed is Dictionary:
		push_error("Could not load customer archetypes.")
		return
	for value: Variant in (parsed as Dictionary).get("archetypes", []):
		if value is Dictionary:
			archetypes.append((value as Dictionary).duplicate(true))


func total_weight(
	reputation: int,
	config: BalanceConfig
) -> float:
	var total := 0.0
	for archetype: Dictionary in archetypes:
		total += weight_for(archetype, reputation, config)
	return total


func weight_for(
	archetype: Dictionary,
	reputation: int,
	config: BalanceConfig
) -> float:
	var weight := float(archetype.get("weight_normal", 0.0))
	var band_key := "reputation_weight_mid"
	if reputation < 25:
		band_key = "reputation_weight_low"
	elif reputation >= 75:
		band_key = "reputation_weight_high"
	weight *= float(archetype.get(band_key, 1.0))
	var archetype_id := StringName(archetype.get("id", ""))
	if archetype_id == &"whale":
		weight *= config.whale_weight_mult
	elif archetype_id == &"flipper":
		weight *= config.flipper_weight_mult
	return maxf(0.0, weight)


func pick_weighted(
	reputation: int,
	config: BalanceConfig,
	rng: RandomNumberGenerator
) -> Dictionary:
	var total := total_weight(reputation, config)
	if total <= 0.0:
		return {}
	var roll := rng.randf() * total
	for archetype: Dictionary in archetypes:
		roll -= weight_for(archetype, reputation, config)
		if roll <= 0.0:
			return archetype.duplicate(true)
	return archetypes.back().duplicate(true)
