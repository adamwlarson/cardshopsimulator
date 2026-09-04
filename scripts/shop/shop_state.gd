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
## Option B lock: 14×10 = 140 tiles @ 0.9 m → ~1,221 sq ft usable
## (systems-design Medium markets 1,200; SoT ~1,020 was a tile-area miscalc).
const MEDIUM_GRID_WIDTH := 14
const MEDIUM_GRID_HEIGHT := 10
const MEDIUM_CASE_SLOT_BONUS := 12
const MEDIUM_BACKSTOCK_BONUS := 20
const SQ_FT_PER_TILE := 8.71875

var tier: Tier = Tier.SMALL
var staff: Array[StaffMember] = []
var grid_width: int = SMALL_GRID_WIDTH
var grid_height: int = SMALL_GRID_HEIGHT
var medium_lease_signed_day: int = -1
var specialist_on_duty: bool = false
var layout := ShopLayout.new()
var floor_grid: ShopGrid = ShopGrid.small_default()
var _config: BalanceConfig


func reset(config: BalanceConfig) -> void:
	_config = config
	tier = Tier.SMALL
	staff.clear()
	grid_width = SMALL_GRID_WIDTH
	grid_height = SMALL_GRID_HEIGHT
	medium_lease_signed_day = -1
	specialist_on_duty = false
	layout.reset_small()
	floor_grid = ShopGrid.small_default()
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


func has_specialist_on_duty() -> bool:
	if specialist_on_duty:
		return true
	for member: StaffMember in staff:
		if member.role == &"specialist":
			return true
	return false


func set_specialist_on_duty(enabled: bool) -> void:
	specialist_on_duty = enabled


func inspect_attention_cost() -> int:
	var cost := 5
	if _config != null:
		cost = _config.inspect_attention
		if has_specialist_on_duty():
			cost = _config.inspect_attention_specialist
	elif has_specialist_on_duty():
		cost = 2
	return maxi(1, cost)


func research_attention_cost() -> int:
	var cost := 15
	if _config != null:
		cost = _config.research_attention
		if has_specialist_on_duty():
			cost = mini(cost, _config.research_attention_specialist)
	elif has_specialist_on_duty():
		cost = 10
	return maxi(1, cost)


func rearrange_attention_cost() -> int:
	if _config != null:
		return maxi(1, _config.rearrange_attention)
	return 10


func research_cash_cost_cents() -> int:
	if _config != null:
		return maxi(0, _config.research_cost_cents)
	return 5_000


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


func preview_expand_medium() -> StringName:
	return layout.preview_expand(MEDIUM_GRID_WIDTH, MEDIUM_GRID_HEIGHT)


func can_sign_medium_lease(cash_cents: int, reputation: int) -> bool:
	return (
		can_expand_medium(cash_cents, reputation)
		and preview_expand_medium() == &"ok"
	)


func expand_to_medium(signed_day: int, cash_cents: int, reputation: int) -> bool:
	if not can_sign_medium_lease(cash_cents, reputation):
		return false
	if layout.expand(MEDIUM_GRID_WIDTH, MEDIUM_GRID_HEIGHT) != &"ok":
		return false
	tier = Tier.MEDIUM
	medium_lease_signed_day = signed_day
	grid_width = MEDIUM_GRID_WIDTH
	grid_height = MEDIUM_GRID_HEIGHT
	floor_grid.expand(MEDIUM_GRID_WIDTH, MEDIUM_GRID_HEIGHT)
	return true


func tile_count() -> int:
	return grid_width * grid_height


func walkable_tile_count() -> int:
	return layout.walkable_tile_count()


func usable_sq_ft() -> float:
	return float(tile_count()) * SQ_FT_PER_TILE


func to_save() -> Dictionary:
	var staff_rows: Array[Dictionary] = []
	for member: StaffMember in staff:
		staff_rows.append(member.to_save())
	return {
		"tier": int(tier),
		"grid_width": grid_width,
		"grid_height": grid_height,
		"medium_lease_signed_day": medium_lease_signed_day,
		"specialist_on_duty": specialist_on_duty,
		"layout": layout.to_save(),
		"staff": staff_rows,
	}


func apply_save(data: Dictionary, config: BalanceConfig) -> void:
	_config = config
	var saved_tier := int(data.get("tier", Tier.SMALL))
	if saved_tier == int(Tier.MEDIUM):
		tier = Tier.MEDIUM
	else:
		tier = Tier.SMALL
	grid_width = int(data.get("grid_width", SMALL_GRID_WIDTH))
	grid_height = int(data.get("grid_height", SMALL_GRID_HEIGHT))
	medium_lease_signed_day = int(data.get("medium_lease_signed_day", -1))
	specialist_on_duty = bool(data.get("specialist_on_duty", false))
	var layout_data: Variant = data.get("layout", {})
	if layout_data is Dictionary:
		layout.apply_save(layout_data as Dictionary)
	else:
		layout.reset_small()
	floor_grid = ShopGrid.small_default()
	floor_grid.expand(grid_width, grid_height)
	staff.clear()
	var staff_rows: Array = data.get("staff", [])
	for row: Variant in staff_rows:
		if row is Dictionary:
			staff.append(StaffMember.from_save(row as Dictionary))


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
