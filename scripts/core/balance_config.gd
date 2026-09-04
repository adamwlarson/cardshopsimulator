class_name BalanceConfig
extends Resource

enum Difficulty {
	EASY,
	NORMAL,
	HARD,
}

@export var difficulty: Difficulty = Difficulty.NORMAL
@export_range(0, 100_000_000, 1) var starting_cash_cents: int = 800_000
@export_range(0, 10_000_000, 1) var weekly_rent_cents: int = 120_000
@export_range(0.1, 10.0, 0.1) var tile_size_m: float = 0.9
@export_range(1, 1_000, 1) var case_slots: int = 24
@export_range(1, 10_000, 1) var backstock_bins: int = 40
@export_range(1, 1_000, 1) var attention_pool: int = 100
@export_range(0.0, 1.0, 0.01) var event_chance: float = 0.18
@export var loan_shark_enabled: bool = true

# Difficulty-curve hooks. Their exact impact belongs to the owning systems.
@export_range(0.1, 3.0, 0.05) var customer_spawn_rate_scalar: float = 1.0
@export_range(0.0, 3.0, 0.05) var shrink_rate_scalar: float = 1.0
@export_range(0.0, 1.0, 0.01) var comp_noise_scalar: float = 0.15
