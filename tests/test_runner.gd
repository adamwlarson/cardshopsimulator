extends SceneTree

var _failures: int = 0


func _initialize() -> void:
	_test_pricing_spread()
	_test_stock_lot_unit_cost()

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


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		return
	_failures += 1
	push_error("%s: expected %s, got %s" % [label, expected, actual])
