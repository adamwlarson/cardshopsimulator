class_name DemandSignalPresenter
extends RefCounted

const UNDERCUT_FILL_FACTOR := 0.90

enum PriceContext {
	CUSTOMER_BUYING_FROM_SHOP,
	CUSTOMER_SELLING_TO_SHOP,
	SHOP_BUYING_OPPORTUNITY,
}


static func format_cents(value: int) -> String:
	var sign_text := "-" if value < 0 else ""
	var absolute := absi(value)
	return "%s$%s.%02d" % [
		sign_text,
		_group_thousands(absolute / 100),
		absolute % 100,
	]


static func _group_thousands(dollars: int) -> String:
	var raw := str(dollars)
	var grouped := ""
	while raw.length() > 3:
		grouped = "," + raw.substr(raw.length() - 3, 3) + grouped
		raw = raw.substr(0, raw.length() - 3)
	return raw + grouped


static func undercut_fill_cents(suggested_price_cents: int) -> int:
	return maxi(1, floori(suggested_price_cents * UNDERCUT_FILL_FACTOR))


static func wants_label(
	display_name: String,
	sku_id: StringName = &"",
	condition: String = "",
	grader: String = "",
	grade: float = -1.0,
	quantity: int = 1
) -> String:
	var name_text := display_name.strip_edges()
	if name_text.is_empty() or _looks_like_raw_sku(name_text):
		name_text = humanize_sku_id(
			sku_id if not sku_id.is_empty() else StringName(display_name)
		)
	var detail := ""
	if not grader.strip_edges().is_empty() and grade >= 0.0:
		detail = "%s %s" % [grader.strip_edges(), _format_grade(grade)]
	elif not condition.strip_edges().is_empty():
		detail = condition.strip_edges()
	var line := (
		name_text if detail.is_empty() else "%s · %s" % [name_text, detail]
	)
	if quantity > 1:
		line += " ×%d" % quantity
	return line


static func humanize_sku_id(sku_id: StringName) -> String:
	var raw := String(sku_id)
	if raw.is_empty():
		push_warning("Wants label missing display name and SKU.")
		return "Unknown card"
	var parts := raw.split("-")
	var start := 1 if parts.size() > 1 and (parts[0] == "AA" or parts[0] == "ACC") else 0
	var words: PackedStringArray = []
	for index: int in range(start, parts.size()):
		var part := String(parts[index])
		if part.is_empty():
			continue
		words.append(part.capitalize())
	var result := " ".join(words)
	if result.is_empty():
		result = "Unknown card"
	push_warning(
		"Wants label missing display name for SKU %s; humanized to '%s'."
		% [raw, result]
	)
	return result


static func _looks_like_raw_sku(text: String) -> bool:
	return text.begins_with("AA-") or text.begins_with("ACC-")


static func _format_grade(grade: float) -> String:
	if is_equal_approx(grade, roundf(grade)):
		return str(int(roundf(grade)))
	return str(grade)


static func research_action_label(cash_cents: int, attention_cost: int) -> String:
	return "Research · %s · Att %d" % [format_cents(cash_cents), attention_cost]


static func rearrange_action_label(attention_cost: int) -> String:
	return "Rearrange · Att %d" % attention_cost


static func parse_cents(text: String) -> int:
	var cleaned := text.strip_edges().trim_prefix("$").replace(",", "")
	if cleaned.is_empty():
		return 0
	var parts := cleaned.split(".", false, 1)
	if not parts[0].is_valid_int():
		return 0
	var dollars := int(parts[0])
	var cents := 0
	if parts.size() > 1:
		var cents_text := parts[1].left(2).rpad(2, "0")
		if not cents_text.is_valid_int():
			return 0
		cents = int(cents_text)
	return dollars * 100 + cents


static func price_label(context: PriceContext) -> String:
	match context:
		PriceContext.CUSTOMER_BUYING_FROM_SHOP:
			return "Your list"
		PriceContext.CUSTOMER_SELLING_TO_SHOP:
			return "You offer"
		PriceContext.SHOP_BUYING_OPPORTUNITY:
			return "Ask"
	return ""


