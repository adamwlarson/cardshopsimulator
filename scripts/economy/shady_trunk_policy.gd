class_name ShadyTrunkPolicy
extends RefCounted

## systems §3 shady trunk. Prep-only night lot. A seeded night flag
## can offer exactly one trunk. No flag → no trunk that night.
## Ask is 25% of the same live basis today's marketplace leads use.
## Report is Rep +2 once. Graded lots on this channel can be fake at 8%.
const RUN_SEED := 20261003
const ASK_RATE := 0.25
const REPORT_REP_GAIN := 2
const FAKE_SLAB_RATE := 0.08
const COMP_WIDTH := 0.22
const SPACE_REQUIRED := 2
const DEFAULT_GRADE := 10.0
const OFFER_PREFIX := "shady-trunk-day-"
const DEFAULT_SKU_ID := &"AA-SKIE-052"
const DEFAULT_GRADER := &"Prism"
const OFFER_LABEL := "Trunk lot"
const CONDITION_CUE := "Photo only — inspect strongly recommended"
const CONFIDENCE := &"low"


static func ask_rate(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return ASK_RATE
	return configured


static func report_rep_gain(configured: int = 0) -> int:
	if configured <= 0:
		return REPORT_REP_GAIN
	return configured


static func fake_slab_rate(configured: float = -1.0) -> float:
	if configured < 0.0:
		return FAKE_SLAB_RATE
	return configured


static func comp_width(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return COMP_WIDTH
	return configured


static func offer_id(day: int) -> StringName:
	return StringName("%s%d" % [OFFER_PREFIX, maxi(1, day)])


static func is_trunk_id(opportunity_id: StringName) -> bool:
	return String(opportunity_id).begins_with(OFFER_PREFIX)


static func flag_on(seed: int, day: int) -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, 0)
	return rng.randi() % 2 == 0


static func should_offer(seed: int, day: int) -> bool:
	return flag_on(seed, day)


static func ask_cents(basis_cents: int, configured_rate: float = 0.0) -> int:
	if basis_cents <= 0:
		return 0
	return maxi(1, roundi(float(basis_cents) * ask_rate(configured_rate)))


static func _mix(seed: int, day: int, lane: int) -> int:
	var mixed := (
		(int(seed) * 22695477)
		^ (int(day) * 1013904223)
		^ (int(lane) * 1664525)
		^ 0x5f3759df
	)
	return mixed & 0x7fffffff
