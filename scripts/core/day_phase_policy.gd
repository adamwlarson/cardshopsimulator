class_name DayPhasePolicy
extends RefCounted

const PREP := 0
const FLOOR := 1
const SETTLE := 2


static func can_start_floor(current_phase: int) -> bool:
	return current_phase == PREP


static func can_start_settle(current_phase: int) -> bool:
	return current_phase == FLOOR


static func can_advance_day(current_phase: int) -> bool:
	return current_phase == SETTLE
