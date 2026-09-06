extends Node

const FIRST_DAY := 1
const NORMAL_BALANCE_CONFIG: BalanceConfig = preload("res://data/balance/normal.tres")
const FLAGSHIP_MODE := &"flagship"
const SURVIVE_Y1_MODE := &"survive_y1"
const LIQUIDITY_KING_MODE := &"liquidity_king"

enum DayPhase {
	PREP,
	FLOOR,
	SETTLE,
}

enum CampaignMode {
	FLAGSHIP,
	SURVIVE_Y1,
	LIQUIDITY_KING,
	SANDBOX,
}

var current_day: int = FIRST_DAY
var current_reputation: int = 0
var is_game_active: bool = false
var balance_config: BalanceConfig = NORMAL_BALANCE_CONFIG
var current_phase: DayPhase = DayPhase.PREP
var attention_remaining: int = NORMAL_BALANCE_CONFIG.attention_pool
var shop := ShopState.new()
var pending_floor_skip_seconds: float = 0.0
var campaign_mode: CampaignMode = CampaignMode.FLAGSHIP
var campaign_complete: bool = false
var last_prestige: StringName = &""
var sandbox_best_day: int = 0
var sandbox_best_cash_cents: int = 0
var _win_signals_bound: bool = false


func _ready() -> void:
	_ensure_win_signals()


func _ensure_win_signals() -> void:
	if _win_signals_bound:
		return
	if not EventBus.cash_changed.is_connected(_on_cash_changed_maybe_win):
		EventBus.cash_changed.connect(_on_cash_changed_maybe_win)
	if not EventBus.shop_layout_changed.is_connected(_on_layout_changed_maybe_win):
		EventBus.shop_layout_changed.connect(_on_layout_changed_maybe_win)
	_win_signals_bound = true


func set_balance_config(config: BalanceConfig) -> void:
	if config == null:
		push_error("BalanceConfig cannot be null.")
		return
	balance_config = config


func start_new_game() -> void:
	_ensure_win_signals()
	current_day = FIRST_DAY
	current_reputation = balance_config.start_reputation
	current_phase = DayPhase.PREP
	attention_remaining = balance_config.attention_pool
	pending_floor_skip_seconds = 0.0
	campaign_complete = false
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
	_record_sandbox_personal_bests()


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
	evaluate_campaign_win()
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
	# Survive Y1 can first become true on the day-365 PREP landing.
	evaluate_campaign_win()
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
	evaluate_campaign_win()


func meets_flagship() -> bool:
	if shop == null or balance_config == null:
		return false
	return balance_config.meets_flagship(
		int(shop.tier),
		current_reputation,
		Economy.balance_cents
	)


func meets_survive_y1() -> bool:
	if balance_config == null:
		return false
	return balance_config.meets_survive_y1(
		current_day,
		current_reputation,
		Economy.balance_cents
	)


func meets_liquidity_king() -> bool:
	# Liquidity king is a month-end SETTLE snapshot, not a mid-month cash spike.
	if balance_config == null or current_phase != DayPhase.SETTLE:
		return false
	return balance_config.meets_liquidity_king(current_day, Economy.balance_cents)


func select_campaign_mode(mode: CampaignMode) -> bool:
	# Mid-run switch is out of scope. Menu / new-game only.
	if is_game_active:
		return false
	campaign_mode = mode
	return true


func campaign_id(mode: CampaignMode) -> StringName:
	match mode:
		CampaignMode.SURVIVE_Y1:
			return SURVIVE_Y1_MODE
		CampaignMode.LIQUIDITY_KING:
			return LIQUIDITY_KING_MODE
		CampaignMode.SANDBOX:
			return &"sandbox"
		_:
			return FLAGSHIP_MODE


func campaign_mode_id() -> StringName:
	return campaign_id(campaign_mode)


