extends Node

var balance_cents: int = 0
var _ledger: Array[LedgerEntry] = []
var _payday_loan_days_remaining: int = 0


func _ready() -> void:
	reset()


func reset() -> void:
	balance_cents = GameState.balance_config.start_cash_cents
	_ledger.clear()
	_payday_loan_days_remaining = 0
	EventBus.publish_cash_changed(balance_cents)


func record_income(amount_cents: int, category: StringName, memo: String = "") -> bool:
	return _record(LedgerEntry.Kind.INCOME, amount_cents, category, memo)


func record_expense(amount_cents: int, category: StringName, memo: String = "") -> bool:
	if amount_cents > balance_cents:
		return false
	return _record(LedgerEntry.Kind.EXPENSE, amount_cents, category, memo)


func can_afford(amount_cents: int) -> bool:
	return amount_cents >= 0 and balance_cents >= amount_cents


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
	if not record_income(
		config.loan_shark_cash_cents,
		&"payday_loan",
		"Payday loan principal"
	):
		return false
	_payday_loan_days_remaining = config.loan_shark_days
	GameState.adjust_reputation(-config.loan_shark_rep_hit)
	return true


func has_active_payday_loan() -> bool:
	return _payday_loan_days_remaining > 0


func settle_payday_loan() -> bool:
	if _payday_loan_days_remaining <= 0:
		return false
	if not record_expense(
		GameState.balance_config.loan_shark_daily_cents,
		&"payday_loan",
		"Payday loan payment"
	):
		return false
	_payday_loan_days_remaining -= 1
	return true


func settle_day(day: int) -> void:
	# Wage and utility services can attach here without changing phase ownership.
	settle_weekly_obligations(day)
	for wage: Dictionary in GameState.shop.take_due_wages():
		record_expense(
			int(wage.get("amount_cents", 0)),
			&"wages",
			String(wage.get("memo", "Staff wage"))
		)
	settle_payday_loan()
	_settle_shrink()
	DemandSignals.roll_settle_events()


func _settle_shrink() -> void:
	var rate := GameState.shop.shrink_rate()
	var applied: Dictionary = InventoryService.apply_daily_shrink(rate)
	QaInstrumentation.record_shrink_applied({
		"day": GameState.current_day,
		"rate": rate,
		"cogs_cents": int(applied.get("cogs_cents", 0)),
		"loss_cents": int(applied.get("loss_cents", 0)),
		"units_removed": int(applied.get("units_removed", 0)),
		"understaffed": GameState.shop.is_floor_understaffed()
			or not GameState.shop.has_cashier_on_duty(),
		"theft_bias": _on_duty_theft_bias(),
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
	return true


