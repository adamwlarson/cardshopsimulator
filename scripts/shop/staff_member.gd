class_name StaffMember
extends Resource

@export var role: StringName = &"cashier"
@export var display_name: String = "Cashier"
@export var wage_cents: int = 8_000
@export var reliability: float = 0.85
@export var theft_bias: bool = false
@export var free_days_remaining: int = 0


func to_save() -> Dictionary:
	return {
		"role": String(role),
		"display_name": display_name,
		"wage_cents": wage_cents,
		"reliability": reliability,
		"theft_bias": theft_bias,
		"free_days_remaining": free_days_remaining,
	}


static func from_save(data: Dictionary) -> StaffMember:
	var member := StaffMember.new()
	member.role = StringName(data.get("role", "cashier"))
	member.display_name = String(data.get("display_name", "Cashier"))
	member.wage_cents = int(data.get("wage_cents", 8_000))
	member.reliability = float(data.get("reliability", 0.85))
	member.theft_bias = bool(data.get("theft_bias", false))
	member.free_days_remaining = int(data.get("free_days_remaining", 0))
	return member
