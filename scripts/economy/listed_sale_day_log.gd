class_name ListedSaleDayLog
extends RefCounted

## BK1: calendar-day flags for completed listed-price sales (in-shop list
## and filled online holds). Refuses, walkouts, cancels, and failed
## haggles never land here. Settle consumes the flags once.
const SAVE_HAD_FAIR_KEY := "had_fair"
const SAVE_HAD_GOUGE_KEY := "had_gouge"
const SAVE_SETTLE_APPLIED_KEY := "settle_applied"

var had_fair: bool = false
var had_gouge: bool = false
var settle_applied: bool = false


func reset() -> void:
	had_fair = false
	had_gouge = false
	settle_applied = false


func note_completed_sale(
	ask_cents: int,
	suggested_cents: int,
	config: BalanceConfig = null
) -> void:
	if settle_applied:
		return
	if FairPriceSettlePolicy.is_gouge_for(ask_cents, suggested_cents, config):
		had_gouge = true
		return
	if FairPriceSettlePolicy.is_fair_for(ask_cents, suggested_cents, config):
		had_fair = true


func settle_rep_delta(config: BalanceConfig = null) -> int:
	if settle_applied:
		return 0
	settle_applied = true
	return FairPriceSettlePolicy.settle_rep_delta(had_fair, had_gouge, config)


func snapshot() -> Dictionary:
	return {
		SAVE_HAD_FAIR_KEY: had_fair,
		SAVE_HAD_GOUGE_KEY: had_gouge,
		SAVE_SETTLE_APPLIED_KEY: settle_applied,
	}


func apply_save(data: Dictionary) -> void:
	if data.is_empty():
		reset()
		return
	had_fair = bool(data.get(SAVE_HAD_FAIR_KEY, false))
	had_gouge = bool(data.get(SAVE_HAD_GOUGE_KEY, false))
	settle_applied = bool(data.get(SAVE_SETTLE_APPLIED_KEY, false))
