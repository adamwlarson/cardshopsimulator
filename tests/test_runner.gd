extends SceneTree

const EASY_CONFIG: BalanceConfig = preload("res://data/balance/easy.tres")
const NORMAL_CONFIG: BalanceConfig = preload("res://data/balance/normal.tres")
const HARD_CONFIG: BalanceConfig = preload("res://data/balance/hard.tres")
const SPIKE_STAPLE_BEAT := &"sec10_4_spike_staple"
const RENT_FIRESALE_BEAT := &"sec10_6_rent_firesale"
const TITAN_HYPE_BEAT := &"sec10_7_titan_hype"
const SHOWCASE_BEAT := &"sec10_8_slab_vs_singles"

var _failures: int = 0
var _qa := QaInstrumentationService.new()
var _captured_scripted_customer: CustomerProfile
var _captured_price_sku: StringName = &""
var _captured_price_beat: StringName = &""
var _captured_price_mode: StringName = &""
var _captured_price_focus_count: int = 0
var _captured_rent_decision: Dictionary = {}
var _event_bus: Node
var _game_state: Node
var _economy: Node
var _inventory_service: Node
var _demand_signals: Node
var _beat_director: Node
var _qa_autoload: Node

class FakeCustomerInventory:
	extends Node

	var sold: bool = false
	var bought: bool = false

	func find_listed_offer(
		_interest_tags: Array[StringName],
		_budget_cents: int
	) -> Dictionary:
		return {
			"sku_id": &"ACC-SLV-60",
			"listed_price_cents": 599,
		}

	func confirm_customer_sale(
		_sku_id: StringName,
		_sale_price_cents: int
	) -> bool:
		sold = true
		return true

	func confirm_stock_purchase(
		_sku_id: StringName,
		_quantity: int,
		_unit_cost_cents: int,
		_expected_margin_cents: int,
		_location: InventoryLocation
	) -> bool:
		bought = true
		return true


func _initialize() -> void:
	_event_bus = root.get_node("EventBus")
	_game_state = root.get_node("GameState")
	_economy = root.get_node("Economy")
	_inventory_service = root.get_node("InventoryService")
	_demand_signals = root.get_node("DemandSignals")
	_beat_director = root.get_node("BeatDirector")
	_qa_autoload = root.get_node("QaInstrumentation")
	_event_bus.connect(
		"scripted_customer_requested",
		_capture_scripted_customer
	)
	_event_bus.connect("price_focus_requested", _capture_price_focus)
	_event_bus.connect("rent_decision_requested", _capture_rent_decision)
	_test_pricing_spread()
	_test_stock_lot_unit_cost()
	_test_inventory_mutations_and_capacity()
	_test_balance_seed_inventory()
	_test_buy_opportunity_picker_seed()
	_test_price_editor_inventory_picker()
	_test_demand_signal_dto_does_not_leak_truth()
	_test_demand_fairness_contract()
	_test_qa_instrumentation_payloads()
	_test_difficulty_balance_ordering()
	_test_normal_shop_capacity()
	_test_weekly_rent_schedule()
	_test_customer_archetype_weights()
	_test_customer_spawn_phase_gating()
	_test_day_phase_transitions()
	_test_negotiate_clamp()
	_test_customer_service_actions()
	_test_ui_price_labels()
	_test_ui_helpers_do_not_read_hidden_values()
	_test_wants_label_format()
	_test_prep_hud_seed_before_bind()
	_test_undercut_fill_boundary()
	_test_rent_firesale_beat()
	_test_spike_staple_beat()
	_test_titan_hype_price_focus()
	_test_day_ten_beat_serialization()
	_test_showcase_slab_and_singles_preconditions()
	_test_shop_camera_framing()

	if _failures == 0:
		print("All foundation tests passed.")
		_qa.free()
		quit(0)
	else:
		push_error("%d foundation test(s) failed." % _failures)
		_qa.free()
		quit(1)


func _test_pricing_spread() -> void:
	_expect_equal(PricingService.suggested_buy_price_cents(1000), 550, "default buy offer")
	_expect_equal(PricingService.suggested_sell_price_cents(600, 700), 720, "margin floor")
	_expect_equal(PricingService.spread_cents(550, 720), 170, "buy/sell spread")


func _test_stock_lot_unit_cost() -> void:
	var lot := StockLot.new()
	lot.qty = 4
	lot.acquired_cost_avg_cents = 250
	_expect_equal(lot.unit_cost_cents(), 250, "weighted unit cost")
	_expect_equal(lot.total_cost_cents(), 1000, "lot total cost")


