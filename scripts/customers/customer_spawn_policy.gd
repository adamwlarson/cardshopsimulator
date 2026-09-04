class_name CustomerSpawnPolicy
extends RefCounted

const FLOOR_PHASE := 1


static func can_spawn(phase: int) -> bool:
	return phase == FLOOR_PHASE
