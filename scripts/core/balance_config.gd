class_name BalanceConfig
extends Resource

enum Difficulty {
	EASY,
	NORMAL,
	HARD,
}

@export var difficulty: Difficulty = Difficulty.NORMAL
@export var tile_size_m: float = 0.9

@export var start_cash_cents: int = 800_000
@export var start_reputation: int = 40
@export var case_slots: int = 24
@export var backstock_bins: int = 40
@export var seed_blasters: int = 4
@export var seed_dust_etbs: int = 2
@export var seed_skie_blasters: int = 0
@export var seed_named_staples: int = 8
@export var seed_bulk_cards: int = 80
@export var seed_sleeves: int = 200
@export var seed_toploaders: int = 50
@export var start_with_trainee_cashier: bool = false
@export var trainee_free_days: int = 3

@export var first_rent_due_day: int = 7

@export var customer_spawn_mult: float = 1.0
@export var whale_weight_mult: float = 1.0
@export var flipper_weight_mult: float = 1.0
@export var distributor_discount_min: float = 0.30
@export var distributor_discount_max: float = 0.40
@export var online_fee: float = 0.08
@export var online_unlock_rep: int = 35
@export var online_ship_days_min: int = 1
@export var online_ship_days_max: int = 3
## BG1: first N ONLINE_HOLD cancels each calendar day are free. Each extra
## same-day cancel applies Rep −online_cancel_rep_hit once. Missing / ≤0
## falls back in OnlineCancelPolicy to 1 free/day and hit 1.
@export var online_cancel_free_per_day: int = 1
@export var online_cancel_rep_hit: int = 1
## BE1: high-rep online listing settle cut. Missing / ≤0 falls back in
## OnlineFeePolicy to 5% at Rep ≥ 75. Base `online_fee` stays below the gate.
@export var online_high_rep_fee_percent: int = 5
@export var online_high_rep_fee_gate: int = 75
## BI1: concurrent ONLINE_HOLD soft cap. Missing band caps fall back
## in OnlineHoldCapPolicy to 4 / 8 / 12. Cap ≤ 0 treated as 1 once
## unlocked (never silent infinite).
@export var online_hold_cap_low: int = 4
@export var online_hold_cap_mid: int = 8
@export var online_hold_cap_high: int = 12
@export var shrink_daily_base: float = 0.002
@export var shrink_unstaffed_add: float = 0.005
## HOLD H2: Easy/Hard inherit this Normal default when omitted from .tres.
@export var staff_noshow_mult: float = 0.4
## HOLD H3: Easy/Hard inherit this Normal Pull Att cost when omitted from .tres.
@export var pull_attention: int = 5
@export var rent_small_weekly_cents: int = 120_000
@export var rent_medium_weekly_cents: int = 240_000
## systems §7.3 Large weekly rent $4,000. Applied the week after Sign.
@export var rent_large_weekly_cents: int = 400_000
@export var wage_mult: float = 1.0
@export var staff_cap_small: int = 1
@export var staff_cap_medium: int = 3
@export var staff_cap_large: int = 5
@export var specialist_wage_cents: int = 14_000
@export var expand_medium_cash_cents: int = 1_500_000
@export var expand_medium_rep: int = 55
## systems §7.3 Large unlock: Cash ≥ $40k + Rep 70.
@export var expand_large_cash_cents: int = 4_000_000
@export var expand_large_rep: int = 70
## Medium vs Small traffic. Default 1.0 keeps shipped Medium spawn rate
## (Option B did not change traffic). Large's scalar is relative to this.
@export var expand_medium_traffic_mult: float = 1.0
## Large vs Medium traffic (Option L1). Rent step is $4,000 / $2,400 ≈ 1.67×
## and floor is ~2,000 / ~1,200 ≈ 1.67× (~2× Small rent). Traffic uses this
## sublinear extra scalar so Large is not 2× Medium traffic for ~2× rent.
## Effective Large mult = expand_medium_traffic_mult × this (1.0 × 1.25 = 1.25).
@export var expand_large_traffic_mult: float = 1.25
@export var marketplace_outing_attention: int = 25
@export var marketplace_outing_floor_skip_seconds: float = 34.0
@export var marketplace_courier_fee_cents: int = 3_500
@export var shady_report_rep_gain: int = 5

@export var event_chance_settle: float = 0.18
@export var negative_event_weight_mult: float = 1.0
@export var market_drift_low: float = 0.98
@export var market_drift_high: float = 1.02
## AR1 class bands. A missing / invalid class pair falls back to sealed, then 0.98–1.02.
@export var market_drift_accessory_low: float = 0.99
@export var market_drift_accessory_high: float = 1.01
@export var market_drift_sealed_low: float = 0.98
@export var market_drift_sealed_high: float = 1.02
@export var market_drift_single_low: float = 0.97
@export var market_drift_single_high: float = 1.03
@export var market_drift_graded_low: float = 0.96
@export var market_drift_graded_high: float = 1.04

