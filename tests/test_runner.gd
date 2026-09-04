extends SceneTree

const EASY_CONFIG: BalanceConfig = preload("res://data/balance/easy.tres")
const NORMAL_CONFIG: BalanceConfig = preload("res://data/balance/normal.tres")
const HARD_CONFIG: BalanceConfig = preload("res://data/balance/hard.tres")

var _failures: int = 0


func _initialize() -> void:
	_test_pricing_spread()
	_test_stock_lot_unit_cost()
	_test_difficulty_balance_ordering()
	_test_normal_shop_capacity()
	_test_weekly_rent_schedule()

	if _failures == 0:
		print("All foundation tests passed.")
		quit(0)
	else:
		push_error("%d foundation test(s) failed." % _failures)
		quit(1)


func _test_pricing_spread() -> void:
	_expect_equal(PricingService.suggested_buy_price_cents(1000), 550, "default buy offer")
	_expect_equal(PricingService.suggested_sell_price_cents(600, 700), 720, "margin floor")
	_expect_equal(PricingService.spread_cents(550, 720), 170, "buy/sell spread")


func _test_stock_lot_unit_cost() -> void:
	var lot := StockLot.new()
	lot.quantity = 4
	lot.cost_basis_cents = 1000
	_expect_equal(lot.unit_cost_cents(), 250, "weighted unit cost")


func _test_difficulty_balance_ordering() -> void:
	var cash_is_ordered := (
		EASY_CONFIG.start_cash_cents
		> NORMAL_CONFIG.start_cash_cents
		and NORMAL_CONFIG.start_cash_cents
		> HARD_CONFIG.start_cash_cents
	)
	_expect_equal(cash_is_ordered, true, "starting cash difficulty ordering")
	_expect_equal(HARD_CONFIG.loan_shark_enabled, false, "hard loan shark access")
	_expect_equal(NORMAL_CONFIG.start_cash_cents, 800_000, "normal starting cash")
	_expect_equal(NORMAL_CONFIG.start_reputation, 40, "normal starting reputation")
	_expect_equal(NORMAL_CONFIG.rent_small_weekly_cents, 120_000, "normal weekly rent")
	_expect_equal(NORMAL_CONFIG.first_rent_due_day, 7, "normal first rent due day")
	_expect_equal(NORMAL_CONFIG.event_chance_settle, 0.18, "normal settle event chance")
	_expect_equal(NORMAL_CONFIG.comp_noise_width_mult, 1.0, "normal comp noise width")
	_expect_equal(EASY_CONFIG.start_cash_cents, 1_200_000, "easy starting cash")
	_expect_equal(HARD_CONFIG.start_cash_cents, 550_000, "hard starting cash")
	_expect_equal(EASY_CONFIG.rent_small_weekly_cents, 100_000, "easy weekly rent")
	_expect_equal(HARD_CONFIG.rent_small_weekly_cents, 135_000, "hard weekly rent")
	_expect_equal(EASY_CONFIG.first_rent_due_day, 10, "easy first rent due day")
	_expect_equal(EASY_CONFIG.whale_weight_mult, 1.4, "easy whale weight")
	_expect_equal(NORMAL_CONFIG.whale_weight_mult, 1.0, "normal whale weight")
	_expect_equal(HARD_CONFIG.whale_weight_mult, 0.7, "hard whale weight")
	_expect_equal(
		EASY_CONFIG.whale_weight_mult > HARD_CONFIG.whale_weight_mult,
		true,
		"easy whale weight exceeds hard"
	)
	_expect_equal(EASY_CONFIG.demand_band_sigma, 0.09, "easy demand sigma")
	_expect_equal(NORMAL_CONFIG.demand_band_sigma, 0.12, "normal demand sigma")
	_expect_equal(HARD_CONFIG.demand_band_sigma, 0.16, "hard demand sigma")


func _test_normal_shop_capacity() -> void:
	var capacity := ShopCapacity.new()
	_expect_equal(capacity.display_slots, NORMAL_CONFIG.case_slots, "normal case slots")
	_expect_equal(capacity.storage_units, NORMAL_CONFIG.backstock_bins, "normal backstock bins")


func _test_weekly_rent_schedule() -> void:
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(6), false, "no rent before weekly settle")
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(7), true, "day seven weekly settle")
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(14), true, "recurring weekly settle")
	_expect_equal(NORMAL_CONFIG.rent_small_weekly_cents, 120_000, "weekly rent amount")


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		return
	_failures += 1
	push_error("%s: expected %s, got %s" % [label, expected, actual])
