extends Node

signal cash_changed(balance_cents: int)
signal transaction_recorded(entry: LedgerEntry)
signal inventory_changed(sku: StringName, quantity: int)
signal day_started(day: int)
signal customer_arrived(customer: CustomerProfile)

func publish_cash_changed(balance_cents: int) -> void:
	cash_changed.emit(balance_cents)


func publish_transaction(entry: LedgerEntry) -> void:
	transaction_recorded.emit(entry)


func publish_inventory_changed(sku: StringName, quantity: int) -> void:
	inventory_changed.emit(sku, quantity)
