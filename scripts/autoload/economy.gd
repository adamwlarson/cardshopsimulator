extends Node

var balance_cents: int = 0
var online_listings := OnlineListingService.new()
var _ledger: Array[LedgerEntry] = []
var _payday_loan_days_remaining: int = 0


func _ready() -> void:
	reset()


func reset() -> void:
	balance_cents = GameState.balance_config.start_cash_cents
	_ledger.clear()
	_payday_loan_days_remaining = 0
	online_listings.reset(GameState.current_day * 7919 + 35)
	EventBus.publish_cash_changed(balance_cents)


func record_income(amount_cents: int, category: StringName, memo: String = "") -> bool:
	return _record(LedgerEntry.Kind.INCOME, amount_cents, category, memo)


func record_expense(amount_cents: int, category: StringName, memo: String = "") -> bool:
	if amount_cents > balance_cents:
		return false
	return _record(LedgerEntry.Kind.EXPENSE, amount_cents, category, memo)


func record_forced_expense(
	amount_cents: int,
	category: StringName,
	memo: String = ""
) -> int:
	var applied := mini(amount_cents, balance_cents)
	if applied <= 0:
		return 0
	if _record(LedgerEntry.Kind.EXPENSE, applied, category, memo):
		return applied
	return 0


func can_afford(amount_cents: int) -> bool:
	return amount_cents >= 0 and balance_cents >= amount_cents


## systems §9.2 AA1: cash + inventory at hidden market × liquidity haircut.
## Haircuts stay in economy math. UI only sees the summed cents.
const LIQUIDITY_HAIRCUT_SEALED := 0.85
const LIQUIDITY_HAIRCUT_SINGLES := 0.7
const LIQUIDITY_HAIRCUT_GRADED := 0.6
const LIQUIDITY_HAIRCUT_ACCESSORIES := 0.9


func net_worth_cents() -> int:
	return balance_cents + _liquidity_inventory_cents()


func liquidity_haircut(product_class: ProductSKU.ProductClass) -> float:
	match product_class:
		ProductSKU.ProductClass.SEALED:
			return LIQUIDITY_HAIRCUT_SEALED
		ProductSKU.ProductClass.SINGLE:
			return LIQUIDITY_HAIRCUT_SINGLES
		ProductSKU.ProductClass.GRADED:
			return LIQUIDITY_HAIRCUT_GRADED
		ProductSKU.ProductClass.ACCESSORY:
			return LIQUIDITY_HAIRCUT_ACCESSORIES
		_:
			return 0.0


func _liquidity_inventory_cents() -> int:
	var model := InventoryService.model
	if model == null:
		return 0
	var total := 0
	for lot: StockLot in model.stock_lots:
		if lot == null or lot.sku == null or lot.qty <= 0:
			continue
		total += _haircut_units(
			DemandSignals.market_cents_for(lot.sku.id),
			lot.sku.product_class,
			lot.qty
		)
	for card: CardInstance in model.cards:
		if card == null:
			continue
		total += _haircut_units(
			DemandSignals.market_cents_for(card.sku_id),
			ProductSKU.ProductClass.SINGLE,
			1
		)
	for slab: SlabInstance in model.slabs:
		if slab == null:
			continue
		total += _haircut_units(
			DemandSignals.market_cents_for(slab.sku_id()),
			ProductSKU.ProductClass.GRADED,
			1
		)
	return total


func _haircut_units(
	market_cents: int,
	product_class: ProductSKU.ProductClass,
	quantity: int
) -> int:
	if market_cents <= 0 or quantity <= 0:
		return 0
	return roundi(float(market_cents) * liquidity_haircut(product_class)) * quantity


func get_ledger() -> Array[LedgerEntry]:
	return _ledger.duplicate()


func settle_weekly_obligations(day: int) -> bool:
	if not GameState.balance_config.is_rent_due_day(day):
		return false
	return record_expense(
		GameState.shop.weekly_rent_cents(day),
		&"rent",
		"Weekly rent"
	)


func take_payday_loan() -> bool:
	var config := GameState.balance_config
	if not config.loan_shark_enabled or _payday_loan_days_remaining > 0:
		return false
	return apply_loan_shark_terms()