func _test_inventory_mutations_and_capacity() -> void:
	var config := BalanceConfig.new()
	config.case_slots = 2
	config.backstock_bins = 1
	var inventory := InventoryModel.new(config)
	var backstock := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	var shelf := InventoryLocation.new(InventoryLocation.Type.SHELF)
	_expect_equal(inventory.add_stock(&"ACC-SLV-60", 2, 100, shelf), true, "add accessory lot")
	_expect_equal(inventory.add_stock(&"ACC-SLV-60", 2, 200, shelf), true, "merge accessory lot")
	_expect_equal(inventory.get_stock_quantity(&"ACC-SLV-60"), 4, "merged accessory quantity")
	_expect_equal(inventory.stock_lots[0].unit_cost_cents(), 150, "weighted lot average")
	_expect_equal(inventory.remove_stock(&"ACC-SLV-60", 3), true, "remove accessory stock")
	_expect_equal(inventory.remove_stock(&"ACC-SLV-60", 2), false, "reject stock underflow")
	_expect_equal(inventory.add_stock(&"AA-BASE-088", 1, 100, shelf), false, "single cannot use stock lot")
	_expect_equal(inventory.add_stock(&"AA-DUST-ETB", 1, 100, backstock), true, "first backstock bin")
	_expect_equal(inventory.add_stock(&"AA-SKIE-ETB", 1, 100, backstock), false, "backstock capacity")
	_expect_equal(inventory.move_stock(&"ACC-SLV-60", shelf, backstock, 1), false, "reject move to full backstock")
	_expect_equal(inventory.remove_stock(&"AA-DUST-ETB", 1), true, "remove complete stock lot")
	_expect_equal(inventory.move_stock(&"ACC-SLV-60", shelf, backstock, 1), true, "split lot into free backstock")
	_expect_equal(inventory.get_stock_quantity(&"ACC-SLV-60"), 1, "split move preserves quantity")

	var case_location := InventoryLocation.new(InventoryLocation.Type.CASE)
	var first_card := CardInstance.new(&"AA-BASE-088", 200, case_location)
	var second_card := CardInstance.new(&"AA-BASE-078", 200, case_location)
	_expect_equal(inventory.add_card(first_card), true, "first case card")
	_expect_equal(inventory.add_card(second_card), true, "second case card")
	var slab_card := CardInstance.new(&"AA-SKIE-052", 300)
	var slab := SlabInstance.new(slab_card, &"Prism Grade", 10.0, "CERT-1", 500, case_location)
	_expect_equal(inventory.add_slab(slab), false, "slab needs two free case slots")
	_expect_equal(inventory.case_slots_used(), 2, "case slot accounting")
	_expect_equal(inventory.remove_card(first_card), true, "remove first card")
	_expect_equal(inventory.remove_card(second_card), true, "remove second card")
	_expect_equal(inventory.add_slab(slab), true, "add slab with two free slots")
	_expect_equal(inventory.add_slab(slab), false, "reject duplicate slab object")
	var duplicate_card_slab := SlabInstance.new(
		slab_card, &"Vaultmark", 9.5, "CERT-2", 500, case_location
	)
	_expect_equal(
		inventory.add_slab(duplicate_card_slab),
		false,
		"reject duplicate slab card ownership"
	)
	_expect_equal(inventory.remove_slab(slab), true, "remove slab")

	var split_config := BalanceConfig.new()
	split_config.backstock_bins = 2
	var split_inventory := InventoryModel.new(split_config)
	var bin_zero := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK, 0)
	var bin_one := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK, 1)
	var bin_two := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK, 2)
	_expect_equal(split_inventory.add_stock(&"ACC-SLV-60", 2, 100, bin_zero), true, "fill first bin")
	_expect_equal(split_inventory.add_stock(&"ACC-TOP-25", 1, 100, bin_one), true, "fill second bin")
	_expect_equal(
		split_inventory.move_stock(&"ACC-SLV-60", bin_zero, bin_two, 1),
		false,
		"partial split cannot overflow bins"
	)


func _test_balance_seed_inventory() -> void:
	for config: BalanceConfig in [EASY_CONFIG, NORMAL_CONFIG, HARD_CONFIG]:
		var inventory := InventoryModel.new(config)
		inventory.reset_and_seed()
		_expect_equal(
			inventory.get_stock_quantity(&"AA-SKIE-BLST"),
			config.seed_blasters + config.seed_skie_blasters,
			"seed current-set blasters"
		)
		_expect_equal(
			inventory.get_stock_quantity(&"AA-DUST-ETB"),
			config.seed_dust_etbs,
			"seed Dust ETBs"
		)
		_expect_equal(
			inventory.get_stock_quantity(&"ACC-SLV-60"),
			ceili(config.seed_sleeves / 60.0),
			"seed sleeve packs"
		)
		_expect_equal(
			inventory.get_stock_quantity(&"ACC-TOP-25"),
			ceili(config.seed_toploaders / 25.0),
			"seed toploader packs"
		)
		_expect_equal(
			inventory.cards.size(),
			config.seed_named_staples + config.seed_bulk_cards,
			"seed card count"
		)
	_expect_equal(
		InventoryModel.new(NORMAL_CONFIG).get_sku(&"AA-SKIE-ETB") != null,
		true,
		"canon Skiefall ETB catalog SKU"
	)


func _test_buy_opportunity_picker_seed() -> void:
	var inventory := InventoryModel.new(NORMAL_CONFIG)
	var opportunities := BuyOpportunityCatalog.new().open_for_day(1, inventory.catalog)
	var has_dustway := false
	var has_distributor_moq := false
	for opportunity: BuyOpportunity in opportunities:
		if opportunity.sku_id == &"AA-DUST-ETB":
			has_dustway = true
		if (
			opportunity.channel == DemandSignalService.Channel.DISTRIBUTOR
			and opportunity.beat_id == &"distributor_moq"
			and opportunity.quantity > 1
		):
			has_distributor_moq = true
	_expect_equal(has_dustway, true, "Dustway buy opportunity available")
	_expect_equal(has_distributor_moq, true, "distributor MOQ opportunity available")
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("AA-SKIE-ETB"),
		false,
		"HUD does not hardcode sole Skiefall opportunity"
	)
	_expect_equal(
		hud_source.contains("DemandSignals.open_buy_signals()"),
		true,
		"HUD binds demand signal opportunity list"
	)


func _test_price_editor_inventory_picker() -> void:
	var inventory_service_script := load(
		"res://scripts/autoload/inventory_service.gd"
	) as Script
	var inventory_service := inventory_service_script.new() as Node
	var inventory_model := InventoryModel.new(NORMAL_CONFIG)
	inventory_model.reset_and_seed()
	inventory_service.set("model", inventory_model)
	var priceable_stock: Array = inventory_service.call("get_priceable_stock")
	var priceable_skus: Array[StringName] = []
	var has_non_dustway_sku := false
	for item: Dictionary in priceable_stock:
		var sku_id := StringName(item["sku_id"])
		priceable_skus.append(sku_id)
		if sku_id != &"AA-DUST-ETB":
			has_non_dustway_sku = true
	_expect_equal(
		priceable_skus.size() > 1,
		true,
		"price picker exposes multiple seeded SKUs"
	)
	_expect_equal(
		has_non_dustway_sku,
		true,
		"price picker is not Dustway-only"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("DemandSignals.priceable_stock_signals()"),
		true,
		"HUD binds priceable inventory signals"
	)
	_expect_equal(
		hud_source.contains("AA-DUST-ETB"),
		false,
		"HUD does not hardcode Dustway price target"
	)
	inventory_service.free()


