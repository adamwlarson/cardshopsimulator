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
@export var shrink_daily_base: float = 0.002
@export var shrink_unstaffed_add: float = 0.005
@export var rent_small_weekly_cents: int = 120_000
@export var wage_mult: float = 1.0

@export var event_chance_settle: float = 0.18
@export var negative_event_weight_mult: float = 1.0
@export var market_drift_low: float = 0.98
@export var market_drift_high: float = 1.02

@export var attention_pool: int = 100
@export var comp_noise_width_mult: float = 1.0
@export var demand_band_sigma: float = 0.12

@export var research_cost_cents: int = 5_000
@export var research_attention: int = 15
@export var inspect_accuracy: float = 0.85
@export var shady_fake_slab_rate: float = 0.08

@export var fair_comp_mae_max: float = 0.12
@export var fair_band_within1_min: float = 0.80
@export var fair_forbid_hot_cold_invert: bool = true

@export var loan_shark_enabled: bool = true
@export var loan_shark_cash_cents: int = 500_000
@export var loan_shark_daily_cents: int = 20_000
@export var loan_shark_days: int = 40
@export var loan_shark_rep_hit: int = 10
@export var missed_rent_weeks_to_lose: int = 2
@export var ironman_destitution_default: bool = false

@export var survive_y1_rep_floor: int = 40
@export var flagship_cash_cents: int = 5_000_000
@export var liquidity_king_cash_cents: int = 10_000_000


func is_rent_due_day(day: int) -> bool:
	return (
		day >= first_rent_due_day
		and (day - first_rent_due_day) % 7 == 0
	)
