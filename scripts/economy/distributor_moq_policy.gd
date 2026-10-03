class_name DistributorMoqPolicy
extends RefCounted

## systems §5.3 band 0–24. Integer gate: Rep ≤ 24 doubles today's
## distributor minimum. Rep ≥ 25 keeps today's MOQ. Not a price change
## and not a door-spawn change.
const QUIET_FLOOR_MAX_REP := 24
const QUIET_FLOOR_MOQ_MULT := 2.0


static func is_worse_moq(reputation: int) -> bool:
	return reputation <= QUIET_FLOOR_MAX_REP


static func moq_mult(configured: float = QUIET_FLOOR_MOQ_MULT) -> float:
	if configured <= 0.0:
		return QUIET_FLOOR_MOQ_MULT
	return configured


static func minimum_units(
	today_moq: int,
	reputation: int,
	configured_mult: float = QUIET_FLOOR_MOQ_MULT
) -> int:
	if today_moq <= 0:
		return 0
	if not is_worse_moq(reputation):
		return today_moq
	return maxi(1, roundi(float(today_moq) * moq_mult(configured_mult)))


static func meets_minimum(
	today_moq: int,
	count: int,
	reputation: int,
	configured_mult: float = QUIET_FLOOR_MOQ_MULT
) -> bool:
	return count >= minimum_units(today_moq, reputation, configured_mult)
