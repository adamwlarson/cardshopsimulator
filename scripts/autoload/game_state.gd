extends Node

const FIRST_DAY := 1
const NORMAL_BALANCE_CONFIG: BalanceConfig = preload("res://data/balance/normal.tres")

enum DayPhase {
	PREP,
	FLOOR,
	SETTLE,
}

var current_day: int = FIRST_DAY
var current_reputation: int = 0
var is_game_active: bool = false
var balance_config: BalanceConfig = NORMAL_BALANCE_CONFIG
var current_phase: DayPhase = DayPhase.PREP
var attention_remaining: int = NORMAL_BALANCE_CONFIG.attention_pool
var shop := ShopState.new()
var pending_floor_skip_seconds: float = 0.0


func set_balance_config(config: BalanceConfig) -> void:
	if config == null:
		push_error("BalanceConfig cannot be null.")
		return
	balance_config = config


func start_new_game() -> void:
	current_day = FIRST_DAY
	current_reputation = balance_config.start_reputation
	current_phase = DayPhase.PREP
	attention_remaining = balance_config.attention_pool
	pending_floor_skip_seconds = 0.0
	is_game_active = true
	shop.reset(balance_config)
	Economy.reset()
	InventoryService.reset()
	DemandSignals.reset()
	BeatDirector.reset()
	QaInstrumentation.begin_day(current_day, Economy.balance_cents)
	EventBus.day_started.emit(current_day)
	EventBus.reputation_changed.emit(current_reputation)
	EventBus.attention_changed.emit(attention_remaining)
	EventBus.day_phase_changed.emit(current_phase)
	EventBus.shop_layout_changed.emit()


func start_floor() -> bool:
	if not is_game_active or not DayPhasePolicy.can_start_floor(current_phase):
		return false
	var noshows := shop.roll_floor_attendance()
	if noshows > 0:
		QaInstrumentation.record_staff_noshow({
			"day": current_day,
			"noshow_count": noshows,
			"cashier_count": shop.cashier_count(),
			"on_duty": shop.cashiers_on_duty_count(),
			"understaffed": shop.is_floor_understaffed(),
		})
	current_phase = DayPhase.FLOOR
	EventBus.day_phase_changed.emit(current_phase)
	return true


func start_settle() -> bool:
	if not is_game_active or not DayPhasePolicy.can_start_settle(current_phase):
		return false
	current_phase = DayPhase.SETTLE
	Economy.settle_day(current_day)
	EventBus.day_phase_changed.emit(current_phase)
	return true


func advance_day() -> bool:
	if not is_game_active or not DayPhasePolicy.can_advance_day(current_phase):
		return false
	QaInstrumentation.end_day(current_day, Economy.balance_cents)
	current_day += 1
	current_phase = DayPhase.PREP
	attention_remaining = balance_config.attention_pool
	pending_floor_skip_seconds = 0.0
	shop.reset_daily_attendance()
	QaInstrumentation.begin_day(current_day, Economy.balance_cents)
	EventBus.day_started.emit(current_day)
	EventBus.attention_changed.emit(attention_remaining)
	EventBus.day_phase_changed.emit(current_phase)
	return true


func spend_attention(amount: int) -> bool:
	if current_phase != DayPhase.FLOOR:
		return false
	return consume_attention(amount)


func consume_attention(amount: int) -> bool:
	if not is_game_active or amount <= 0 or amount > attention_remaining:
		return false
	attention_remaining -= amount
	EventBus.attention_changed.emit(attention_remaining)
	return true


func can_research() -> bool:
	# HOLD H1: Att-0 fold — same gate as other owner Att verbs.
	return (
		is_game_active
		and current_phase in [DayPhase.PREP, DayPhase.FLOOR]
		and attention_remaining >= shop.research_attention_cost()
	)


func can_inspect() -> bool:
	return (
		is_game_active
		and attention_remaining >= shop.inspect_attention_cost()
	)


func can_negotiate() -> bool:
	return (
		is_game_active
		and current_phase == DayPhase.FLOOR
		and attention_remaining >= CustomerQueue.NEGOTIATE_ATTENTION_COST
	)


func can_pull() -> bool:
	return (
		is_game_active
		and current_phase == DayPhase.FLOOR
		and attention_remaining >= shop.pull_attention_cost()
	)


func can_rearrange() -> bool:
	return is_game_active and current_phase == DayPhase.PREP


