class_name LedgerEntry
extends RefCounted

enum Kind {
	INCOME,
	EXPENSE,
}

var kind: Kind
var amount_cents: int
var category: StringName
var memo: String
var day: int


func _init(
	entry_kind: Kind,
	entry_amount_cents: int,
	entry_category: StringName,
	entry_memo: String,
	entry_day: int
) -> void:
	kind = entry_kind
	amount_cents = entry_amount_cents
	category = entry_category
	memo = entry_memo
	day = entry_day
