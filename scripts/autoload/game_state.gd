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
var sandbox_best_net_worth_cents: int = 0
var campaign_lost: bool = false
var last_lose_reason: StringName = &""
var loan_shark_recovery_used: bool = false
var loan_shark_offer_pending: bool = false
## Z1 opt-in. Default off on Easy/Normal/Hard. Menu / new-game only.
var ironman_enabled: bool = false
var missed_rent_weeks: int = 0
var last_fire_rep_delta: int = 0
var last_register_walkout_rep_delta: int = 0
var register_walkout_count_today: int = 0
var register_walkout_rep_spent_today: int = 0
var last_nm_mismatch_sale: bool = false
var last_nm_mismatch_refund_cents: int = 0
var last_nm_mismatch_rep_delta: int = 0
var last_fair_price_settle_rep_delta: int = 0
var listed_sale_log := ListedSaleDayLog.new()
var last_buylist_drip_rep_delta: int = 0
var buylist_drip_applied: bool = false
var buylist_pcts := BuylistPctSettings.new()
## BN1/BO1: that day's seller-lot / seller-walk-in weight. 1.0 until open.
## Starve is < 1.0; flood is > 1.0. They never stack the same day.
var seller_lots_weight_mult: float = 1.0
var _unpaid_wages_this_settle: bool = false
var _suppress_lose_eval: bool = false
var _suppress_sandbox_bests: bool = false
var _win_signals_bound: bool = false


func _ready() -> void:
	_ensure_win_signals()


func _ensure_win_signals() -> void:
	if _win_signals_bound:
		return
	if not EventBus.cash_changed.is_connected(_on_cash_changed_maybe_win):
		EventBus.cash_changed.connect(_on_cash_changed_maybe_win)
	if not EventBus.inventory_changed.is_connected(_on_inventory_changed_maybe_bests):
		EventBus.inventory_changed.connect(_on_inventory_changed_maybe_bests)
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
	campaign_lost = false
	last_lose_reason = &""
	loan_shark_recovery_used = false
	loan_shark_offer_pending = false
	missed_rent_weeks = 0
	last_fire_rep_delta = 0
	last_register_walkout_rep_delta = 0
	register_walkout_count_today = 0
	register_walkout_rep_spent_today = 0
	clear_last_nm_mismatch()
	last_fair_price_settle_rep_delta = 0
	listed_sale_log.reset()
	last_buylist_drip_rep_delta = 0
	buylist_drip_applied = false
	buylist_pcts.reset()
	seller_lots_weight_mult = 1.0
	_unpaid_wages_this_settle = false
	_suppress_lose_eval = false
	_suppress_sandbox_bests = true
	is_game_active = true
	shop.reset(balance_config)
	Economy.reset()
	InventoryService.reset()
	DemandSignals.reset()
	_suppress_sandbox_bests = false
	BeatDirector.reset()
	QaInstrumentation.begin_day(current_day, Economy.balance_cents)
	EventBus.day_started.emit(current_day)
	EventBus.reputation_changed.emit(current_reputation)
	EventBus.attention_changed.emit(attention_remaining)
	EventBus.day_phase_changed.emit(current_phase)
	EventBus.shop_layout_changed.emit()
	_record_sandbox_personal_bests()


func start_floor() -> bool:
	if not can_progress_day() or not DayPhasePolicy.can_start_floor(current_phase):
		return false
	var noshows := shop.roll_floor_attendance()
	shop.tick_roster_age()
	if noshows > 0:
		QaInstrumentation.record_staff_noshow({
			"day": current_day,
			"noshow_count": noshows,
			"cashier_count": shop.cashier_count(),
			"on_duty": shop.cashiers_on_duty_count(),
			"understaffed": shop.is_floor_understaffed(),
		})
	_run_stocker_restock()
	apply_buylist_fewer_lots_at_open()
	apply_buylist_flood_at_open()
	current_phase = DayPhase.FLOOR
	EventBus.day_phase_changed.emit(current_phase)
	_release_queued_regular_return()
	return true