func rearrange_fixture(fixture_id: StringName, new_origin: Vector2i) -> Dictionary:
	var cost := shop.rearrange_attention_cost()
	if not can_rearrange():
		return _rearrange_result(false, &"wrong_phase", fixture_id, new_origin, 0)
	if attention_remaining < cost:
		return _rearrange_result(false, &"insufficient_attention", fixture_id, new_origin, 0)
	var reason := shop.layout.preview_move(fixture_id, new_origin)
	if reason != &"ok":
		var rejected := _rearrange_result(false, reason, fixture_id, new_origin, 0)
		QaInstrumentation.record_rearrange_attempted(rejected)
		return rejected
	if not consume_attention(cost):
		return _rearrange_result(false, &"insufficient_attention", fixture_id, new_origin, 0)
	shop.layout.apply_move(fixture_id, new_origin)
	var applied := _rearrange_result(true, &"ok", fixture_id, new_origin, cost)
	QaInstrumentation.record_rearrange_attempted(applied)
	return applied


func _rearrange_result(
	ok: bool,
	reason: StringName,
	fixture_id: StringName,
	new_origin: Vector2i,
	attention_spent: int
) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"fixture_id": String(fixture_id),
		"origin_x": new_origin.x,
		"origin_y": new_origin.y,
		"attention_spent": attention_spent,
		"attention_remaining": attention_remaining,
		"has_circulation": shop.layout.has_circulation(),
	}


func is_night_prep() -> bool:
	return is_game_active and current_phase == DayPhase.PREP


func queue_floor_skip(seconds: float) -> void:
	if seconds <= 0.0:
		return
	pending_floor_skip_seconds += seconds


func consume_floor_skip() -> float:
	var skip := pending_floor_skip_seconds
	pending_floor_skip_seconds = 0.0
	return skip


func adjust_reputation(delta: int) -> void:
	current_reputation = clampi(current_reputation + delta, 0, 100)
	EventBus.reputation_changed.emit(current_reputation)


func return_to_menu() -> void:
	if is_game_active:
		QaInstrumentation.end_day(current_day, Economy.balance_cents)
	is_game_active = false


func capture_save() -> Dictionary:
	var inventory := {
		"case_slot_bonus": 0,
		"backstock_bin_bonus": 0,
	}
	if InventoryService.model != null:
		inventory["case_slot_bonus"] = InventoryService.model.case_slot_bonus
		inventory["backstock_bin_bonus"] = InventoryService.model.backstock_bin_bonus
	var payload := {
		"version": 1,
		"day": current_day,
		"reputation": current_reputation,
		"phase": int(current_phase),
		"attention_remaining": attention_remaining,
		"pending_floor_skip_seconds": pending_floor_skip_seconds,
		"shop": shop.to_save(),
		"inventory": inventory,
		"market_event": DemandSignals.event_to_save(),
	}
	var serialized := JSON.stringify(payload).to_utf8_buffer()
	QaInstrumentation.record_save_pre_write(serialized)
	return payload


func restore_save(data: Dictionary) -> bool:
	if data.is_empty() or int(data.get("version", 0)) != 1:
		return false
	if not data.has("shop") or not data.get("shop") is Dictionary:
		return false
	is_game_active = true
	current_day = int(data.get("day", FIRST_DAY))
	current_reputation = int(data.get("reputation", 0))
	current_phase = int(data.get("phase", DayPhase.PREP)) as DayPhase
	attention_remaining = int(
		data.get("attention_remaining", balance_config.attention_pool)
	)
	pending_floor_skip_seconds = float(data.get("pending_floor_skip_seconds", 0.0))
	shop.apply_save(data.get("shop", {}), balance_config)
	var inventory: Dictionary = data.get("inventory", {})
	InventoryService.apply_medium_capacity(
		int(inventory.get("case_slot_bonus", 0)),
		int(inventory.get("backstock_bin_bonus", 0))
	)
	var market_event: Variant = data.get("market_event", {})
	if market_event is Dictionary:
		DemandSignals.apply_event_save(market_event as Dictionary)
	else:
		DemandSignals.apply_event_save({})
	var serialized := JSON.stringify(data).to_utf8_buffer()
	QaInstrumentation.record_save_post_load(serialized)
	EventBus.reputation_changed.emit(current_reputation)
	EventBus.attention_changed.emit(attention_remaining)
	EventBus.day_phase_changed.emit(current_phase)
	EventBus.shop_layout_changed.emit()
	return true