func apply_loan_shark_terms() -> bool:
	var config := GameState.balance_config
	if not config.loan_shark_enabled:
		return false
	if not record_income(
		config.loan_shark_cash_cents,
		&"payday_loan",
		"Loan shark principal"
	):
		return false
	_payday_loan_days_remaining = config.loan_shark_days
	GameState.adjust_reputation(-config.loan_shark_rep_hit)
	return true


func has_active_payday_loan() -> bool:
	return _payday_loan_days_remaining > 0


func payday_loan_days_remaining() -> int:
	return _payday_loan_days_remaining


func restore_payday_loan_days(days: int) -> void:
	_payday_loan_days_remaining = maxi(0, days)


func settle_payday_loan() -> bool:
	if _payday_loan_days_remaining <= 0:
		return false
	var daily := GameState.balance_config.loan_shark_daily_cents
	if daily > 0:
		record_forced_expense(daily, &"payday_loan", "Loan shark daily")
	_payday_loan_days_remaining -= 1
	return true


func settle_day(day: int) -> void:
	# Wage and utility services can attach here without changing phase ownership.
	GameState.begin_settle_obligations()
	if GameState.balance_config.is_rent_due_day(day):
		if settle_weekly_obligations(day):
			GameState.note_rent_paid()
		else:
			GameState.note_rent_missed()
	for wage: Dictionary in GameState.shop.take_due_wages():
		if not record_expense(
			int(wage.get("amount_cents", 0)),
			&"wages",
			String(wage.get("memo", "Staff wage"))
		):
			GameState.note_unpaid_wage()
	settle_payday_loan()
	online_listings.tick_shipping()
	_settle_shrink()
	DemandSignals.roll_settle_events()


func effective_shrink_rate() -> float:
	return GameState.shop.shrink_rate() * DemandSignals.active_shrink_multiplier()


func _settle_shrink() -> void:
	var base_rate := GameState.shop.shrink_rate()
	var shrink_mult := DemandSignals.active_shrink_multiplier()
	var rate := base_rate * shrink_mult
	var applied: Dictionary = InventoryService.apply_daily_shrink(rate)
	QaInstrumentation.record_shrink_applied({
		"day": GameState.current_day,
		"rate": rate,
		"base_rate": base_rate,
		"shrink_mult": shrink_mult,
		"cogs_cents": int(applied.get("cogs_cents", 0)),
		"loss_cents": int(applied.get("loss_cents", 0)),
		"units_removed": int(applied.get("units_removed", 0)),
		"target_loss_cents": int(applied.get("target_loss_cents", 0)),
		"floor_sealed_cogs_cents": int(applied.get("floor_sealed_cogs_cents", 0)),
		"floor_sealed_premium_rate": float(applied.get("floor_sealed_premium_rate", 0.0)),
		"floor_sealed_target_cents": int(applied.get("floor_sealed_target_cents", 0)),
		"floor_sealed_loss_cents": int(applied.get("floor_sealed_loss_cents", 0)),
		"floor_sealed_units_removed": int(applied.get("floor_sealed_units_removed", 0)),
		"understaffed": not GameState.shop.has_floor_staff_on_duty(),
		"staff_on_floor": GameState.shop.has_floor_staff_on_duty(),
		"theft_ring": DemandSignals.has_theft_ring(),
		"theft_bias": _on_duty_theft_bias(),
		"cameras_active": GameState.shop.has_active_cameras(),
	})


func _on_duty_theft_bias() -> bool:
	for member: StaffMember in GameState.shop.staff:
		if member.is_cashier() and member.on_duty_today and member.theft_bias:
			return true
	return false


func _record(kind: LedgerEntry.Kind, amount_cents: int, category: StringName, memo: String) -> bool:
	if amount_cents <= 0:
		push_warning("Transactions must have a positive amount.")
		return false

	var signed_amount := amount_cents if kind == LedgerEntry.Kind.INCOME else -amount_cents
	balance_cents += signed_amount
	var entry := LedgerEntry.new(kind, amount_cents, category, memo, GameState.current_day)
	_ledger.append(entry)
	EventBus.publish_transaction(entry)
	EventBus.publish_cash_changed(balance_cents)
	if GameState.current_phase != GameState.DayPhase.SETTLE:
		GameState.evaluate_campaign_win()
	return true


