class_name RegularsReturnPolicy
extends RefCounted

## systems §5.1 Regular / §5.3 band 50–74. Integer gate: Rep ≥ 50 can
## queue a next-floor Regular after a listed-price sale. Rep ≤ 49 cannot.
const UNLOCK_REP := 50
## One queued return. A second listed sale the same day does not add another.
const QUEUE_CAP := 1
## Existing Regular archetype. No new want table.
const ARCHETYPE_ID := &"regular"


static func unlock_rep(configured: int = UNLOCK_REP) -> int:
	if configured <= 0:
		return UNLOCK_REP
	return configured


static func queue_cap(configured: int = QUEUE_CAP) -> int:
	if configured <= 0:
		return QUEUE_CAP
	return configured


static func is_unlocked(reputation: int, configured_unlock: int = UNLOCK_REP) -> bool:
	return reputation >= unlock_rep(configured_unlock)


static func can_queue(
	reputation: int,
	queued: int,
	configured_unlock: int = UNLOCK_REP,
	configured_cap: int = QUEUE_CAP
) -> bool:
	return (
		is_unlocked(reputation, configured_unlock)
		and queued < queue_cap(configured_cap)
	)
