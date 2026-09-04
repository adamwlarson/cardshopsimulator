class_name PricingService
extends RefCounted

const DEFAULT_BUY_RATIO := 0.55
const DEFAULT_SELL_RATIO := 1.20


static func suggested_buy_price_cents(market_price_cents: int, buy_ratio: float = DEFAULT_BUY_RATIO) -> int:
	if market_price_cents <= 0:
		return 0
	return maxi(1, roundi(market_price_cents * clampf(buy_ratio, 0.0, 1.0)))


static func suggested_sell_price_cents(
	cost_basis_cents: int,
	market_price_cents: int,
	sell_ratio: float = DEFAULT_SELL_RATIO
) -> int:
	if cost_basis_cents < 0 or market_price_cents <= 0:
		return 0
	var margin_floor := roundi(cost_basis_cents * maxf(1.0, sell_ratio))
	return maxi(margin_floor, market_price_cents)


static func spread_cents(buy_price_cents: int, sell_price_cents: int) -> int:
	return maxi(0, sell_price_cents - buy_price_cents)
