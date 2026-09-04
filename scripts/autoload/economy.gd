extends Node

var balance_cents: int = 0
var _ledger: Array[LedgerEntry] = []


func _ready() -> void:
	EventBus.day_started.connect(_on_day_started)


func reset() -> void:
	balance_cents = GameState.balance_config.starting_cash_cents
	_ledger.clear()
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


func _on_day_started(day: int) -> void:
	# TODO: Move this boundary to an explicit weekly settle phase.
	if day > GameState.FIRST_DAY and day % 7 == 0:
		record_expense(
			GameState.balance_config.weekly_rent_cents,
			&"rent",
			"Weekly rent"
		)
