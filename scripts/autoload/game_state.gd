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
	is_game_active = true
	Economy.reset()
	InventoryService.reset()
	DemandSignals.reset()
	BeatDirector.reset()
	QaInstrumentation.begin_day(current_day, Economy.balance_cents)
	EventBus.day_started.emit(current_day)
	EventBus.reputation_changed.emit(current_reputation)
	EventBus.attention_changed.emit(attention_remaining)
	EventBus.day_phase_changed.emit(current_phase)


func start_floor() -> bool:
	if not is_game_active or not DayPhasePolicy.can_start_floor(current_phase):
		return false
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
	QaInstrumentation.begin_day(current_day, Economy.balance_cents)
	EventBus.day_started.emit(current_day)
	EventBus.attention_changed.emit(attention_remaining)
	EventBus.day_phase_changed.emit(current_phase)
	return true


func spend_attention(amount: int) -> bool:
	if (
		current_phase != DayPhase.FLOOR
		or amount <= 0
		or amount > attention_remaining
	):
		return false
	attention_remaining -= amount
	EventBus.attention_changed.emit(attention_remaining)
	return true


func adjust_reputation(delta: int) -> void:
	current_reputation = clampi(current_reputation + delta, 0, 100)
	EventBus.reputation_changed.emit(current_reputation)


func return_to_menu() -> void:
	if is_game_active:
		QaInstrumentation.end_day(current_day, Economy.balance_cents)
	is_game_active = false