func _test_demand_signal_dto_does_not_leak_truth() -> void:
	_qa.set_force_enabled(false)
	var market_state := MarketState.new()
	market_state.update_sku(&"AA-SKIE-047", 2200, 0.75)
	var service := DemandSignalService.new(NORMAL_CONFIG, market_state, 42, _qa)
	var buy_signal := service.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		1200, 2, 800_000, 1, 3
	)
	var price_signal := service.price_confirm(
		1, &"AA-SKIE-047", 2300,
		InventoryLocation.new(InventoryLocation.Type.CASE)
	)
	_expect_dto_has_no_truth_fields(buy_signal, "buy signal")
	_expect_dto_has_no_truth_fields(price_signal, "price signal")
	_expect_equal(
		buy_signal.shown_demand_band,
		price_signal.shown_demand_band,
		"shared daily demand band"
	)
	_expect_equal(price_signal.move_feel.is_empty(), false, "qualitative move feel")


func _test_demand_fairness_contract() -> void:
	var market_state := MarketState.new()
	market_state.update_sku(&"AA-SKIE-047", 10_000, 0.70)
	var service := DemandSignalService.new(NORMAL_CONFIG, market_state, 99, _qa)
	var total_midpoint_error := 0.0
	var within_one_band := 0
	var sample_count := 0
	for day: int in range(1, 31):
		var dto := service.buy_confirm(
			day, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
			5000, 1, 800_000, 1, 10
		)
		var midpoint: int = (dto.shown_comp_low_cents + dto.shown_comp_high_cents) / 2
		total_midpoint_error += absf(float(midpoint - 10_000)) / 10_000.0
		var shown_index := _band_index(dto.shown_demand_band)
		var true_index := _band_index(&"warm")
		if absi(shown_index - true_index) <= 1:
			within_one_band += 1
		sample_count += 1
	_expect_equal(
		total_midpoint_error / sample_count <= NORMAL_CONFIG.fair_comp_mae_max,
		true,
		"30-day comp MAE fairness"
	)
	_expect_equal(
		float(within_one_band) / sample_count >= NORMAL_CONFIG.fair_band_within1_min,
		true,
		"30-day band fairness"
	)

	var narrow_default := DemandSignalService.new(NORMAL_CONFIG, market_state, 12, _qa)
	var narrow_research := DemandSignalService.new(NORMAL_CONFIG, market_state, 12, _qa)
	var default_dto := narrow_default.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		5000, 1, 800_000, 1, 10
	)
	var research_dto := narrow_research.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		5000, 1, 800_000, 1, 10, true
	)
	_expect_equal(
		research_dto.shown_comp_high_cents - research_dto.shown_comp_low_cents
		< default_dto.shown_comp_high_cents - default_dto.shown_comp_low_cents,
		true,
		"research narrows comp"
	)
	var distributor_service := DemandSignalService.new(
		NORMAL_CONFIG, market_state, 12, _qa
	)
	var distributor_dto := distributor_service.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.DISTRIBUTOR,
		5000, 1, 800_000, 1, 10
	)
	_expect_equal(
		distributor_dto.shown_comp_high_cents - distributor_dto.shown_comp_low_cents
		< default_dto.shown_comp_high_cents - default_dto.shown_comp_low_cents,
		true,
		"distributor comp tighter than marketplace"
	)

	for demand_score: float in [0.0, 1.0]:
		market_state.update_sku(&"AA-SKIE-047", 10_000, demand_score)
		var inversion_service := DemandSignalService.new(
			NORMAL_CONFIG, market_state, 123, _qa
		)
		for day: int in range(1, 101):
			var dto := inversion_service.buy_confirm(
				day, &"AA-SKIE-047", DemandSignalService.Channel.SHADY,
				5000, 1, 800_000, 1, 10
			)
			var cruel_inversion := (
				demand_score == 0.0 and dto.shown_demand_band == &"hot"
				or demand_score == 1.0 and dto.shown_demand_band == &"cold"
			)
			_expect_equal(cruel_inversion, false, "forbid hot-cold inversion")


func _test_qa_instrumentation_payloads() -> void:
	_qa.set_force_enabled(true)
	_qa.clear()
	_qa.begin_day(3, 10_000)
	_qa.end_day(3, 11_500)
	_qa.record_buy_confirm(&"AA-DUST-ETB", 2, 2500, 1500)
	var market_state := MarketState.new()
	market_state.update_sku(&"AA-DUST-ETB", 4499, 0.30)
	var service := DemandSignalService.new(NORMAL_CONFIG, market_state, 7, _qa)
	service.buy_confirm(
		3, &"AA-DUST-ETB", DemandSignalService.Channel.DISTRIBUTOR,
		2500, 2, 20_000, 1, 2
	)
	service.price_confirm(
		3, &"AA-DUST-ETB", 4799,
		InventoryLocation.new(InventoryLocation.Type.SHELF),
		DemandSignalService.Channel.DISTRIBUTOR
	)
	_qa.record_save_pre_write("save-data".to_utf8_buffer())
	_qa.record_save_post_load("save-data".to_utf8_buffer())
	var events := _qa.get_events()
	_expect_equal(events.size(), 6, "instrumentation event count")
	_expect_payload_keys(events[0], [&"day", &"cash_start", &"cash_end", &"delta"], "day cash payload")
	_expect_payload_keys(events[1], [&"sku", &"qty", &"unit_cost", &"expected_margin"], "buy payload")
	_expect_payload_keys(
		events[2],
		[
			&"screen", &"sku_id", &"shown_comp_low_cents", &"shown_comp_high_cents",
			&"true_market_cents", &"shown_demand_band", &"true_demand_band", &"confidence",
		],
		"buy demand signal payload"
	)
	_expect_payload_keys(
		events[3],
		[
			&"screen", &"sku_id", &"shown_comp_low_cents", &"shown_comp_high_cents",
			&"true_market_cents", &"shown_demand_band", &"true_demand_band", &"confidence",
			&"listed_price_cents", &"move_feel",
		],
		"price demand signal payload"
	)
	_expect_equal(
		events[4]["payload"]["hash"],
		events[5]["payload"]["hash"],
		"save round-trip hash"
	)
	_qa.set_force_enabled(false)


