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
		EASY_CONFIG.starting_cash_cents
		> NORMAL_CONFIG.starting_cash_cents
		and NORMAL_CONFIG.starting_cash_cents
		> HARD_CONFIG.starting_cash_cents
	)
	_expect_equal(cash_is_ordered, true, "starting cash difficulty ordering")
	_expect_equal(HARD_CONFIG.loan_shark_enabled, false, "hard loan shark access")
	_expect_equal(NORMAL_CONFIG.starting_cash_cents, 800_000, "normal starting cash")
	_expect_equal(NORMAL_CONFIG.weekly_rent_cents, 120_000, "normal weekly rent")


func _test_normal_shop_capacity() -> void:
	var capacity := ShopCapacity.new()
	_expect_equal(capacity.display_slots, NORMAL_CONFIG.case_slots, "normal case slots")
	_expect_equal(capacity.storage_units, NORMAL_CONFIG.backstock_bins, "normal backstock bins")


func _test_weekly_rent_schedule() -> void:
	GameState.set_balance_config(NORMAL_CONFIG)
	Economy.reset()
	var starting_cash := Economy.balance_cents
	_expect_equal(Economy.settle_weekly_obligations(6), false, "no rent before weekly settle")
	_expect_equal(Economy.balance_cents, starting_cash, "pre-settle cash unchanged")
	_expect_equal(Economy.settle_weekly_obligations(7), true, "rent charged on weekly settle")
	_expect_equal(
		Economy.balance_cents,
		starting_cash - NORMAL_CONFIG.weekly_rent_cents,
		"weekly rent amount"
	)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		return
	_failures += 1
	push_error("%s: expected %s, got %s" % [label, expected, actual])