func _release_queued_regular_return() -> void:
	# AO1: one-shot Regular after a listed-price sale at Rep ≥ 50.
	# Separate from the door roll. Spawn count and whale weight stay shipped.
	var returning := DemandSignals.take_regular_return()
	if returning == null:
		return
	EventBus.scripted_customer_requested.emit(returning)


func _run_stocker_restock() -> int:
	# AF1: one restock pass at floor open, after attendance. No Stocker
	# on duty → no auto-restock. Owner rearrange stays a manual verb.
	var restock := StockerRestock.new()
	shop.last_stocker_restock_count = restock.apply(shop)
	return shop.last_stocker_restock_count


func start_settle() -> bool:
	if not can_progress_day() or not DayPhasePolicy.can_start_settle(current_phase):
		return false
	current_phase = DayPhase.SETTLE
	Economy.settle_day(current_day)
	EventBus.day_phase_changed.emit(current_phase)
	evaluate_campaign_win()
	evaluate_campaign_lose()
	return true


func advance_day() -> bool:
	if not can_progress_day() or not DayPhasePolicy.can_advance_day(current_phase):
		return false
	QaInstrumentation.end_day(current_day, Economy.balance_cents)
	current_day += 1
	# BL1: day id flip drops cached noisy suggested so PREP/HUD re-derives.
	DemandSignals.clear_cached_noisy_suggested()
	current_phase = DayPhase.PREP
	attention_remaining = balance_config.attention_pool
	pending_floor_skip_seconds = 0.0
	shop.reset_daily_attendance()
	last_register_walkout_rep_delta = 0
	register_walkout_count_today = 0
	register_walkout_rep_spent_today = 0
	last_fair_price_settle_rep_delta = 0
	listed_sale_log.reset()
	last_buylist_drip_rep_delta = 0
	buylist_drip_applied = false
	seller_lots_weight_mult = 1.0
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


func can_install_cameras() -> bool:
	return (
		is_game_active
		and current_phase in [DayPhase.PREP, DayPhase.FLOOR]
		and not shop.has_cameras()
		and attention_remaining >= shop.camera_attention_cost()
		and Economy.can_afford(shop.camera_cash_cost_cents())
	)


func install_cameras() -> Dictionary:
	var cash_cost := shop.camera_cash_cost_cents()
	var attention_cost := shop.camera_attention_cost()
	if shop.has_cameras():
		return _camera_result(false, &"already_owned", 0, 0)
	if not is_game_active or current_phase not in [DayPhase.PREP, DayPhase.FLOOR]:
		return _camera_result(false, &"wrong_phase", 0, 0)
	if attention_remaining < attention_cost:
		return _camera_result(false, &"insufficient_attention", 0, 0)
	if not Economy.can_afford(cash_cost):
		return _camera_result(false, &"insufficient_cash", 0, 0)
	if not consume_attention(attention_cost):
		return _camera_result(false, &"insufficient_attention", 0, 0)
	if not Economy.record_expense(cash_cost, &"cameras", "Security cameras"):
		attention_remaining += attention_cost
		EventBus.attention_changed.emit(attention_remaining)
		return _camera_result(false, &"insufficient_cash", 0, 0)
	if not shop.install_cameras():
		return _camera_result(false, &"already_owned", attention_cost, cash_cost)
	var applied := _camera_result(true, &"ok", attention_cost, cash_cost)
	QaInstrumentation.record_cameras_installed(applied)
	return applied


func _camera_result(
	ok: bool,
	reason: StringName,
	attention_spent: int,
	cash_spent_cents: int
) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"attention_spent": attention_spent,
		"cash_spent_cents": cash_spent_cents,
		"attention_remaining": attention_remaining,
		"cameras_owned": shop.has_cameras(),
		"cameras_active": shop.has_active_cameras(),
	}


func can_inspect() -> bool:
	return (
		is_game_active
		and attention_remaining >= shop.inspect_attention_cost()
	)


func can_negotiate() -> bool:
	return (
		is_game_active
		and current_phase == DayPhase.FLOOR
		and attention_remaining >= NegotiatePolicy.attention_cost()
	)