func _test_difficulty_balance_ordering() -> void:
	var cash_is_ordered := (
		EASY_CONFIG.start_cash_cents
		> NORMAL_CONFIG.start_cash_cents
		and NORMAL_CONFIG.start_cash_cents
		> HARD_CONFIG.start_cash_cents
	)
	_expect_equal(cash_is_ordered, true, "starting cash difficulty ordering")
	_expect_equal(HARD_CONFIG.loan_shark_enabled, false, "hard loan shark access")
	_expect_equal(NORMAL_CONFIG.start_cash_cents, 800_000, "normal starting cash")
	_expect_equal(NORMAL_CONFIG.start_reputation, 40, "normal starting reputation")
	_expect_equal(NORMAL_CONFIG.rent_small_weekly_cents, 120_000, "normal weekly rent")
	_expect_equal(NORMAL_CONFIG.first_rent_due_day, 7, "normal first rent due day")
	_expect_equal(NORMAL_CONFIG.event_chance_settle, 0.18, "normal settle event chance")
	_expect_equal(NORMAL_CONFIG.comp_noise_width_mult, 1.0, "normal comp noise width")
	_expect_equal(EASY_CONFIG.start_cash_cents, 1_200_000, "easy starting cash")
	_expect_equal(HARD_CONFIG.start_cash_cents, 550_000, "hard starting cash")
	_expect_equal(EASY_CONFIG.rent_small_weekly_cents, 100_000, "easy weekly rent")
	_expect_equal(HARD_CONFIG.rent_small_weekly_cents, 135_000, "hard weekly rent")
	_expect_equal(EASY_CONFIG.first_rent_due_day, 10, "easy first rent due day")
	_expect_equal(EASY_CONFIG.whale_weight_mult, 1.4, "easy whale weight")
	_expect_equal(NORMAL_CONFIG.whale_weight_mult, 1.0, "normal whale weight")
	_expect_equal(HARD_CONFIG.whale_weight_mult, 0.7, "hard whale weight")
	_expect_equal(
		EASY_CONFIG.whale_weight_mult > HARD_CONFIG.whale_weight_mult,
		true,
		"easy whale weight exceeds hard"
	)
	_expect_equal(EASY_CONFIG.demand_band_sigma, 0.09, "easy demand sigma")
	_expect_equal(NORMAL_CONFIG.demand_band_sigma, 0.12, "normal demand sigma")
	_expect_equal(HARD_CONFIG.demand_band_sigma, 0.16, "hard demand sigma")
	_expect_equal(EASY_CONFIG.seed_bulk_cards, 80, "easy seed bulk cards")
	_expect_equal(NORMAL_CONFIG.seed_bulk_cards, 80, "normal seed bulk cards")
	_expect_equal(HARD_CONFIG.seed_bulk_cards, 80, "hard seed bulk cards")


func _test_normal_shop_capacity() -> void:
	var capacity := ShopCapacity.new()
	_expect_equal(capacity.display_slots, NORMAL_CONFIG.case_slots, "normal case slots")
	_expect_equal(capacity.storage_units, NORMAL_CONFIG.backstock_bins, "normal backstock bins")


func _test_weekly_rent_schedule() -> void:
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(6), false, "no rent before weekly settle")
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(7), true, "day seven weekly settle")
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(14), true, "recurring weekly settle")
	_expect_equal(NORMAL_CONFIG.rent_small_weekly_cents, 120_000, "weekly rent amount")


func _test_customer_archetype_weights() -> void:
	var catalog := CustomerArchetypeCatalog.new()
	_expect_equal(catalog.archetypes.size(), 6, "six customer archetypes")
	var ids: Array[StringName] = []
	for archetype: Dictionary in catalog.archetypes:
		ids.append(StringName(archetype.get("id", "")))
		_expect_equal(
			float(archetype.get("weight_normal", 0.0)) > 0.0,
			true,
			"positive normal archetype weight"
		)
	for expected_id: StringName in [
		&"kid_parent", &"spike", &"collector",
		&"flipper", &"regular", &"whale",
	]:
		_expect_equal(expected_id in ids, true, "archetype %s" % expected_id)
	var whale: Dictionary = {}
	for archetype: Dictionary in catalog.archetypes:
		if StringName(archetype.get("id", "")) == &"whale":
			whale = archetype
			break
	var low_weight := catalog.weight_for(whale, 10, NORMAL_CONFIG)
	var high_weight := catalog.weight_for(whale, 80, NORMAL_CONFIG)
	_expect_equal(low_weight, 0.0, "whales gated at low reputation")
	_expect_equal(high_weight > low_weight, true, "whale high reputation bias")


func _test_customer_spawn_phase_gating() -> void:
	_expect_equal(
		CustomerSpawnPolicy.can_spawn(DayPhasePolicy.PREP),
		false,
		"no prep customer spawn"
	)
	_expect_equal(
		CustomerSpawnPolicy.can_spawn(DayPhasePolicy.FLOOR),
		true,
		"floor customer spawn"
	)
	_expect_equal(
		CustomerSpawnPolicy.can_spawn(DayPhasePolicy.SETTLE),
		false,
		"no settle customer spawn"
	)


func _test_day_phase_transitions() -> void:
	_expect_equal(
		DayPhasePolicy.can_start_floor(DayPhasePolicy.PREP),
		true,
		"prep enters floor"
	)
	_expect_equal(
		DayPhasePolicy.can_start_floor(DayPhasePolicy.FLOOR),
		false,
		"floor cannot restart floor"
	)
	_expect_equal(
		DayPhasePolicy.can_start_settle(DayPhasePolicy.FLOOR),
		true,
		"floor enters settle"
	)
	_expect_equal(
		DayPhasePolicy.can_start_settle(DayPhasePolicy.PREP),
		false,
		"prep cannot settle"
	)
	_expect_equal(
		DayPhasePolicy.can_advance_day(DayPhasePolicy.SETTLE),
		true,
		"settle advances day"
	)
	_expect_equal(
		DayPhasePolicy.can_advance_day(DayPhasePolicy.FLOOR),
		false,
		"floor cannot advance day"
	)


func _test_negotiate_clamp() -> void:
	_expect_equal(
		CustomerQueue.negotiated_price_cents(1000, -0.50),
		900,
		"negotiation lower clamp"
	)
	_expect_equal(
		CustomerQueue.negotiated_price_cents(1000, 0.50),
		1100,
		"negotiation upper clamp"
	)