@export var attention_pool: int = 100
@export var comp_noise_width_mult: float = 1.0
@export var demand_band_sigma: float = 0.12

@export var research_cost_cents: int = 5_000
@export var research_attention: int = 15
@export var research_attention_specialist: int = 10
@export var research_duration_days_min: int = 1
@export var research_duration_days_max: int = 3
@export var research_demand_band_sigma: float = 0.07
@export var research_comp_narrow_factor: float = 0.55
@export var rearrange_attention: int = 10
@export var inspect_attention: int = 5
@export var inspect_attention_specialist: int = 2
@export var inspect_accuracy: float = 0.85
@export var shady_fake_slab_rate: float = 0.08
## Sale of a fail-slab: reputation bomb (systems §2.2).
@export var fake_slab_sale_rep_hit: int = 15
## BB1/BD1: uninspected marketplace/shady/auction single listed NM, true LP+.
## Missing values fall back to −2 / 0.50 in NmMismatchPolicy.
@export var uninspected_nm_mismatch_rep_hit: int = 2
@export var uninspected_nm_mismatch_refund_fraction: float = 0.50

@export var fair_comp_mae_max: float = 0.12
@export var fair_band_within1_min: float = 0.80
@export var fair_forbid_hot_cold_invert: bool = true

@export var loan_shark_enabled: bool = true
@export var loan_shark_cash_cents: int = 500_000
@export var loan_shark_daily_cents: int = 20_000
@export var loan_shark_days: int = 40
@export var loan_shark_rep_hit: int = 10
@export var missed_rent_weeks_to_lose: int = 2
## Z1 / systems §9.1 #4: menu opt-in default. Stay false on Easy/Normal/Hard.
## Do not turn Ironman on by default for Hard. Live toggle is GameState.ironman_enabled.
@export var ironman_destitution_default: bool = false
## Dual-floor lose when Ironman is on: cash < $500 and inventory COGS < $500.
## Do not rebalance these floors.
@export var ironman_cash_cents: int = 50_000
@export var ironman_cogs_cents: int = 50_000

@export var survive_y1_rep_floor: int = 40
## systems §9.2 Survive Year 1 day gate. Same day on Easy/Normal/Hard.
@export var survive_y1_day: int = 365
@export var flagship_cash_cents: int = 5_000_000
## systems §9.2 Flagship Rep floor. Cash is the difficulty scalar.
@export var flagship_rep: int = 80
@export var liquidity_king_cash_cents: int = 10_000_000
## 30-day months for Liquidity king month-end. Shared across difficulties.
@export var month_length_days: int = 30
## V1 cameras: cash gate. $2,500 is a real capital bite vs start $8k,
## cheaper than Medium Sign ($15k). Easy/Hard inherit unless overridden.
@export var camera_cash_cents: int = 250_000
## Thin Attention install — between Inspect (5) and Rearrange (10).
@export var camera_attention: int = 8
## Theft-ring shrink multiplier while cameras are owned/active (vs ×3).
@export var camera_theft_shrink_mult: float = 1.5
## AB1 play table: cash + Rep gate, same shape as Medium/Large Sign.
## $10k + Rep 50 sits under Medium ($15k / Rep 55) and above cameras ($2.5k).
@export var play_table_cash_cents: int = 1_000_000
@export var play_table_rep: int = 50
## AC1 / systems §7.2: graded CASE whose showcase origin is within
## `sightline_tiles` of the entrance. ×1.15 is a modest walk-in notice /
## sell-through bump — one locked tier, not a new sell-chance curve and
## not multi-sightline. Easy/Hard inherit unless overridden.
@export var sightline_display_bonus: float = 1.15
@export var sightline_tiles: int = 3
## AD1 / systems §4.2: location-class walk-in browse interest.
## Distinct from AC1 sightline ×1.15 (notice-only, distance-to-door).
## Case is a modest showcase premium over binder-as-identity; backstock
## is invisible to walk-ins (online / pull still allowed). Easy/Hard inherit.
@export var case_display_bonus: float = 1.20
@export var binder_display_bonus: float = 1.00
@export var backstock_display_bonus: float = 0.00
## AE1 / systems §2.1: accessories on a Shelf whose origin is within
## `impulse_shelf_tiles` of the Counter. Browse rank / notice only —
## not a sell-probability weight and not a sale-cash multiplier.
## Other floor shelf stays ×1.00; backstock stays ×0.00 for walk-ins
## (online / pull still allowed). Easy/Hard inherit unless overridden.
@export var impulse_shelf_interest: float = 1.25
@export var floor_shelf_interest: float = 1.00
@export var impulse_shelf_tiles: int = 2
## AF1 / systems §6.1: Stocker wage and daily restock budget.
## While on duty, auto-move up to N BACKSTOCK lots onto a valid floor
## location (SHELF / CASE / BINDER). Placement only — not a sell weight
## and not a sale-cash multiplier. Easy/Hard inherit unless overridden.
@export var stocker_wage_cents: int = 7_000
@export var stocker_restock_lots_per_day: int = 4
## AG1 / systems §6.3: Fire stops the wage immediately. Roster age is
## counted in floor days. Age ≥ 3 means the floor already knows them
## → one-time Rep −5. Age < 3 → Rep unchanged. Easy/Hard inherit.
@export var fire_rep_hit: int = 5
@export var fire_popular_roster_age: int = 3
## AH1 / systems §5.2: uncovered register walkouts. Each waiting
## customer who needs service and finds no coverage leaves that step
## (−1 Rep once). A day cannot drop more than 3 Rep from this rule.
## Easy/Hard inherit. Not a sell weight and not a listed-price change.
@export var register_walkout_rep_hit: int = 1
@export var register_walkout_rep_cap: int = 3
## BK1 / systems §5.3: close-settle fair / overprice Rep ticks vs the
## noisy suggested the player already sees. Missing / ≤0 mults fall
## back in FairPriceSettlePolicy to 1.10 / 1.25. Missing Rep deltas
## fall back to +1 / −1. Easy/Hard inherit. Not a sell weight.
@export var fair_price_fair_mult: float = 1.10
@export var fair_price_gouge_mult: float = 1.25
@export var fair_price_fair_rep_gain: int = 1
@export var fair_price_gouge_rep_hit: int = 1


