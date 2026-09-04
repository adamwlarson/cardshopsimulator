class_name BalanceConfig
extends Resource

enum Difficulty {
	EASY,
	NORMAL,
	HARD,
}

@export var difficulty: Difficulty = Difficulty.NORMAL
@export var start_cash_cents: int = 800_000
@export var start_reputation: int = 40
@export var case_slots: int = 24
@export var backstock_bins: int = 40
@export var rent_small_weekly_cents: int = 120_000
@export var first_rent_due_day: int = 7
@export var attention_pool: int = 100
@export var event_chance_settle: float = 0.18
@export var loan_shark_enabled: bool = true
@export var tile_size_m: float = 0.9

# §8 difficulty-curve scalars. Owning systems apply them exactly once.
@export var customer_spawn_mult: float = 1.0
@export var whale_spawn_mult: float = 1.0
@export var flipper_spawn_mult: float = 1.0
@export var shrink_mult: float = 1.0
@export var comp_noise_width_mult: float = 1.0
@export var demand_band_sigma: float = 1.0
@export var comp_mae_cap_sealed: float = 0.12
@export var comp_mae_cap_singles: float = 0.16
@export var comp_mae_cap_graded: float = 0.20


func is_rent_due_day(day: int) -> bool:
	return (
		day >= first_rent_due_day
		and (day - first_rent_due_day) % 7 == 0
	)
