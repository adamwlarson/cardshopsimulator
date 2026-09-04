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


func reset(config: BalanceConfig) -> void:
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
	if tier == Tier.MEDIUM:
		return GameState.balance_config.staff_cap_medium
	return GameState.balance_config.staff_cap_small


func can_hire() -> bool:
	return hired_count() < staff_cap()


func is_owner_only() -> bool:
	return hired_count() == 0


func hire_cashier(cheap: bool) -> StaffMember:
	if not can_hire():
		return null
	var member := _make_cashier(cheap)
	staff.append(member)
	return member


func cash_meets_medium() -> bool:
	return Economy.balance_cents >= GameState.balance_config.expand_medium_cash_cents


func rep_meets_medium() -> bool:
	return GameState.current_reputation >= GameState.balance_config.expand_medium_rep


func can_expand_medium() -> bool:
	return tier == Tier.SMALL and cash_meets_medium() and rep_meets_medium()


func expand_to_medium(signed_day: int) -> bool:
	if not can_expand_medium():
		return false
	tier = Tier.MEDIUM
	medium_lease_signed_day = signed_day
	grid_width = MEDIUM_GRID_WIDTH
	grid_height = MEDIUM_GRID_HEIGHT
	InventoryService.apply_medium_capacity(
		MEDIUM_CASE_SLOT_BONUS,
		MEDIUM_BACKSTOCK_BONUS
	)
	return true


func weekly_rent_cents(day: int) -> int:
	var config := GameState.balance_config
	if (
		tier == Tier.MEDIUM
		and medium_lease_signed_day >= 0
		and day > medium_lease_signed_day
	):
		return config.rent_medium_weekly_cents
	return config.rent_small_weekly_cents


func daily_wage_cents() -> int:
	var total := 0
	var wage_mult := GameState.balance_config.wage_mult
	for member: StaffMember in staff:
		if member.free_days_remaining > 0:
			continue
		total += maxi(1, roundi(float(member.wage_cents) * wage_mult))
	return total


func settle_wages() -> void:
	for member: StaffMember in staff:
		if member.free_days_remaining > 0:
			member.free_days_remaining -= 1
			continue
		var wage_cents := maxi(
			1,
			roundi(float(member.wage_cents) * GameState.balance_config.wage_mult)
		)
		Economy.record_expense(
			wage_cents,
			&"wages",
			"%s wage" % member.display_name
		)


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
