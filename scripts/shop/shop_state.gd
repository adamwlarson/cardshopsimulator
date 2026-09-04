class_name ShopState
extends RefCounted

enum Tier {
	SMALL,
	MEDIUM,
}

const CASHIER_WAGE_CENTS := 8_000
const CHEAP_CASHIER_WAGE_CENTS := 4_500
const CASHIER_RELIABILITY := 0.85
const CHEAP_CASHIER_RELIABILITY := 0.50
const SMALL_GRID_WIDTH := 10
const SMALL_GRID_HEIGHT := 8
const MEDIUM_GRID_WIDTH := 12
const MEDIUM_GRID_HEIGHT := 11
const MEDIUM_CASE_SLOT_BONUS := 12
const MEDIUM_BACKSTOCK_BONUS := 20

var tier: Tier = Tier.SMALL
var staff: Array[StaffMember] = []
var grid_width: int = SMALL_GRID_WIDTH
var grid_height: int = SMALL_GRID_HEIGHT
var medium_lease_signed_day: int = -1
var _config: BalanceConfig


func reset(config: BalanceConfig) -> void:
	_config = config
	tier = Tier.SMALL
	staff.clear()
	grid_width = SMALL_GRID_WIDTH
	grid_height = SMALL_GRID_HEIGHT
	medium_lease_signed_day = -1
	if config != null and config.start_with_trainee_cashier:
		var trainee := _make_cashier(false)
		trainee.display_name = "Trainee cashier"
		trainee.free_days_remaining = maxi(0, config.trainee_free_days)
		staff.append(trainee)


func hired_count() -> int:
	return staff.size()


func staff_cap() -> int:
	var small_cap := 1
	var medium_cap := 3
	if _config != null:
		small_cap = _config.staff_cap_small
		medium_cap = _config.staff_cap_medium
	if tier == Tier.MEDIUM:
		return medium_cap
	return small_cap


func can_hire() -> bool:
	return hired_count() < staff_cap()


func is_owner_only() -> bool:
	return hired_count() == 0


func inspect_attention_cost() -> int:
	var cost := 5
	if _config != null:
		cost = _config.inspect_attention
	# Specialist on duty later may reduce Owner 5 → 2.
	return maxi(1, cost)


func hire_cashier(cheap: bool) -> StaffMember:
	if not can_hire():
		return null
	var member := _make_cashier(cheap)
	staff.append(member)
	return member


func cash_meets_medium(cash_cents: int) -> bool:
	return _config != null and cash_cents >= _config.expand_medium_cash_cents


func rep_meets_medium(reputation: int) -> bool:
	return _config != null and reputation >= _config.expand_medium_rep


func can_expand_medium(cash_cents: int, reputation: int) -> bool:
	return (
		tier == Tier.SMALL
		and cash_meets_medium(cash_cents)
		and rep_meets_medium(reputation)
	)


func expand_to_medium(signed_day: int, cash_cents: int, reputation: int) -> bool:
	if not can_expand_medium(cash_cents, reputation):
		return false
	tier = Tier.MEDIUM
	medium_lease_signed_day = signed_day
	grid_width = MEDIUM_GRID_WIDTH
	grid_height = MEDIUM_GRID_HEIGHT
	return true


func weekly_rent_cents(day: int) -> int:
	if _config == null:
		return 0
	if (
		tier == Tier.MEDIUM
		and medium_lease_signed_day >= 0
		and day > medium_lease_signed_day
	):
		return _config.rent_medium_weekly_cents
	return _config.rent_small_weekly_cents


func take_due_wages() -> Array[Dictionary]:
	var due: Array[Dictionary] = []
	var wage_mult := _config.wage_mult if _config != null else 1.0
	for member: StaffMember in staff:
		if member.free_days_remaining > 0:
			member.free_days_remaining -= 1
			continue
		due.append({
			"amount_cents": maxi(1, roundi(float(member.wage_cents) * wage_mult)),
			"memo": "%s wage" % member.display_name,
		})
	return due


func _make_cashier(cheap: bool) -> StaffMember:
	var member := StaffMember.new()
	member.role = &"cashier"
	if cheap:
		member.display_name = "Cheap cashier"
		member.wage_cents = CHEAP_CASHIER_WAGE_CENTS
		member.reliability = CHEAP_CASHIER_RELIABILITY
		member.theft_bias = true
	else:
		member.display_name = "Cashier"
		member.wage_cents = CASHIER_WAGE_CENTS
		member.reliability = CASHIER_RELIABILITY
		member.theft_bias = false
	return member