func _test_customer_service_actions() -> void:
	var inventory := FakeCustomerInventory.new()
	var queue := CustomerQueue.new()
	queue.configure(inventory)
	var refused_customer := CustomerProfile.new()
	refused_customer.budget_cents = 1000
	refused_customer.interest_tags = [&"accessory"]
	_expect_equal(queue.enqueue(refused_customer), true, "enqueue listed offer")
	_expect_equal(queue.refuse(), true, "refuse customer")
	_expect_equal(inventory.sold, false, "refuse does not sell")
	var buying_customer := CustomerProfile.new()
	buying_customer.budget_cents = 1000
	buying_customer.interest_tags = [&"accessory"]
	_expect_equal(queue.enqueue(buying_customer), true, "enqueue sale customer")
	_expect_equal(queue.sell_listed(), true, "sell listed action")
	_expect_equal(inventory.sold, true, "sell action reaches inventory")
	var seller := CustomerProfile.new()
	seller.trade_intent = CustomerProfile.TradeIntent.SELLING_TO_SHOP
	seller.buylist_signal = BuyConfirmSignal.new()
	seller.buylist_signal.sku_id = &"AA-DUST-ETB"
	seller.buylist_signal.display_name = "Dustway Chronicles Explorer Box"
	seller.buylist_signal.quantity = 1
	seller.buylist_signal.unit_cost_cents = 2400
	seller.buylist_signal.lot_total_cents = 2400
	seller.buylist_signal.shown_comp_low_cents = 4200
	seller.buylist_signal.shown_comp_high_cents = 4800
	seller.buylist_signal.can_confirm = true
	_expect_equal(queue.enqueue(seller), true, "enqueue buylist seller")
	_expect_equal(queue.accept_buylist_offer(), true, "accept buylist offer")
	_expect_equal(inventory.bought, true, "buylist offer reaches inventory purchase")
	queue.free()
	inventory.free()


func _test_ui_price_labels() -> void:
	_expect_equal(
		DemandSignalPresenter.price_label(
			DemandSignalPresenter.PriceContext.CUSTOMER_BUYING_FROM_SHOP
		),
		"Your list",
		"customer sale price label"
	)
	_expect_equal(
		DemandSignalPresenter.price_label(
			DemandSignalPresenter.PriceContext.CUSTOMER_SELLING_TO_SHOP
		),
		"You offer",
		"buylist bid label"
	)
	_expect_equal(
		DemandSignalPresenter.price_label(
			DemandSignalPresenter.PriceContext.SHOP_BUYING_OPPORTUNITY
		),
		"Ask",
		"buy opportunity ask label"
	)
	var buylist_dto := BuyConfirmSignal.new()
	buylist_dto.display_name = "Seller lot"
	buylist_dto.quantity = 1
	buylist_dto.unit_cost_cents = 500
	buylist_dto.lot_total_cents = 500
	buylist_dto.confidence = &"medium"
	var seller_summary := DemandSignalPresenter.buylist_seller_summary(
		buylist_dto
	)
	_expect_equal(
		seller_summary.contains("You offer: $5.00 each"),
		true,
		"buylist seller summary uses You offer helper"
	)
	_expect_equal(
		seller_summary.contains("Your list") or seller_summary.contains("Ask"),
		false,
		"buylist seller summary excludes other price labels"
	)