func can_pull() -> bool:
	return (
		is_game_active
		and current_phase == DayPhase.FLOOR
		and attention_remaining >= shop.pull_attention_cost()
	)


func can_rearrange() -> bool:
	return is_game_active and current_phase == DayPhase.PREP


func can_unlock_play_table() -> bool:
	return (
		is_game_active
		and current_phase == DayPhase.PREP
		and shop.can_unlock_play_table(Economy.balance_cents, current_reputation)
	)


func unlock_play_table() -> Dictionary:
	var cash_cost := shop.play_table_cash_cost_cents()
	if shop.has_play_table():
		return _play_table_result(false, &"already_owned", 0, Vector2i(-1, -1))
	if not is_game_active or current_phase != DayPhase.PREP:
		return _play_table_result(false, &"wrong_phase", 0, Vector2i(-1, -1))
	if not shop.rep_meets_play_table(current_reputation):
		return _play_table_result(false, &"insufficient_reputation", 0, Vector2i(-1, -1))
	if not Economy.can_afford(cash_cost):
		return _play_table_result(false, &"insufficient_cash", 0, Vector2i(-1, -1))
	if not Economy.record_expense(cash_cost, &"play_table", "Play table"):
		return _play_table_result(false, &"insufficient_cash", 0, Vector2i(-1, -1))
	if not shop.unlock_play_table():
		return _play_table_result(false, &"already_owned", cash_cost, Vector2i(-1, -1))
	var origin := ShopLayout.PLAY_TABLE_DEFAULT_ORIGIN
	var placed := shop.place_play_table(origin)
	if placed != &"ok" and placed != &"blocked_path":
		var applied_locked := _play_table_result(true, placed, cash_cost, origin)
		QaInstrumentation.record_play_table_unlocked(applied_locked)
		EventBus.shop_layout_changed.emit()
		return applied_locked
	var applied := _play_table_result(true, &"ok", cash_cost, origin)
	applied["place_reason"] = String(placed)
	QaInstrumentation.record_play_table_unlocked(applied)
	EventBus.shop_layout_changed.emit()
	return applied


func place_play_table(origin: Vector2i) -> Dictionary:
	if not shop.has_play_table():
		return _play_table_result(false, &"locked", 0, origin)
	if not is_game_active or current_phase != DayPhase.PREP:
		return _play_table_result(false, &"wrong_phase", 0, origin)
	if shop.has_play_table_placed():
		return _play_table_result(false, &"already_placed", 0, origin)
	var reason := shop.place_play_table(origin)
	var ok := reason == &"ok" or reason == &"blocked_path"
	var applied := _play_table_result(ok, reason if ok else reason, 0, origin)
	if ok:
		QaInstrumentation.record_play_table_placed(applied)
		EventBus.shop_layout_changed.emit()
	return applied


func rearrange_fixture(fixture_id: StringName, new_origin: Vector2i) -> Dictionary:
	var cost := shop.rearrange_attention_cost()
	if not can_rearrange():
		return _rearrange_result(false, &"wrong_phase", fixture_id, new_origin, 0)
	if attention_remaining < cost:
		return _rearrange_result(false, &"insufficient_attention", fixture_id, new_origin, 0)
	var reason := shop.layout.preview_move(fixture_id, new_origin)
	var fixture := shop.layout.fixture_by_id(fixture_id)
	var allow_block := (
		reason == &"blocked_path"
		and shop.layout.allows_blocked_move(fixture)
	)
	if reason != &"ok" and not allow_block:
		var rejected := _rearrange_result(false, reason, fixture_id, new_origin, 0)
		QaInstrumentation.record_rearrange_attempted(rejected)
		return rejected
	if not consume_attention(cost):
		return _rearrange_result(false, &"insufficient_attention", fixture_id, new_origin, 0)
	shop.layout.apply_move(fixture_id, new_origin)
	shop.sync_play_table_blockers()
	var applied := _rearrange_result(true, reason, fixture_id, new_origin, cost)
	QaInstrumentation.record_rearrange_attempted(applied)
	EventBus.shop_layout_changed.emit()
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


