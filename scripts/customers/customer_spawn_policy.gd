class_name CustomerSpawnPolicy
extends RefCounted

const FLOOR_PHASE := 1
## systems §5.3 band 0–24. Integer gate: Rep ≤ 24 is quiet, Rep ≥ 25 is baseline.
const QUIET_FLOOR_MAX_REP := 24
const QUIET_FLOOR_COUNT_MULT := 0.5
## One customer per live timer roll. Quiet floor halves this (round down, floor 0).
const BASELINE_SPAWN_COUNT := 1


static func can_spawn(phase: int) -> bool:
	return phase == FLOOR_PHASE


static func is_quiet_floor(reputation: int) -> bool:
	return reputation <= QUIET_FLOOR_MAX_REP


## Spawn count for one roll. Rep is read here, not cached across rolls.
## Quiet floor (≤24) is ×0.5 versus the same baseline at Rep ≥ 25,
## rounded down, floor 0. This is traffic, not a sell weight.
static func spawn_count(
	reputation: int,
	baseline_count: int = BASELINE_SPAWN_COUNT
) -> int:
	if baseline_count <= 0:
		return 0
	if is_quiet_floor(reputation):
		return int(floor(float(baseline_count) * QUIET_FLOOR_COUNT_MULT))
	return baseline_count


static func whales_allowed(reputation: int) -> bool:
	return not is_quiet_floor(reputation)