func _test_ui_helpers_do_not_read_hidden_values() -> void:
	for path: String in [
		"res://scripts/ui/demand_signal_presenter.gd",
		"res://scripts/ui/hud.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_expect_equal(source.contains("true_market"), false, "%s market truth access" % path)
		_expect_equal(source.contains("p_buy"), false, "%s probability access" % path)
		_expect_equal(source.contains("cert_valid"), false, "%s certificate access" % path)
	_expect_equal(
		bool(ProjectSettings.get_setting("debug/qa_instrumentation", true)),
		false,
		"QA instrumentation defaults off"
	)


func _test_wants_label_format() -> void:
	_expect_equal(
		DemandSignalPresenter.wants_label(
			"Bastion Captain",
			&"AA-BASE-088",
			"NM"
		),
		"Bastion Captain · NM",
		"Wants uses bible name and condition"
	)
	_expect_equal(
		DemandSignalPresenter.wants_label(
			"Arcbolt Adept",
			&"AA-BASE-078",
			"NM"
		),
		"Arcbolt Adept · NM",
		"Wants Arcbolt staple format"
	)
	_expect_equal(
		DemandSignalPresenter.wants_label(
			"Empress of Updrafts",
			&"AA-SKIE-052",
			"",
			"Prism",
			10.0
		),
		"Empress of Updrafts · Prism 10",
		"Wants graded format omits .0"
	)
	_expect_equal(
		DemandSignalPresenter.wants_label(
			"Bastion Captain",
			&"AA-BASE-088",
			"NM",
			"",
			-1.0,
			2
		),
		"Bastion Captain · NM ×2",
		"Wants appends quantity when above one"
	)
	var fallback := DemandSignalPresenter.wants_label(
		"",
		&"AA-BASE-088",
		"NM"
	)
	_expect_equal(fallback, "Base 088 · NM", "missing name humanizes SKU")
	_expect_equal(
		fallback.contains("AA-") or fallback.contains("AA-BASE-"),
		false,
		"humanized fallback has no raw AA SKU"
	)
	var raw_passthrough := DemandSignalPresenter.wants_label(
		"AA-BASE-088",
		&"AA-BASE-088",
		"NM"
	)
	_expect_equal(
		raw_passthrough.contains("AA-BASE-") or raw_passthrough.contains("AA-"),
		false,
		"raw SKU display name is humanized away"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var inventory := _inventory_service.get("model") as InventoryModel
	var bastion := inventory.get_sku(&"AA-BASE-088")
	var bastion_card: CardInstance = _inventory_service.call(
		"get_card",
		&"AA-BASE-088"
	)
	var spike_wants := DemandSignalPresenter.wants_label(
		bastion.display_name,
		&"AA-BASE-088",
		CardInstance.Condition.keys()[bastion_card.condition]
	)
	_expect_equal(
		spike_wants,
		"Bastion Captain · NM",
		"CustomerServe Wants uses Bastion Captain · NM"
	)
	_expect_equal(
		spike_wants.contains("AA-BASE-"),
		false,
		"CustomerServe Wants hides raw SKU ids"
	)
	var empress := inventory.get_sku(&"AA-SKIE-052")
	_inventory_service.call(
		"receive_slab",
		&"AA-SKIE-052",
		&"Prism",
		10.0,
		empress.base_market_cents,
		InventoryLocation.new(InventoryLocation.Type.CASE)
	)
	var empress_slab: SlabInstance = _inventory_service.call(
		"get_slab",
		&"AA-SKIE-052"
	)
	_expect_equal(
		DemandSignalPresenter.wants_label(
			empress.display_name,
			&"AA-SKIE-052",
			"",
			String(empress_slab.grader),
			empress_slab.grade
		),
		"Empress of Updrafts · Prism 10",
		"CustomerServe Wants uses grader and grade"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("String(_current_customer.target_sku)"),
		false,
		"HUD Wants line does not interpolate raw SKU"
	)
	_expect_equal(
		hud_source.contains("_customer_wants_label"),
		true,
		"HUD CustomerServe uses Wants helper"
	)


func _test_prep_hud_seed_before_bind() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("is_game_active", false)
	_economy.set("balance_cents", 0)
	_game_state.set("attention_remaining", 0)
	_game_state.call("start_new_game")
	_expect_equal(
		int(_economy.get("balance_cents")),
		800_000,
		"Prep seed cash from Normal BalanceConfig"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		100,
		"Prep seed attention from Normal BalanceConfig"
	)
	_expect_equal(
		NORMAL_CONFIG.start_cash_cents,
		800_000,
		"Normal start_cash_cents unchanged"
	)
	_expect_equal(
		NORMAL_CONFIG.attention_pool,
		100,
		"Normal attention_pool unchanged"
	)
	_expect_equal(
		DemandSignalPresenter.format_cents(int(_economy.get("balance_cents"))),
		"$8000.00",
		"Prep cash formats as $8000.00"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("_bind_seeded_status"),
		true,
		"HUD binds status after seed"
	)
	_expect_equal(
		hud_source.contains("GameState.start_new_game()"),
		true,
		"HUD seeds inactive sessions before bind"
	)
	var hud_scene := FileAccess.get_file_as_string(
		"res://scenes/ui/gameplay_hud.tscn"
	)
	_expect_equal(
		hud_scene.contains("Cash  $8000.00"),
		true,
		"Prep HUD scene default is seeded cash"
	)
	_expect_equal(
		hud_scene.contains("Cash $0.00") or hud_scene.contains("Cash  $0.00"),
		false,
		"Prep HUD scene default is not $0"
	)
	_expect_equal(
		hud_scene.contains("Attention  100"),
		true,
		"Prep HUD scene default is seeded attention"
	)


func _test_undercut_fill_boundary() -> void:
	_expect_equal(
		DemandSignalPresenter.UNDERCUT_FILL_FACTOR,
		0.90,
		"Undercut fill factor is strict 0.90"
	)
	_expect_equal(
		DemandSignalPresenter.undercut_fill_cents(1000),
		900,
		"Undercut fill floors suggested * 0.90"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var preview := _demand_signals.call(
		"price_signal",
		&"AA-DUST-ETB",
		_inventory_service.call("listed_price_for", &"AA-DUST-ETB"),
		_inventory_service.call("location_for", &"AA-DUST-ETB")
	) as PriceConfirmSignal
	var undercut_cents := DemandSignalPresenter.undercut_fill_cents(
		preview.suggested_price_cents
	)
	_expect_equal(
		undercut_cents,
		maxi(1, floori(preview.suggested_price_cents * 0.90)),
		"Undercut helper matches floori(suggested * 0.90)"
	)
	var undercut_preview := _demand_signals.call(
		"refresh_price_signal",
		preview,
		undercut_cents
	) as PriceConfirmSignal
	_expect_equal(
		undercut_preview.position,
		&"undercut",
		"×0.90 fill maps to Undercut"
	)
	var competitive_cents := ceili(preview.suggested_price_cents * 0.92)
	var competitive_preview := _demand_signals.call(
		"refresh_price_signal",
		preview,
		competitive_cents
	) as PriceConfirmSignal
	_expect_equal(
		competitive_preview.position,
		&"competitive",
		"exact −8% (suggest × 0.92) maps to Competitive"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("* 0.92") or hud_source.contains("*0.92"),
		false,
		"HUD has no leftover ×0.92 Undercut fill"
	)
	_expect_equal(
		hud_source.contains("undercut_fill_cents"),
		true,
		"HUD Undercut fill uses shared 0.90 helper"
	)
	var presenter_source := FileAccess.get_file_as_string(
		"res://scripts/ui/demand_signal_presenter.gd"
	)
	_expect_equal(
		presenter_source.contains("* 0.92") or presenter_source.contains("*0.92"),
		false,
		"presenter has no leftover ×0.92 Undercut fill"
	)


func _test_spike_staple_beat() -> void:
	_game_state.call("start_new_game")
	var inventory := _inventory_service.get("model") as InventoryModel
	for card: CardInstance in inventory.cards.duplicate():
		if card.sku_id in [&"AA-BASE-088", &"AA-BASE-078"]:
			inventory.remove_card(card)
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.FLOOR)
	_captured_scripted_customer = null
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call(
			"trigger_qa_beat",
			SPIKE_STAPLE_BEAT
		),
		true,
		"Spike staple QA trigger"
	)
	_expect_equal(
		_inventory_service.call("card_count", &"AA-BASE-088"),
		1,
		"Spike beat seeds exactly one missing NM staple"
	)
	_expect_equal(
		_captured_scripted_customer != null,
		true,
		"Spike scripted customer emitted"
	)
	if _captured_scripted_customer != null:
		_expect_equal(
			_captured_scripted_customer.archetype_id,
			&"spike",
			"scripted customer archetype"
		)
		_expect_equal(
			_captured_scripted_customer.desired_skus,
			[&"AA-BASE-088"],
			"Spike targets seeded staple"
		)
	_qa_autoload.call("set_force_enabled", false)


func _test_rent_firesale_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_rent_decision = {}
	_beat_director.call("_start_day_beats", 7)
	_expect_equal(
		_beat_director.call("is_started", RENT_FIRESALE_BEAT),
		true,
		"rent fire-sale starts on Normal day seven PREP"
	)
	_expect_equal(
		StringName(_captured_rent_decision.get("beat_id", &"")),
		RENT_FIRESALE_BEAT,
		"rent decision carries beat tag"
	)
	_expect_equal(
		bool(_captured_rent_decision.get("fire_sale_enabled", false)),
		true,
		"rent decision offers sealed fire-sale"
	)
	_expect_equal(
		bool(_captured_rent_decision.get("accessory_enabled", false)),
		true,
		"rent decision offers accessory cut"
	)
	_expect_equal(
		bool(_captured_rent_decision.get("loan_enabled", false)),
		true,
		"rent decision offers Normal payday loan"
	)
	for key: Variant in _captured_rent_decision.keys():
		var field := String(key)
		_expect_equal(
			field.contains("true_market")
			or field.contains("p_buy")
			or field.contains("cert_valid"),
			false,
			"rent decision field %s does not leak truth" % field
		)

	_captured_price_sku = &""
	_captured_price_beat = &""
	_captured_price_mode = &""
	_expect_equal(
		_beat_director.call("choose_rent_path", &"fire_sale"),
		true,
		"rent fire-sale path opens pricing"
	)
	_expect_equal(
		_captured_price_sku in [&"AA-DUST-ETB", &"AA-DUST-BLST"],
		true,
		"rent fire-sale focuses owned Dustway sealed"
	)
	_expect_equal(
		_captured_price_beat,
		RENT_FIRESALE_BEAT,
		"rent price focus carries beat tag"
	)
	_expect_equal(
		_captured_price_mode,
		&"undercut",
		"rent price focus suggests Undercut"
	)
	var fire_sale_preview := _demand_signals.call(
		"price_signal",
		_captured_price_sku,
		_inventory_service.call("listed_price_for", _captured_price_sku),
		_inventory_service.call("location_for", _captured_price_sku)
	) as PriceConfirmSignal
	var undercut_cents := DemandSignalPresenter.undercut_fill_cents(
		fire_sale_preview.suggested_price_cents
	)
	fire_sale_preview = _demand_signals.call(
		"refresh_price_signal",
		fire_sale_preview,
		undercut_cents
	) as PriceConfirmSignal
	_expect_equal(
		fire_sale_preview.position,
		&"undercut",
		"rent fire-sale preview refresh shows Undercut"
	)
	_beat_director.call(
		"_on_beat_ui_resolved",
		RENT_FIRESALE_BEAT,
		&"cancelled"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 7)
	var cash_before_rent := int(_economy.get("balance_cents"))
	_expect_equal(
		_beat_director.call("choose_rent_path", &"dismissed"),
		true,
		"rent decision can explicitly dismiss"
	)
	_expect_equal(
		(_economy.call("get_ledger") as Array).is_empty(),
		true,
		"dismiss does not auto-pay rent"
	)
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_rent - NORMAL_CONFIG.rent_small_weekly_cents,
		"dismissed rent still collects at SETTLE"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_rent_decision = {}
	_beat_director.call("_start_day_beats", 7)
	_expect_equal(
		bool(_captured_rent_decision.get("loan_enabled", true)),
		false,
		"Hard rent decision hides payday loan"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains(
			"rent_loan_button.visible = bool(payload.get(\"loan_enabled\", false))"
		),
		true,
		"HUD hides unavailable loan option"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_titan_hype_price_focus() -> void:
	_beat_director.call("reset")
	var inventory := _inventory_service.get("model") as InventoryModel
	for card: CardInstance in inventory.cards.duplicate():
		if card.sku_id == &"AA-SKIE-047":
			inventory.remove_card(card)
	_game_state.set("current_day", 8)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_price_sku = &""
	_captured_price_beat = &""
	_captured_price_focus_count = 0
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call(
			"trigger_qa_beat",
			TITAN_HYPE_BEAT
		),
		true,
		"Titan hype QA trigger"
	)
	_expect_equal(
		int(_inventory_service.call("card_count", &"AA-SKIE-047")) >= 1,
		true,
		"Titan hype ensures NM inventory"
	)
	var titan_signal := _demand_signals.call(
		"price_signal",
		&"AA-SKIE-047",
		2200,
		_inventory_service.call("location_for", &"AA-SKIE-047")
	) as PriceConfirmSignal
	_expect_equal(
		titan_signal.shown_demand_band,
		&"hot",
		"Titan hype shows HOT noisy demand band"
	)
	_expect_equal(
		titan_signal.suggested_price_cents > 2200,
		true,
		"Titan hype elevates noisy suggested comp"
	)
	_expect_equal(_captured_price_sku, &"AA-SKIE-047", "Titan price focus SKU")
	_expect_equal(
		_captured_price_beat,
		TITAN_HYPE_BEAT,
		"Titan price focus beat tag"
	)
	_expect_equal(_captured_price_focus_count, 1, "Titan initial PREP focus")
	var market_state := _demand_signals.get("_market_state") as MarketState
	var market_before_refocus := market_state.market_cents_for(&"AA-SKIE-047")
	var listed_before_refocus := int(
		_inventory_service.call("listed_price_for", &"AA-SKIE-047")
	)
	_game_state.set("current_phase", DayPhasePolicy.FLOOR)
	_beat_director.call("_refocus_titan_after_phase_change", 8)
	_expect_equal(
		_captured_price_focus_count,
		2,
		"Titan refocuses after PREP to FLOOR UI settles"
	)
	_expect_equal(
		market_state.market_cents_for(&"AA-SKIE-047"),
		market_before_refocus,
		"Titan refocus does not multiply market cents"
	)
	_expect_equal(
		int(_inventory_service.call("listed_price_for", &"AA-SKIE-047")),
		listed_before_refocus,
		"Titan refocus does not mutate listed cents"
	)
	_expect_equal(
		_beat_director.call("is_completed", TITAN_HYPE_BEAT),
		false,
		"Titan remains pending for Apply or Cancel on FLOOR"
	)
	_beat_director.call(
		"_on_beat_ui_resolved",
		TITAN_HYPE_BEAT,
		&"cancelled"
	)
	_expect_equal(
		_beat_director.call(
			"is_completed",
			TITAN_HYPE_BEAT
		),
		true,
		"Titan cancel resolves restored FLOOR editor"
	)
	_beat_director.call("reset")
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", TITAN_HYPE_BEAT),
		true,
		"Titan can start again in isolated lifecycle"
	)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_beat_director.call("_on_day_phase_changed", DayPhasePolicy.SETTLE)
	_expect_equal(
		_beat_director.call("is_completed", TITAN_HYPE_BEAT),
		true,
		"ignored Titan completes at SETTLE instead of staying stuck"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_showcase_slab_and_singles_preconditions() -> void:
	_beat_director.call("reset")
	var inventory := _inventory_service.get("model") as InventoryModel
	for card: CardInstance in inventory.cards.duplicate():
		if card.sku_id in [&"AA-SKIE-047", &"AA-SKIE-058"]:
			inventory.remove_card(card)
	for slab: SlabInstance in inventory.slabs.duplicate():
		inventory.remove_slab(slab)
	_game_state.set("current_day", 10)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call(
			"trigger_qa_beat",
			SHOWCASE_BEAT
		),
		true,
		"showcase QA trigger"
	)
	var empress_slab := (
		_inventory_service.call("get_slab", &"AA-SKIE-052") as SlabInstance
	)
	var titan := (
		_inventory_service.call("get_card", &"AA-SKIE-047") as CardInstance
	)
	var paragon := (
		_inventory_service.call("get_card", &"AA-SKIE-058") as CardInstance
	)
	_expect_equal(empress_slab != null, true, "showcase ensures Empress slab")
	_expect_equal(titan != null, true, "showcase ensures Titan single")
	_expect_equal(paragon != null, true, "showcase ensures Paragon single")
	_expect_equal(
		int(_inventory_service.call("case_free_slot_weight")) >= 2,
		true,
		"showcase starts with two free slot-weights"
	)
	_expect_equal(
		_beat_director.call("choose_showcase", &"slab"),
		true,
		"choose slab"
	)
	_expect_equal(
		empress_slab.location.type,
		InventoryLocation.Type.CASE,
		"slab moves through case API"
	)
	_expect_equal(
		_beat_director.call("choose_showcase", &"singles"),
		true,
		"switch to singles"
	)
	_expect_equal(
		empress_slab.location.type,
		InventoryLocation.Type.ONLINE_HOLD,
		"singles choice removes slab from case"
	)
	_expect_equal(titan.location.type, InventoryLocation.Type.CASE, "Titan in case")
	_expect_equal(paragon.location.type, InventoryLocation.Type.CASE, "Paragon in case")
	_qa_autoload.call("set_force_enabled", false)