func _play_table_result(
	ok: bool,
	reason: StringName,
	cash_spent_cents: int,
	origin: Vector2i
) -> Dictionary:
	return {
		"ok": ok,
		"reason": String(reason),
		"cash_spent_cents": cash_spent_cents,
		"origin_x": origin.x,
		"origin_y": origin.y,
		"play_table_owned": shop.has_play_table(),
		"play_table_placed": shop.has_play_table_placed(),
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


func can_progress_day() -> bool:
	return is_game_active and not loan_shark_offer_pending and not campaign_lost


func begin_settle_obligations() -> void:
	_unpaid_wages_this_settle = false


func note_rent_paid() -> void:
	missed_rent_weeks = 0


func note_rent_missed() -> void:
	missed_rent_weeks += 1


func note_unpaid_wage() -> void:
	_unpaid_wages_this_settle = true


func register_is_covered() -> bool:
	return shop.register_is_covered(attention_remaining)


func apply_register_walkout_rep() -> int:
	# AH1: −1 Rep per walkout, once, capped at −3 per day.
	# Further walkouts still leave; they do not drop more Rep.
	last_register_walkout_rep_delta = 0
	register_walkout_count_today += 1
	var hit := shop.register_walkout_rep_hit()
	var cap := shop.register_walkout_rep_cap()
	if hit <= 0 or register_walkout_rep_spent_today >= cap:
		return 0
	var applied := mini(hit, cap - register_walkout_rep_spent_today)
	if applied <= 0:
		return 0
	register_walkout_rep_spent_today += applied
	last_register_walkout_rep_delta = -applied
	adjust_reputation(-applied)
	return -applied


func clear_last_nm_mismatch() -> void:
	last_nm_mismatch_sale = false
	last_nm_mismatch_refund_cents = 0
	last_nm_mismatch_rep_delta = 0


func note_nm_mismatch(refund_cents: int, rep_delta: int) -> void:
	last_nm_mismatch_sale = true
	last_nm_mismatch_refund_cents = maxi(0, refund_cents)
	last_nm_mismatch_rep_delta = rep_delta


func note_completed_listed_sale(
	sku_id: StringName,
	ask_cents: int,
	suggested_cents: int = 0
) -> void:
	# BK1: completed listed-price sale (in-shop list or filled online hold).
	# Suggested is the same noisy figure the player already sees for that SKU.
	if suggested_cents <= 0:
		suggested_cents = DemandSignals.suggested_for_listed_sale(sku_id, ask_cents)
	listed_sale_log.note_completed_sale(ask_cents, suggested_cents, balance_config)


func apply_fair_price_settle_rep() -> int:
	# BK1: once per close-settle, after wages/rent/shrink.
	# Gouge −1 skips fair +1. Caps are once each per day.
	last_fair_price_settle_rep_delta = 0
	var delta := listed_sale_log.settle_rep_delta(balance_config)
	last_fair_price_settle_rep_delta = delta
	if delta == 0:
		return 0
	adjust_reputation(delta)
	QaInstrumentation.record_fair_price_settle({
		"rep_delta": delta,
		"had_fair": listed_sale_log.had_fair,
		"had_gouge": listed_sale_log.had_gouge,
		"reputation": current_reputation,
	})
	return delta


func player_buylist_pct(category: Variant) -> float:
	return buylist_pcts.pct_for(category)


func set_player_buylist_pct(category: Variant, pct: float) -> void:
	buylist_pcts.set_pct(category, pct)


func apply_buylist_drip_settle_rep() -> int:
	# BM1: once per close-settle, after shrink (shares the BK1 beat).
	# Any category strictly below drip_floor → Rep −1 once. Caps at one −1.
	last_buylist_drip_rep_delta = 0
	if buylist_drip_applied:
		return 0
	buylist_drip_applied = true
	var delta := BuylistDripPolicy.settle_rep_delta(buylist_pcts, balance_config)
	last_buylist_drip_rep_delta = delta
	if delta == 0:
		return 0
	adjust_reputation(delta)
	QaInstrumentation.record_buylist_drip_settle({
		"rep_delta": delta,
		"reputation": current_reputation,
	})
	return delta


func apply_buylist_fewer_lots_at_open() -> float:
	# BN1: snapshot at floor open. Any category strictly below drip_floor
	# → seller-lot / seller-walk-in weight × fewer_lots_mult. Caps at one
	# mult. High % does not raise traffic. Buyer door / whale stay shipped.
	seller_lots_weight_mult = BuylistFewerLotsPolicy.seller_weight_mult(
		buylist_pcts,
		balance_config
	)
	QaInstrumentation.record_buylist_fewer_lots({
		"weight_mult": seller_lots_weight_mult,
		"starved": seller_lots_weight_mult < 1.0,
		"day": current_day,
	})
	return seller_lots_weight_mult


func apply_buylist_flood_at_open() -> float:
	# BO1: snapshot at floor open after BN1. Any category strictly above
	# flood_ceiling and none below drip_floor → seller-lot / seller-walk-in
	# weight × flood_lots_mult. Caps at one mult. If BN1 starved the day,
	# starve wins — do not also flood. Buyer door / whale stay shipped.
	if BuylistFewerLotsPolicy.is_starved(buylist_pcts, balance_config):
		QaInstrumentation.record_buylist_flood({
			"weight_mult": seller_lots_weight_mult,
			"flooded": false,
			"starved": true,
			"day": current_day,
		})
		return seller_lots_weight_mult
	seller_lots_weight_mult = BuylistFloodPolicy.seller_weight_mult(
		buylist_pcts,
		balance_config
	)
	QaInstrumentation.record_buylist_flood({
		"weight_mult": seller_lots_weight_mult,
		"flooded": seller_lots_weight_mult > 1.0,
		"starved": false,
		"day": current_day,
	})
	return seller_lots_weight_mult


func fire_staff(index: int) -> StaffMember:
	# AG1: role leaves the roster now. Wage stops on the next settle.
	# Popular (roster age ≥ 3 floor days) eats Rep −5 once.
	last_fire_rep_delta = 0
	var member := shop.fire_staff(index)
	if member == null:
		return null
	last_fire_rep_delta = shop.take_fire_rep_delta(member)
	if last_fire_rep_delta != 0:
		adjust_reputation(last_fire_rep_delta)
	return member


func adjust_reputation(delta: int) -> void:
	current_reputation = clampi(current_reputation + delta, 0, 100)
	EventBus.reputation_changed.emit(current_reputation)
	evaluate_campaign_win()
	evaluate_campaign_lose()


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


func select_ironman(enabled: bool) -> bool:
	# Mid-run switch is out of scope. Menu / new-game only. Default off.
	if is_game_active:
		return false
	ironman_enabled = enabled
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


func has_sandbox_personal_bests() -> bool:
	return sandbox_best_day > 0 or sandbox_best_net_worth_cents > 0


func _record_sandbox_personal_bests() -> void:
	# AA1 / systems §9.2: Sandbox high water only. Peak net worth + longest day.
	# Still no win awards. Career high-water survives new games and save/load.
	if _suppress_sandbox_bests or campaign_mode != CampaignMode.SANDBOX:
		return
	sandbox_best_day = maxi(sandbox_best_day, current_day)
	sandbox_best_net_worth_cents = maxi(
		sandbox_best_net_worth_cents,
		Economy.net_worth_cents()
	)


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


func can_offer_loan_shark() -> bool:
	return (
		balance_config != null
		and balance_config.loan_shark_enabled
		and not loan_shark_recovery_used
		and not loan_shark_offer_pending
	)


func bankruptcy_reason() -> StringName:
	if current_reputation <= 0:
		return &"reputation"
	if _unpaid_wages_this_settle:
		return &"unpaid_wages"
	if (
		balance_config != null
		and missed_rent_weeks >= maxi(1, balance_config.missed_rent_weeks_to_lose)
	):
		return &"missed_rent"
	# Z1 / systems §9.1 #4: Ironman lose when cash < $500 AND inventory COGS
	# < $500. COGS is InventoryService.inventory_cogs_cents() — acquired cost
	# of sealed, singles, graded, and accessories, not liquidity-haircut NW.
	# Off → existing lose rules only (cash < 0 / missed rent / Rep ≤ 0).
	if (
		ironman_enabled
		and balance_config != null
		and balance_config.meets_ironman_destitution(
			Economy.balance_cents,
			InventoryService.inventory_cogs_cents()
		)
	):
		return &"ironman"
	return &""


func loan_shark_offer_payload() -> Dictionary:
	var terms := {}
	if balance_config != null:
		terms = balance_config.loan_shark_terms()
	return {
		"reason": String(last_lose_reason),
		"cash_cents": int(terms.get("cash_cents", 0)),
		"daily_cents": int(terms.get("daily_cents", 0)),
		"days": int(terms.get("days", 0)),
		"rep_hit": int(terms.get("rep_hit", 0)),
	}


func campaign_lose_payload() -> Dictionary:
	return {
		"reason": String(last_lose_reason),
		"day": current_day,
		"cash_cents": Economy.balance_cents,
		"reputation": current_reputation,
		"loan_offered": loan_shark_recovery_used,
	}


func evaluate_campaign_lose() -> bool:
	if _suppress_lose_eval or campaign_complete or campaign_lost:
		return false
	if not is_game_active or loan_shark_offer_pending:
		return false
	var reason := bankruptcy_reason()
	if reason == &"":
		return false
	# Ironman dual-floor is a named lose, not a loan-shark bankruptcy.
	# Existing cash/rent/rep shark path stays unchanged.
	if reason != &"ironman" and can_offer_loan_shark():
		return _offer_loan_shark(reason)
	return _award_loss(reason)


func accept_loan_shark() -> bool:
	if not loan_shark_offer_pending or campaign_lost or campaign_complete:
		return false
	_suppress_lose_eval = true
	if not Economy.apply_loan_shark_terms():
		_suppress_lose_eval = false
		return false
	loan_shark_recovery_used = true
	loan_shark_offer_pending = false
	missed_rent_weeks = 0
	_unpaid_wages_this_settle = false
	_suppress_lose_eval = false
	var payload := loan_shark_offer_payload()
	payload["outcome"] = "accept"
	QaInstrumentation.record_loan_shark_resolved(payload)
	EventBus.loan_shark_resolved.emit(&"accept")
	return true


func refuse_loan_shark() -> bool:
	# Refuse is game over (systems §9.3 / W1). There is no continue-without-loan path.
	if not loan_shark_offer_pending or campaign_lost or campaign_complete:
		return false
	loan_shark_offer_pending = false
	loan_shark_recovery_used = true
	var payload := loan_shark_offer_payload()
	payload["outcome"] = "refuse"
	QaInstrumentation.record_loan_shark_resolved(payload)
	EventBus.loan_shark_resolved.emit(&"refuse")
	return _award_loss(&"refused_loan_shark")


func _offer_loan_shark(reason: StringName) -> bool:
	last_lose_reason = reason
	loan_shark_offer_pending = true
	var payload := loan_shark_offer_payload()
	QaInstrumentation.record_loan_shark_offered(payload)
	EventBus.loan_shark_offered.emit(payload)
	return true


func _award_loss(reason: StringName) -> bool:
	campaign_lost = true
	last_lose_reason = reason
	is_game_active = false
	loan_shark_offer_pending = false
	var payload := campaign_lose_payload()
	QaInstrumentation.record_campaign_lost(payload)
	EventBus.campaign_lost.emit(payload)
	return true


func _on_cash_changed_maybe_win(_balance_cents: int) -> void:
	_record_sandbox_personal_bests()
	if current_phase == DayPhase.SETTLE:
		return
	evaluate_campaign_win()
	evaluate_campaign_lose()


func _on_inventory_changed_maybe_bests(_sku: StringName, _quantity: int) -> void:
	_record_sandbox_personal_bests()


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
		"sandbox_best_net_worth_cents": sandbox_best_net_worth_cents,
		"campaign_lost": campaign_lost,
		"last_lose_reason": String(last_lose_reason),
		"loan_shark_recovery_used": loan_shark_recovery_used,
		"ironman_enabled": ironman_enabled,
		"missed_rent_weeks": missed_rent_weeks,
		"register_walkout_count_today": register_walkout_count_today,
		"register_walkout_rep_spent_today": register_walkout_rep_spent_today,
		"payday_loan_days_remaining": Economy.payday_loan_days_remaining(),
		"online_cancel": Economy.online_cancel_to_save(),
		"online_listings": Economy.online_listings_to_save(),
		"listed_sale_day": listed_sale_log.snapshot(),
		"buylist_pcts": buylist_pcts.snapshot(),
		"buylist_drip_applied": buylist_drip_applied,
		"seller_lots_weight_mult": seller_lots_weight_mult,
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
	campaign_lost = bool(data.get("campaign_lost", false))
	last_lose_reason = StringName(data.get("last_lose_reason", &""))
	loan_shark_recovery_used = bool(data.get("loan_shark_recovery_used", false))
	ironman_enabled = bool(data.get("ironman_enabled", false))
	loan_shark_offer_pending = false
	missed_rent_weeks = int(data.get("missed_rent_weeks", 0))
	last_fire_rep_delta = 0
	last_register_walkout_rep_delta = 0
	last_fair_price_settle_rep_delta = 0
	last_buylist_drip_rep_delta = 0
	clear_last_nm_mismatch()
	var listed_sale_day: Variant = data.get("listed_sale_day", {})
	if listed_sale_day is Dictionary:
		listed_sale_log.apply_save(listed_sale_day as Dictionary)
	else:
		listed_sale_log.reset()
	var saved_buylist_pcts: Variant = data.get("buylist_pcts", {})
	if saved_buylist_pcts is Dictionary:
		buylist_pcts.apply_save(saved_buylist_pcts as Dictionary)
	else:
		buylist_pcts.reset()
	buylist_drip_applied = bool(data.get("buylist_drip_applied", false))
	seller_lots_weight_mult = float(data.get("seller_lots_weight_mult", 1.0))
	if seller_lots_weight_mult <= 0.0 or seller_lots_weight_mult > 3.0:
		seller_lots_weight_mult = 1.0
	register_walkout_count_today = maxi(
		0,
		int(data.get("register_walkout_count_today", 0))
	)
	register_walkout_rep_spent_today = maxi(
		0,
		int(data.get("register_walkout_rep_spent_today", 0))
	)
	_unpaid_wages_this_settle = false
	sandbox_best_day = int(data.get("sandbox_best_day", sandbox_best_day))
	sandbox_best_net_worth_cents = int(
		data.get(
			"sandbox_best_net_worth_cents",
			data.get("sandbox_best_cash_cents", sandbox_best_net_worth_cents)
		)
	)
	Economy.restore_payday_loan_days(int(data.get("payday_loan_days_remaining", 0)))
	var online_cancel: Variant = data.get("online_cancel", {})
	if online_cancel is Dictionary:
		Economy.restore_online_cancel(online_cancel as Dictionary)
	else:
		Economy.restore_online_cancel({})
	var saved_prestige := StringName(data.get("last_prestige", &""))
	if not saved_prestige.is_empty():
		last_prestige = saved_prestige
	shop.apply_save(data.get("shop", {}), balance_config)
	var inventory: Dictionary = data.get("inventory", {})
	InventoryService.apply_shop_capacity_bonuses(
		int(inventory.get("case_slot_bonus", 0)),
		int(inventory.get("backstock_bin_bonus", 0))
	)
	var online_holds: Variant = data.get("online_listings", {})
	if online_holds is Dictionary:
		Economy.restore_online_listings(online_holds as Dictionary)
	else:
		Economy.restore_online_listings({})
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
	if campaign_complete or campaign_lost:
		is_game_active = false
	else:
		evaluate_campaign_win()
		evaluate_campaign_lose()
	return true
