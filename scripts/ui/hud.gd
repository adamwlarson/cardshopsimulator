extends Control

@onready var cash_label: Label = %CashLabel
@onready var day_label: Label = %DayLabel


func _ready() -> void:
	EventBus.cash_changed.connect(_update_cash)
	EventBus.day_started.connect(_update_day)
	_update_cash(Economy.balance_cents)
	_update_day(GameState.current_day)


func _update_cash(balance_cents: int) -> void:
	cash_label.text = "Cash  $%s" % _format_cents(balance_cents)


func _update_day(day: int) -> void:
	day_label.text = "Day %d" % day


func _format_cents(value: int) -> String:
	var dollars := value / 100
	var cents := absi(value % 100)
	return "%d.%02d" % [dollars, cents]