func _test_shop_camera_framing() -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "shop_floor scene loads")
	if packed == null:
		return
	var shop: Node = packed.instantiate()
	var camera := shop.get_node_or_null("Camera") as Camera3D
	_expect_equal(camera != null, true, "Camera present")
	if camera == null:
		shop.free()
		return
	_expect_equal(camera.current, true, "Camera is current")
	_expect_equal(
		camera.position.is_equal_approx(Vector3(4.5, 1.65, -1.8)),
		true,
		"Art Lead camera position"
	)
	_expect_equal(
		camera.rotation_degrees.is_equal_approx(Vector3(-28, 0, 0)),
		true,
		"Art Lead camera pitch"
	)
	_expect_equal(is_equal_approx(camera.fov, 70.0), true, "Art Lead camera FOV")
	var world := shop.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_expect_equal(world != null, true, "WorldEnvironment present")
	if world != null and world.environment != null:
		_expect_equal(
			world.environment.ambient_light_source,
			Environment.AMBIENT_SOURCE_COLOR,
			"interior ambient uses color fill"
		)
	var omni_count := 0
	var lights_root := shop.get_node_or_null("Fixtures/OverheadLights")
	if lights_root != null:
		for child: Node in lights_root.get_children():
			if child is OmniLight3D:
				omni_count += 1
	_expect_equal(omni_count, 4, "overhead omni fills")
	shop.free()


