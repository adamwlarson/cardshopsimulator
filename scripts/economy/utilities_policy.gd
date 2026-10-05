class_name UtilitiesPolicy
extends RefCounted

## BP1: close-settle daily utilities by current shop tier.
## One ledger expense per settle day. Missing / ≤0 amounts fall back to
## Small $40 / Medium $70 / Large $110. Pay with the wages unpaid path
## (attempt expense; note once if unpaid). Not a sell weight.
## Out: utilities-specific bankruptcy; payday-loan forced drain.
const SMALL_DAILY_CENTS := 4_000
const MEDIUM_DAILY_CENTS := 7_000
const LARGE_DAILY_CENTS := 11_000
const CATEGORY := &"utilities"
const MEMO := "Utilities"


static func daily_cents(configured: int = 0, fallback: int = SMALL_DAILY_CENTS) -> int:
	if configured <= 0:
		return fallback
	return configured


static func daily_cents_for_tier(shop_tier: int, config: BalanceConfig = null) -> int:
	if shop_tier >= int(ShopState.Tier.LARGE):
		return daily_cents(
			0 if config == null else config.utilities_large_daily_cents,
			LARGE_DAILY_CENTS
		)
	if shop_tier == int(ShopState.Tier.MEDIUM):
		return daily_cents(
			0 if config == null else config.utilities_medium_daily_cents,
			MEDIUM_DAILY_CENTS
		)
	return daily_cents(
		0 if config == null else config.utilities_small_daily_cents,
		SMALL_DAILY_CENTS
	)
