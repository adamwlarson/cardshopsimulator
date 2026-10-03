class_name AuctionSnipePolicy
extends RefCounted

## systems §3 auction snipes. Prep-only timed lot. Seeded flag can
## offer exactly one snipe. A live named settle event forces the
## flag on for that prep. Quiet days use the seeded flag alone.
const RUN_SEED := 20261003
const ATTENTION_COST := 10
const COMP_WIDTH := 0.12
const ASK_OFFSET_MIN := 0.05
const ASK_OFFSET_MAX := 0.16
const OFFER_PREFIX := "auction-snipe-day-"
const DEFAULT_SKU_ID := &"AA-DUST-ETB"
const OFFER_LABEL := "Auction snipe"
const CONDITION_CUE := "Photo only — inspect recommended"
const CONFIDENCE := &"medium"


static func attention_cost(configured: int = 0) -> int:
	if configured <= 0:
		return ATTENTION_COST
	return configured


static func comp_width(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return COMP_WIDTH
	return configured


static func offer_id(day: int) -> StringName:
	return StringName("%s%d" % [OFFER_PREFIX, maxi(1, day)])


static func is_snipe_id(opportunity_id: StringName) -> bool:
	return String(opportunity_id).begins_with(OFFER_PREFIX)


static func flag_on(seed: int, day: int) -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, 0)
	return rng.randi() % 2 == 0


static func should_offer(seed: int, day: int, named_event_live: bool) -> bool:
	if named_event_live:
		return true
	return flag_on(seed, day)


static func noisy_basis_cents(
	basis_cents: int,
	seed: int,
	day: int,
	configured_width: float = 0.0
) -> int:
	if basis_cents <= 0:
		return 0
	var width := comp_width(configured_width)
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, 1)
	var noise := rng.randf_range(-width, width)
	return maxi(1, roundi(float(basis_cents) * (1.0 + noise)))


static func ask_cents(
	basis_cents: int,
	seed: int,
	day: int,
	configured_width: float = 0.0
) -> int:
	var noisy := noisy_basis_cents(basis_cents, seed, day, configured_width)
	if noisy <= 0:
		return 0
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, 2)
	var over := rng.randf() >= 0.5
	var delta := rng.randf_range(ASK_OFFSET_MIN, ASK_OFFSET_MAX)
	var factor := 1.0 + delta if over else 1.0 - delta
	return maxi(1, roundi(float(noisy) * factor))


static func _mix(seed: int, day: int, lane: int) -> int:
	var mixed := (int(seed) * 1664525) ^ (int(day) * 22695477) ^ (int(lane) * 1013904223)
	return mixed & 0x7fffffff