func _test_day_ten_beat_serialization() -> void:
	_beat_director.call("reset")
	_game_state.set("current_day", 10)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", TITAN_HYPE_BEAT),
		true,
		"day-ten Titan trigger"
	)
	_beat_director.call("_start_day_beats", 10)
	_expect_equal(
		_beat_director.call("is_started", SHOWCASE_BEAT),
		false,
		"showcase waits while Titan editor is unresolved"
	)
	_beat_director.call(
		"_on_beat_ui_resolved",
		TITAN_HYPE_BEAT,
		&"cancelled"
	)
	_qa_autoload.call("set_force_enabled", false)


func _capture_scripted_customer(customer: CustomerProfile) -> void:
	_captured_scripted_customer = customer


func _capture_price_focus(
	sku_id: StringName,
	beat_id: StringName,
	_message: String,
	suggestion_mode: StringName
) -> void:
	_captured_price_sku = sku_id
	_captured_price_beat = beat_id
	_captured_price_mode = suggestion_mode
	_captured_price_focus_count += 1


func _capture_rent_decision(payload: Dictionary) -> void:
	_captured_rent_decision = payload


func _expect_dto_has_no_truth_fields(dto: Resource, label: String) -> void:
	for property: Dictionary in dto.get_property_list():
		var property_name := String(property["name"])
		var leaks_truth := (
			property_name.contains("true_market")
			or property_name.contains("p_buy")
			or property_name.contains("cert_valid")
		)
		_expect_equal(leaks_truth, false, "%s field %s" % [label, property_name])


func _band_index(band: StringName) -> int:
	return [&"cold", &"steady", &"warm", &"hot"].find(band)


func _expect_payload_keys(
	event: Dictionary,
	expected_keys: Array[StringName],
	label: String
) -> void:
	var payload: Dictionary = event["payload"]
	for key: StringName in expected_keys:
		_expect_equal(payload.has(String(key)), true, "%s key %s" % [label, key])


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		return
	_failures += 1
	push_error("%s: expected %s, got %s" % [label, expected, actual])
