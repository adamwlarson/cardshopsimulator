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
	config: BalanceConfig,
	event_whale_mult: float = 1.0,
	event_buylist_mult: float = 1.0
) -> float:
	var total := 0.0
	for archetype: Dictionary in archetypes:
		total += weight_for(
			archetype,
			reputation,
			config,
			event_whale_mult,
			event_buylist_mult
		)
	return total


func weight_for(
	archetype: Dictionary,
	reputation: int,
	config: BalanceConfig,
	event_whale_mult: float = 1.0,
	event_buylist_mult: float = 1.0
) -> float:
	var archetype_id := StringName(archetype.get("id", ""))
	# AI1: quiet floor zeros whale weight before Convention / play-table bumps.
	# High band (75–100) stays the shipped mid/high table. Not a sell weight.
	if archetype_id == &"whale" and not CustomerSpawnPolicy.whales_allowed(reputation):
		return 0.0
	var weight := float(archetype.get("weight_normal", 0.0))
	var band_key := "reputation_weight_mid"
	if CustomerSpawnPolicy.is_quiet_floor(reputation):
		band_key = "reputation_weight_low"
	elif reputation >= 75:
		band_key = "reputation_weight_high"
	weight *= float(archetype.get(band_key, 1.0))
	if archetype_id == &"whale":
		weight *= config.whale_weight_mult * maxf(0.0, event_whale_mult)
	elif archetype_id == &"flipper":
		weight *= config.flipper_weight_mult * maxf(0.0, event_buylist_mult)
	return maxf(0.0, weight)


## Seeded spawn roll: same seed + same baseline, Rep read at the roll.
## Quiet floor yields floor(baseline × 0.5) archetypes and never a whale.
func roll_spawn(
	seed: int,
	reputation: int,
	config: BalanceConfig,
	baseline_count: int,
	event_whale_mult: float = 1.0,
	event_buylist_mult: float = 1.0
) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var count := CustomerSpawnPolicy.spawn_count(reputation, baseline_count)
	var rolled: Array[Dictionary] = []
	for _i in count:
		var archetype := pick_weighted(
			reputation,
			config,
			rng,
			event_whale_mult,
			event_buylist_mult
		)
		if not archetype.is_empty():
			rolled.append(archetype)
	return rolled


func pick_weighted(
	reputation: int,
	config: BalanceConfig,
	rng: RandomNumberGenerator,
	event_whale_mult: float = 1.0,
	event_buylist_mult: float = 1.0
) -> Dictionary:
	var total := total_weight(
		reputation,
		config,
		event_whale_mult,
		event_buylist_mult
	)
	if total <= 0.0:
		return {}
	var roll := rng.randf() * total
	for archetype: Dictionary in archetypes:
		roll -= weight_for(
			archetype,
			reputation,
			config,
			event_whale_mult,
			event_buylist_mult
		)
		if roll <= 0.0:
			return archetype.duplicate(true)
	return archetypes.back().duplicate(true)
