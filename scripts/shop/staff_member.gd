class_name StaffMember
extends Resource

const SCENE_CASHIER := (
	"res://assets/chars/staff/char_cashier_01/"
	+ "char_cashier_01.glb"
)
const CLIP_IDLE_STAND := &"idle_stand"
const BODY_HEIGHT := 1.72

@export var role: StringName = &"cashier"
@export var display_name: String = "Cashier"
@export var wage_cents: int = 8_000
@export var reliability: float = 0.85
@export var theft_bias: bool = false
@export var free_days_remaining: int = 0
@export var on_duty_today: bool = true


func is_cashier() -> bool:
	return role == &"cashier"


func is_specialist() -> bool:
	return role == &"specialist"


func visual_scene_path() -> String:
	if is_cashier():
		return SCENE_CASHIER
	return ""


func clamped_reliability() -> float:
	return clampf(reliability, 0.0, 1.0)


func to_save() -> Dictionary:
	return {
		"role": String(role),
		"display_name": display_name,
		"wage_cents": wage_cents,
		"reliability": reliability,
		"theft_bias": theft_bias,
		"free_days_remaining": free_days_remaining,
		"on_duty_today": on_duty_today,
	}


static func from_save(data: Dictionary) -> StaffMember:
	var member := StaffMember.new()
	member.role = StringName(data.get("role", "cashier"))
	member.display_name = String(data.get("display_name", "Cashier"))
	member.wage_cents = int(data.get("wage_cents", 8_000))
	member.reliability = float(data.get("reliability", 0.85))
	member.theft_bias = bool(data.get("theft_bias", false))
	member.free_days_remaining = int(data.get("free_days_remaining", 0))
	member.on_duty_today = bool(data.get("on_duty_today", true))
	return member