func is_rent_due_day(day: int) -> bool:
	return (
		day >= first_rent_due_day
		and (day - first_rent_due_day) % 7 == 0
	)


func shop_traffic_mult(shop_tier: int) -> float:
	# Integers match ShopState.Tier (SMALL=0, MEDIUM=1, LARGE=2).
	# Do not reference ShopState here — BalanceConfig must stay loadable first.
	var medium_mult := maxf(0.01, expand_medium_traffic_mult)
	if shop_tier >= 2:
		return medium_mult * maxf(0.01, expand_large_traffic_mult)
	if shop_tier == 1:
		return medium_mult
	return 1.0


func customer_spawn_wait_seconds(base_interval: float, shop_tier: int) -> float:
	var combined := customer_spawn_mult * shop_traffic_mult(shop_tier)
	return base_interval / maxf(0.01, combined)


func meets_flagship(shop_tier: int, reputation: int, cash_cents: int) -> bool:
	# Integers match ShopState.Tier (SMALL=0, MEDIUM=1, LARGE=2).
	return (
		shop_tier >= 2
		and reputation >= flagship_rep
		and cash_cents >= flagship_cash_cents
	)


func meets_survive_y1(day: int, reputation: int, cash_cents: int) -> bool:
	return (
		day >= survive_y1_day
		and cash_cents > 0
		and reputation >= survive_y1_rep_floor
	)


func is_month_end_day(day: int) -> bool:
	return day > 0 and month_length_days > 0 and day % month_length_days == 0


func meets_liquidity_king(day: int, cash_cents: int) -> bool:
	return is_month_end_day(day) and cash_cents >= liquidity_king_cash_cents


func loan_shark_terms() -> Dictionary:
	return {
		"enabled": loan_shark_enabled,
		"cash_cents": loan_shark_cash_cents,
		"daily_cents": loan_shark_daily_cents,
		"days": loan_shark_days,
		"rep_hit": loan_shark_rep_hit,
	}


func meets_ironman_destitution(cash_cents: int, cogs_cents: int) -> bool:
	# Floors only. GameState.ironman_enabled is the player opt-in gate.
	return cash_cents < ironman_cash_cents and cogs_cents < ironman_cogs_cents


func market_drift_range(product_class: ProductSKU.ProductClass) -> Vector2:
	var lo := 0.0
	var hi := 0.0
	match product_class:
		ProductSKU.ProductClass.ACCESSORY:
			lo = market_drift_accessory_low
			hi = market_drift_accessory_high
		ProductSKU.ProductClass.SEALED:
			lo = market_drift_sealed_low
			hi = market_drift_sealed_high
		ProductSKU.ProductClass.SINGLE:
			lo = market_drift_single_low
			hi = market_drift_single_high
		ProductSKU.ProductClass.GRADED:
			lo = market_drift_graded_low
			hi = market_drift_graded_high
		_:
			lo = 0.0
			hi = 0.0
	if _is_valid_market_drift_range(lo, hi):
		return Vector2(lo, hi)
	return _sealed_market_drift_range()


func _sealed_market_drift_range() -> Vector2:
	if _is_valid_market_drift_range(market_drift_sealed_low, market_drift_sealed_high):
		return Vector2(market_drift_sealed_low, market_drift_sealed_high)
	if _is_valid_market_drift_range(market_drift_low, market_drift_high):
		return Vector2(market_drift_low, market_drift_high)
	return Vector2(0.98, 1.02)


func _is_valid_market_drift_range(lo: float, hi: float) -> bool:
	return lo > 0.0 and hi >= lo