func campaign_title(mode: StringName) -> String:
	match mode:
		SURVIVE_Y1_MODE:
			return "Survive Year 1"
		LIQUIDITY_KING_MODE:
			return "Liquidity king"
		&"sandbox":
			return "Sandbox"
		_:
			return "Flagship"


func campaign_goal_copy(mode: StringName = &"") -> String:
	var resolved := mode if not mode.is_empty() else campaign_mode_id()
	match resolved:
		SURVIVE_Y1_MODE:
			return "Reach day 365 with cash on hand and a solid reputation."
		LIQUIDITY_KING_MODE:
			return "Close any month with a towering cash pile."
		&"sandbox":
			return "No win condition. Chase personal bests."
		_:
			return "Own a Large shop, hit high reputation, and bank a deep reserve."


func campaign_win_payload() -> Dictionary:
	var tier := 0
	if shop != null:
		tier = int(shop.tier)
	var mode := last_prestige
	if mode.is_empty():
		mode = campaign_mode_id()
	return {
		"mode": String(mode),
		"day": current_day,
		"cash_cents": Economy.balance_cents,
		"reputation": current_reputation,
		"shop_tier": tier,
	}


func evaluate_campaign_win() -> bool:
	# Campaign mode select (not multi-goal): only the selected CampaignMode can
	# award. Distinct win kinds (flagship / survive_y1 / liquidity_king) keep
	# prestige from colliding. Sandbox never awards. Flagship branch is unchanged.
	_ensure_win_signals()
	if campaign_complete or not is_game_active:
		return false
	match campaign_mode:
		CampaignMode.FLAGSHIP:
			if not meets_flagship():
				return false
			return _award_campaign(FLAGSHIP_MODE)
		CampaignMode.SURVIVE_Y1:
			if not meets_survive_y1():
				return false
			return _award_campaign(SURVIVE_Y1_MODE)
		CampaignMode.LIQUIDITY_KING:
			if not meets_liquidity_king():
				return false
			return _award_campaign(LIQUIDITY_KING_MODE)
		_:
			_record_sandbox_personal_bests()
			return false


func _record_sandbox_personal_bests() -> void:
	if campaign_mode != CampaignMode.SANDBOX:
		return
	sandbox_best_day = maxi(sandbox_best_day, current_day)
	sandbox_best_cash_cents = maxi(sandbox_best_cash_cents, Economy.balance_cents)


func _award_campaign(mode: StringName) -> bool:
	campaign_complete = true
	last_prestige = mode
	is_game_active = false
	var payload := campaign_win_payload()
	QaInstrumentation.record_campaign_won(payload)
	EventBus.campaign_won.emit(payload)
	return true


func _award_flagship() -> bool:
	return _award_campaign(FLAGSHIP_MODE)


func _on_cash_changed_maybe_win(_balance_cents: int) -> void:
	if current_phase == DayPhase.SETTLE:
		return
	evaluate_campaign_win()


func _on_layout_changed_maybe_win() -> void:
	evaluate_campaign_win()


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
		"campaign_mode": int(campaign_mode),
		"campaign_complete": campaign_complete,
		"last_prestige": String(last_prestige),
		"sandbox_best_day": sandbox_best_day,
		"sandbox_best_cash_cents": sandbox_best_cash_cents,
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
	campaign_mode = int(data.get("campaign_mode", CampaignMode.FLAGSHIP)) as CampaignMode
	campaign_complete = bool(data.get("campaign_complete", false))
	sandbox_best_day = int(data.get("sandbox_best_day", sandbox_best_day))
	sandbox_best_cash_cents = int(data.get("sandbox_best_cash_cents", sandbox_best_cash_cents))
	var saved_prestige := StringName(data.get("last_prestige", &""))
	if not saved_prestige.is_empty():
		last_prestige = saved_prestige
	shop.apply_save(data.get("shop", {}), balance_config)
	var inventory: Dictionary = data.get("inventory", {})
	InventoryService.apply_shop_capacity_bonuses(
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
	if campaign_complete:
		is_game_active = false
	else:
		evaluate_campaign_win()
	return true