static func band_chip(band: StringName) -> String:
	var label := String(band).to_upper()
	match String(band):
		"cold":
			return "○ %s" % label
		"steady":
			return "● %s" % label
		"warm":
			return "▲ %s" % label
		"hot":
			return "■ %s" % label
	return "● %s" % label


static func position_chip(position: StringName) -> String:
	var label := String(position).replace("_", " ").capitalize()
	match String(position):
		"undercut":
			return "▼ %s" % label
		"competitive":
			return "◆ %s" % label
		"premium":
			return "▲ %s" % label
	return "◆ %s" % label


static func move_feel_chip(move_feel: StringName) -> String:
	var label := String(move_feel).replace("_", " ").capitalize()
	match String(move_feel):
		"likely_sits":
			return "▢ %s" % label
		"should_move":
			return "→ %s" % label
		"walk_risk":
			return "! %s" % label
	return "· %s" % label


static func opportunity_row(dto: BuyConfirmSignal) -> String:
	var name_text := dto.display_name
	if name_text.strip_edges().is_empty():
		name_text = String(dto.sku_id)
	return "%s · %s ×%d\nAsk %s · %s · %s confidence" % [
		String(dto.channel).capitalize(),
		name_text,
		dto.quantity,
		format_cents(dto.lot_total_cents),
		band_chip(dto.shown_demand_band),
		String(dto.confidence).capitalize(),
	]


static func priceable_stock_row(dto: PriceConfirmSignal) -> String:
	var name_text := dto.display_name
	if name_text.strip_edges().is_empty():
		name_text = String(dto.sku_id)
	return "%s ×%d\nYour list %s · %s" % [
		name_text,
		dto.quantity,
		format_cents(dto.listed_price_cents),
		dto.display_context,
	]


static func buy_summary(dto: BuyConfirmSignal) -> String:
	return "\n".join([
		"%s: %s each · %s total" % [
			price_label(PriceContext.SHOP_BUYING_OPPORTUNITY),
			format_cents(dto.unit_cost_cents),
			format_cents(dto.lot_total_cents),
		],
		"Comp range: %s – %s" % [
			format_cents(dto.shown_comp_low_cents),
			format_cents(dto.shown_comp_high_cents),
		],
		"Demand: %s · Confidence: %s" % [
			band_chip(dto.shown_demand_band),
			String(dto.confidence).capitalize(),
		],
		"Condition: %s" % dto.condition_cue,
		"After buy: %s %s · Space: %s %d needed / %d free" % [
			"✓" if dto.remaining_cash_cents >= 0 else "✗",
			format_cents(dto.remaining_cash_cents),
			"✓" if dto.space_free >= dto.space_required else "✗",
			dto.space_required,
			dto.space_free,
		],
	])


static func buylist_seller_summary(dto: BuyConfirmSignal) -> String:
	return "\n".join([
		"Selling: %s ×%d" % [dto.display_name, dto.quantity],
		"%s: %s each · %s total" % [
			price_label(PriceContext.CUSTOMER_SELLING_TO_SHOP),
			format_cents(dto.unit_cost_cents),
			format_cents(dto.lot_total_cents),
		],
		"Comp range: %s – %s" % [
			format_cents(dto.shown_comp_low_cents),
			format_cents(dto.shown_comp_high_cents),
		],
		"Demand: %s · Confidence: %s" % [
			band_chip(dto.shown_demand_band),
			String(dto.confidence).capitalize(),
		],
		"Condition: %s" % dto.condition_cue,
	])


static func price_summary(
	dto: PriceConfirmSignal,
	include_signal_chips: bool = true
) -> String:
	var percent := roundi(dto.price_delta_percent * 100.0)
	var lines: PackedStringArray = [
		"Suggested (noisy): %s" % format_cents(dto.suggested_price_cents),
		"Vs suggestion: %s (%+d%%)" % [
			format_cents(dto.price_delta_cents),
			percent,
		],
	]
	if include_signal_chips:
		lines.append(
			"Position: %s · Demand: %s" % [
				position_chip(dto.position),
				band_chip(dto.shown_demand_band),
			]
		)
		lines.append(
			"Move feel: %s · %s" % [
				move_feel_chip(dto.move_feel),
				dto.display_context,
			]
		)
	elif not dto.display_context.strip_edges().is_empty():
		lines.append(dto.display_context)
	return "\n".join(lines)
