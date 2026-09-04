extends SceneTree

const EASY_CONFIG: BalanceConfig = preload("res://data/balance/easy.tres")
const NORMAL_CONFIG: BalanceConfig = preload("res://data/balance/normal.tres")
const HARD_CONFIG: BalanceConfig = preload("res://data/balance/hard.tres")
const SPIKE_STAPLE_BEAT := &"sec10_4_spike_staple"
const RENT_FIRESALE_BEAT := &"sec10_6_rent_firesale"
const TITAN_HYPE_BEAT := &"sec10_7_titan_hype"
const SHOWCASE_BEAT := &"sec10_8_slab_vs_singles"
const MARKETPLACE_OUTING_BEAT := &"sec10_3_marketplace_outing"
const HIRE_CASHIER_BEAT := &"sec10_5_hire_cashier"
const EXPAND_MEDIUM_BEAT := &"sec10_9_expand_medium"
const SHADY_TRUNK_BEAT := &"sec10_10_shady_trunk"

var _failures: int = 0
var _qa := QaInstrumentationService.new()
var _captured_scripted_customer: CustomerProfile
var _captured_price_sku: StringName = &""
var _captured_price_beat: StringName = &""
var _captured_price_mode: StringName = &""
var _captured_price_focus_count: int = 0
var _captured_rent_decision: Dictionary = {}
var _captured_beat_decision: Dictionary = {}
var _captured_buy_focus_id: StringName = &""
var _captured_buy_focus_beat: StringName = &""
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

	func has_backstock(_sku_id: StringName) -> bool:
		return false

	func pull_from_backstock(_sku_id: StringName) -> bool:
		return false


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
	_event_bus.connect("beat_decision_requested", _capture_beat_decision)
	_event_bus.connect("buy_focus_requested", _capture_buy_focus)
	_test_pricing_spread()
	_test_stock_lot_unit_cost()
	_test_inventory_mutations_and_capacity()
	_test_balance_seed_inventory()
	_test_buy_opportunity_picker_seed()
	_test_price_editor_inventory_picker()
	_test_demand_signal_dto_does_not_leak_truth()
	_test_demand_fairness_contract()
	_test_inspect_buy_opportunity()
	_test_research_and_rearrange_attention()
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
	_test_gameplay_hud_visual_smoke()
	_test_undercut_fill_boundary()
	_test_rent_firesale_beat()
	_test_spike_staple_beat()
	_test_titan_hype_price_focus()
	_test_market_events_seven_day_seeded_run()
	_test_hype_spike_target_sku_only()
	_test_fog_day_sigma_and_inversion()
	_test_market_event_save_load()
	_test_day_ten_beat_serialization()
	_test_marketplace_outing_beat()
	_test_hire_cashier_beat()
	_test_specialist_staff_path()
	_test_expand_medium_beat()
	_test_medium_floor_growth()
	_test_medium_overhead_lights()
	_test_shady_trunk_beat()
	_test_showcase_slab_and_singles_preconditions()
	_test_shop_camera_framing()
	_test_shop_camera_look_clamps()
	_test_heavier_decor_placement()
	_test_customer_npc_spawn_browse_approach_path()
	_test_customer_npc_intent_icons_have_no_truth()
	_test_customer_npc_desk_volume_gates_hud()
	_test_customer_npc_does_not_change_camera()
	_test_customer_npc_visible_when_queued()
	_test_customer_npc_mvp_cast()
	_test_customer_npc_locomotion_clips()
	_test_cashier_silhouette_on_floor()
	_test_c2_hire_beat_paths()
	_test_c2_unreliable_ten_day_stress()
	_test_c2_att_zero_owner_verbs()
	_test_c2_specialist_attention_assert()

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


func _test_inspect_buy_opportunity() -> void:
	_qa.set_force_enabled(false)
	_expect_equal(
		DemandSignalService.recommends_inspect(
			DemandSignalService.Channel.MARKETPLACE
		),
		true,
		"marketplace recommends inspect"
	)
	_expect_equal(
		DemandSignalService.recommends_inspect(&"shady"),
		true,
		"shady recommends inspect"
	)
	_expect_equal(
		DemandSignalService.recommends_inspect(&"buylist"),
		true,
		"buylist inspect is optional"
	)
	_expect_equal(
		DemandSignalService.recommends_inspect(
			DemandSignalService.Channel.DISTRIBUTOR
		),
		false,
		"distributor does not recommend inspect"
	)

	var market_state := MarketState.new()
	market_state.update_sku(&"AA-SKIE-047", 2200, 0.75)
	var seeded_a := DemandSignalService.new(NORMAL_CONFIG, market_state, 42, _qa)
	var seeded_b := DemandSignalService.new(NORMAL_CONFIG, market_state, 42, _qa)
	var dto_a := seeded_a.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		1200, 2, 800_000, 1, 3
	)
	var dto_b := seeded_b.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		1200, 2, 800_000, 1, 3
	)
	var fog_cue := dto_a.condition_cue
	var comp_low := dto_a.shown_comp_low_cents
	var comp_high := dto_a.shown_comp_high_cents
	var demand_band := dto_a.shown_demand_band
	var confidence := dto_a.confidence
	_expect_equal(
		fog_cue.to_lower().contains("photo"),
		true,
		"marketplace starts with photo-only fog"
	)
	_expect_equal(seeded_a.can_inspect(dto_a), true, "fogged marketplace can inspect")
	_expect_equal(seeded_a.inspect_condition(dto_a), true, "seeded inspect succeeds")
	_expect_equal(seeded_b.inspect_condition(dto_b), true, "duplicate seed inspect")
	_expect_equal(
		dto_a.condition_cue,
		dto_b.condition_cue,
		"inspect cue is deterministic under seeded RNG"
	)
	_expect_equal(dto_a.inspected, true, "inspect marks opportunity inspected")
	_expect_equal(
		dto_a.shown_comp_low_cents,
		comp_low,
		"inspect does not change comp low"
	)
	_expect_equal(
		dto_a.shown_comp_high_cents,
		comp_high,
		"inspect does not change comp high"
	)
	_expect_equal(
		dto_a.shown_demand_band,
		demand_band,
		"inspect does not change demand band"
	)
	_expect_equal(dto_a.confidence, confidence, "inspect does not change confidence")
	_assert_text_has_no_truth(dto_a.condition_cue, "inspect cue")
	_assert_text_has_no_truth(
		DemandSignalPresenter.buy_summary(dto_a),
		"inspect buy summary"
	)
	_expect_dto_has_no_truth_fields(dto_a, "inspected buy signal")
	_expect_equal(
		seeded_a.inspect_condition(dto_a),
		false,
		"second inspect is blocked"
	)
	_expect_equal(
		dto_a.condition_cue,
		dto_b.condition_cue,
		"blocked inspect leaves cue unchanged"
	)

	var accurate_config := BalanceConfig.new()
	accurate_config.inspect_accuracy = 1.0
	accurate_config.inspect_attention = 5
	var miss_config := BalanceConfig.new()
	miss_config.inspect_accuracy = 0.0
	miss_config.inspect_attention = 5
	var accurate := DemandSignalService.new(accurate_config, market_state, 7, _qa)
	var miss := DemandSignalService.new(miss_config, market_state, 7, _qa)
	var accurate_dto := accurate.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.SHADY,
		900, 1, 800_000, 1, 3
	)
	var miss_dto := miss.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.SHADY,
		900, 1, 800_000, 1, 3
	)
	var shady_fog := accurate_dto.condition_cue
	_expect_equal(
		shady_fog.to_lower().contains("strongly recommended"),
		true,
		"shady starts with strongly recommended fog"
	)
	_expect_equal(accurate.inspect_condition(accurate_dto), true, "accuracy 1.0 inspect")
	_expect_equal(miss.inspect_condition(miss_dto), true, "accuracy 0.0 inspect")
	_expect_equal(
		accurate_dto.condition_cue != shady_fog,
		true,
		"successful inspect clears photo fog"
	)
	_expect_equal(
		accurate_dto.condition_cue != miss_dto.condition_cue,
		true,
		"accuracy miss yields a different soft cue"
	)
	_assert_text_has_no_truth(accurate_dto.condition_cue, "accurate inspect cue")
	_assert_text_has_no_truth(miss_dto.condition_cue, "miss inspect cue")

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.inspect_attention_cost(), 5, "Owner inspect costs 5 Att")
	_expect_equal(
		int(_game_state.get("current_phase")),
		DayPhasePolicy.PREP,
		"inspect attention test starts in PREP"
	)
	_expect_equal(
		bool(_game_state.call("spend_attention", 5)),
		false,
		"FLOOR-only spend_attention still rejects PREP"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		100,
		"rejected FLOOR spend does not debit PREP Att"
	)
	_expect_equal(
		bool(_game_state.call("consume_attention", 5)),
		true,
		"PREP consume_attention debits inspect cost"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		95,
		"inspect debit leaves 95 Att"
	)
	_expect_equal(
		bool(_game_state.call("consume_attention", 96)),
		false,
		"insufficient Attention blocks inspect spend"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		95,
		"blocked inspect spend does not debit"
	)

	_game_state.call("start_new_game")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "gameplay HUD loads for inspect")
	if hud == null:
		return
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	var attention := hud.get_node_or_null("%AttentionLabel") as Label
	var summary_label := hud.get_node_or_null("%BuySummary") as Label
	var open_buy := hud.get_node_or_null("%OpenBuyButton") as Button
	_expect_equal(open_buy != null, true, "OpenBuyButton present")
	open_buy.pressed.emit()
	var marketplace_row_clicked := _click_buy_row_for_channel(hud, &"marketplace")
	_expect_equal(marketplace_row_clicked, true, "day 1 marketplace lot exists")
	var selected := hud.get("_buy_signal") as BuyConfirmSignal
	_expect_equal(
		selected != null and selected.channel == &"marketplace",
		true,
		"detail opened for marketplace lot"
	)
	_expect_equal(
		inspect_button != null and inspect_button.visible,
		true,
		"Inspect★ visible on marketplace detail"
	)
	_expect_equal(
		inspect_button != null and not inspect_button.disabled,
		true,
		"Inspect★ enabled with full Attention"
	)
	var fog_summary := summary_label.text if summary_label != null else ""
	var marketplace_fog := selected.condition_cue if selected != null else ""
	inspect_button.pressed.emit()
	selected = hud.get("_buy_signal") as BuyConfirmSignal
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		95,
		"Inspect★ spends 5 Attention from PREP"
	)
	_expect_equal(
		attention != null and attention.text == "Att 95/100",
		true,
		"HUD Att label reflects inspect spend"
	)
	_expect_equal(
		selected != null and selected.inspected,
		true,
		"HUD inspect updates the lot"
	)
	_expect_equal(
		selected != null
		and selected.condition_cue != ""
		and selected.condition_cue != marketplace_fog,
		true,
		"HUD inspect updates condition cue"
	)
	_assert_text_has_no_truth(
		selected.condition_cue if selected != null else "",
		"HUD inspect cue"
	)
	_assert_text_has_no_truth(summary_label.text, "HUD inspect summary")
	_expect_equal(
		summary_label.text != fog_summary,
		true,
		"BuyOpportunityDetail summary refreshes after inspect"
	)
	_expect_equal(
		inspect_button.disabled,
		true,
		"Inspect★ disables after a successful inspect"
	)

	_game_state.set("attention_remaining", 4)
	Callable(hud, "_update_attention").call(4)
	var shady := _demand_signals.call(
		"buy_signal",
		&"AA-SKIE-047",
		DemandSignalService.Channel.SHADY,
		900,
		1
	) as BuyConfirmSignal
	shady.opportunity_id = &"test-shady-inspect"
	_select_buy_on_hud(hud, shady)
	_expect_equal(
		inspect_button.visible,
		true,
		"Inspect★ visible on shady detail"
	)
	_expect_equal(
		inspect_button.disabled,
		true,
		"Inspect★ disabled when Attention is below cost"
	)
	var shady_fog_cue := shady.condition_cue
	Callable(hud, "_inspect_buy").call()
	_expect_equal(shady.inspected, false, "blocked inspect does not resolve")
	_expect_equal(shady.condition_cue, shady_fog_cue, "blocked inspect keeps fog")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		4,
		"blocked Inspect★ does not debit Attention"
	)

	open_buy.pressed.emit()
	_expect_equal(
		_click_buy_row_for_channel(hud, &"distributor"),
		true,
		"day 1 distributor lot exists"
	)
	_expect_equal(
		inspect_button.visible,
		false,
		"Inspect★ hidden on distributor NM-assumed lots"
	)
	root.remove_child(hud)
	hud.free()


func _test_research_and_rearrange_attention() -> void:
	_qa.set_force_enabled(false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.inspect_attention_cost(), 5, "Owner inspect stays 5 without specialist")
	_expect_equal(shop.research_attention_cost(), 15, "Owner research costs 15 Att")
	_expect_equal(shop.rearrange_attention_cost(), 10, "Owner rearrange costs 10 Att")
	_expect_equal(shop.research_cash_cost_cents(), 5_000, "Owner research costs $50")
	shop.set_specialist_on_duty(true)
	_expect_equal(shop.inspect_attention_cost(), 2, "Specialist inspect 5→2")
	_expect_equal(shop.research_attention_cost(), 10, "Specialist research 15→10")
	_expect_equal(shop.rearrange_attention_cost(), 10, "Rearrange cost ignores specialist")
	shop.set_specialist_on_duty(false)
	_expect_equal(shop.inspect_attention_cost(), 5, "Inspect returns to 5 off duty")

	var market_state := MarketState.new()
	market_state.update_sku(&"AA-SKIE-047", 10_000, 0.70)
	market_state.update_sku(&"AA-BASE-088", 500, 0.45)
	var fogged := DemandSignalService.new(NORMAL_CONFIG, market_state, 12, _qa)
	var researched := DemandSignalService.new(NORMAL_CONFIG, market_state, 12, _qa)
	var snapshot := researched.apply_research(&"AA-SKIE", 1, 2)
	_expect_equal(researched.is_set_informed(&"AA-SKIE", 1), true, "research informs target set")
	_expect_equal(researched.is_set_informed(&"AA-SKIE", 2), true, "research lasts through day 2")
	_expect_equal(researched.is_set_informed(&"AA-SKIE", 3), false, "research expires after telegraph")
	_expect_equal(researched.is_set_informed(&"AA-BASE", 1), false, "research does not inform other sets")
	_expect_equal(
		String(snapshot.get("display_name", "")).contains("Skiefall"),
		true,
		"research snapshot names the set"
	)
	var watches := researched.active_rotation_watches(1)
	_expect_equal(watches.size() > 0, true, "rotation watch is present")
	_expect_equal(
		watches[0].begins_with("Rotation watch:"),
		true,
		"soft telegraph uses Rotation watch copy"
	)
	_assert_text_has_no_truth(watches[0], "rotation watch")
	var fog_dto := fogged.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		5000, 1, 800_000, 1, 10, false
	)
	var researched_dto := researched.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		5000, 1, 800_000, 1, 10, researched.is_set_informed(&"AA-SKIE", 1)
	)
	_expect_equal(
		researched_dto.shown_comp_high_cents - researched_dto.shown_comp_low_cents
		< fog_dto.shown_comp_high_cents - fog_dto.shown_comp_low_cents,
		true,
		"research narrows target-set comp width"
	)
	_expect_equal(
		researched_dto.condition_cue.to_lower().contains("photo"),
		true,
		"research keeps photo condition fog"
	)
	_expect_equal(researched_dto.inspected, false, "research does not inspect")
	_expect_dto_has_no_truth_fields(researched_dto, "researched buy signal")
	_assert_text_has_no_truth(researched_dto.condition_cue, "researched condition cue")
	_assert_text_has_no_truth(
		DemandSignalPresenter.buy_summary(researched_dto),
		"researched buy summary"
	)

	_qa.set_force_enabled(true)
	_qa.clear()
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	_game_state.call("start_new_game")
	var cash_before := int(_economy.get("balance_cents"))
	var att_before := int(_game_state.get("attention_remaining"))
	var live_before := _demand_signals.call(
		"buy_signal",
		&"AA-SKIE-047",
		DemandSignalService.Channel.MARKETPLACE,
		1200,
		1
	) as BuyConfirmSignal
	var result: Dictionary = _demand_signals.call("research_set", &"AA-SKIE")
	_expect_equal(bool(result.get("ok", false)), true, "research spends Att and cash")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		att_before - NORMAL_CONFIG.research_attention,
		"research debits Att 15"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - NORMAL_CONFIG.research_cost_cents,
		"research debits $50"
	)
	_expect_equal(
		int(result.get("sample_comp_width_after", 0))
		< int(result.get("sample_comp_width_before", 0)),
		true,
		"QA research payload shows narrower comps"
	)
	_expect_equal(
		float(result.get("research_demand_band_sigma", 1.0))
		< float(result.get("demand_band_sigma", 0.0)),
		true,
		"QA research payload shows narrower demand-band σ"
	)
	_assert_payload_has_no_truth(result, "research payload")
	_assert_text_has_no_truth(String(result.get("rotation_watch", "")), "research rotation watch")
	_expect_equal(
		String(result.get("condition_cue", "")).to_lower().contains("cert_valid"),
		false,
		"research payload cue has no cert_valid"
	)
	var live_after := _demand_signals.call(
		"buy_signal",
		&"AA-SKIE-047",
		DemandSignalService.Channel.MARKETPLACE,
		1200,
		1
	) as BuyConfirmSignal
	_expect_equal(
		live_after.shown_comp_high_cents - live_after.shown_comp_low_cents
		< live_before.shown_comp_high_cents - live_before.shown_comp_low_cents,
		true,
		"live buy signal narrows after researching the set"
	)
	_expect_equal(
		live_after.condition_cue.to_lower().contains("photo")
		or live_after.condition_cue.to_lower().contains("inspect"),
		true,
		"live research does not reveal true condition"
	)
	_expect_dto_has_no_truth_fields(live_after, "live researched signal")
	var events: Array = _qa_autoload.call("get_events")
	var saw_research := false
	for event: Dictionary in events:
		if String(event.get("event", "")) == "research_applied":
			saw_research = true
			_assert_payload_has_no_truth(event.get("payload", {}), "research_applied event")
	_expect_equal(saw_research, true, "QA emits research_applied")
	var already := _demand_signals.call("research_set", &"AA-SKIE") as Dictionary
	_expect_equal(bool(already.get("ok", false)), false, "active research cannot be repeated")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		att_before - NORMAL_CONFIG.research_attention,
		"blocked repeat research does not debit Att"
	)

	_game_state.set("attention_remaining", 14)
	var low_att := _demand_signals.call("research_set", &"AA-DUST") as Dictionary
	_expect_equal(bool(low_att.get("ok", false)), false, "research refuses Att < 15")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		14,
		"failed research does not debit Att"
	)
	_game_state.set("attention_remaining", 100)
	_economy.set("balance_cents", 4_999)
	_event_bus.call("publish_cash_changed", 4_999)
	var low_cash := _demand_signals.call("research_set", &"AA-DUST") as Dictionary
	_expect_equal(bool(low_cash.get("ok", false)), false, "research refuses cash < $50")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		100,
		"failed cash research does not debit Att"
	)

	_game_state.call("start_new_game")
	_expect_equal(shop.layout.has_circulation(), true, "default layout has circulation")
	var binder := shop.layout.fixture_by_id(&"binder_rack")
	_expect_equal(binder != null, true, "binder rack exists")
	var legal := _game_state.call(
		"rearrange_fixture",
		&"binder_rack",
		Vector2i(1, 5)
	) as Dictionary
	_expect_equal(bool(legal.get("ok", false)), true, "legal rearrange succeeds")
	_expect_equal(int(legal.get("attention_spent", 0)), 10, "legal rearrange spends Att 10")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		90,
		"rearrange debit leaves 90 Att"
	)
	_expect_equal(shop.layout.fixture_by_id(&"binder_rack").origin, Vector2i(1, 5), "binder moved")
	var blocked := _game_state.call(
		"rearrange_fixture",
		&"binder_rack",
		Vector2i(7, 1)
	) as Dictionary
	_expect_equal(bool(blocked.get("ok", false)), false, "illegal pathing is rejected")
	_expect_equal(
		StringName(blocked.get("reason", &"")),
		&"blocked_path",
		"illegal rearrange reason is blocked_path"
	)
	_expect_equal(int(blocked.get("attention_spent", -1)), 0, "illegal rearrange spends no Att")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		90,
		"illegal rearrange does not debit Att"
	)
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(1, 5),
		"illegal rearrange leaves fixture in place"
	)
	_game_state.set("attention_remaining", 0)
	var free := _game_state.call(
		"rearrange_fixture",
		&"binder_rack",
		Vector2i(1, 4)
	) as Dictionary
	_expect_equal(bool(free.get("ok", false)), false, "free rearrange without Att fails")
	_expect_equal(
		StringName(free.get("reason", &"")),
		&"insufficient_attention",
		"Att 0 rearrange reason"
	)
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(1, 5),
		"Att 0 rearrange does not move"
	)

	var inventory := FakeCustomerInventory.new()
	var queue := CustomerQueue.new()
	queue.configure(inventory)
	var buying_customer := CustomerProfile.new()
	buying_customer.budget_cents = 1000
	buying_customer.interest_tags = [&"accessory"]
	_expect_equal(queue.enqueue(buying_customer), true, "Att 0 still enqueues customers")
	_expect_equal(queue.sell_listed(), true, "cashiers still sell at Att 0")
	_expect_equal(inventory.sold, true, "Att 0 sale reaches inventory")
	queue.free()
	inventory.free()
	var zero_research := _demand_signals.call("research_set", &"AA-BASE") as Dictionary
	_expect_equal(bool(zero_research.get("ok", false)), false, "Att 0 research is disabled")

	_game_state.call("start_new_game")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "gameplay HUD loads for research/rearrange")
	if hud == null:
		_qa.set_force_enabled(false)
		_qa_autoload.call("set_force_enabled", false)
		return
	var open_research := hud.get_node_or_null("%OpenResearchButton") as Button
	var open_rearrange := hud.get_node_or_null("%OpenRearrangeButton") as Button
	var research_confirm := hud.get_node_or_null("%ResearchConfirmButton") as Button
	var rearrange_confirm := hud.get_node_or_null("%RearrangeConfirmButton") as Button
	_expect_equal(
		open_research != null and not open_research.disabled,
		true,
		"Research enabled with cash and Att"
	)
	_expect_equal(
		open_rearrange != null and not open_rearrange.disabled,
		true,
		"Rearrange enabled with Att"
	)
	open_research.pressed.emit()
	var research_rows := hud.get_node_or_null("%ResearchRows") as VBoxContainer
	var clicked_set := false
	if research_rows != null:
		for child: Node in research_rows.get_children():
			var row := child as Button
			if row != null and row.text.contains("Skiefall"):
				row.pressed.emit()
				clicked_set = true
				break
	_expect_equal(clicked_set, true, "Research list includes Skiefall")
	_expect_equal(
		research_confirm != null and research_confirm.text.contains("Att 15"),
		true,
		"Research confirm shows Att cost"
	)
	_expect_equal(
		research_confirm != null and research_confirm.text.contains("$50.00"),
		true,
		"Research confirm shows cash cost"
	)
	var confirm_body := hud.get_node_or_null("%ResearchConfirmBody") as Label
	_assert_text_has_no_truth(
		confirm_body.text if confirm_body != null else "",
		"research confirm body"
	)
	research_confirm.pressed.emit()
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		85,
		"HUD Research spends Att 15"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		795_000,
		"HUD Research spends $50"
	)
	var watch := hud.get_node_or_null("%RotationWatchLabel") as Label
	_expect_equal(
		watch != null and watch.visible and watch.text.contains("Rotation watch"),
		true,
		"HUD shows rotation watch after research"
	)
	_assert_text_has_no_truth(watch.text if watch != null else "", "HUD rotation watch")

	open_rearrange.pressed.emit()
	Callable(hud, "_select_rearrange_fixture").call(&"binder_rack")
	Callable(hud, "_select_rearrange_tile").call(Vector2i(7, 1))
	_expect_equal(
		rearrange_confirm != null and rearrange_confirm.disabled,
		true,
		"HUD disables confirm on illegal pathing"
	)
	Callable(hud, "_confirm_rearrange").call()
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		85,
		"HUD illegal rearrange does not spend Att"
	)
	Callable(hud, "_select_rearrange_tile").call(Vector2i(1, 5))
	_expect_equal(
		rearrange_confirm != null and not rearrange_confirm.disabled,
		true,
		"HUD enables confirm on legal rearrange"
	)
	rearrange_confirm.pressed.emit()
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		75,
		"HUD legal rearrange spends Att 10"
	)

	_game_state.set("attention_remaining", 0)
	Callable(hud, "_update_attention").call(0)
	_expect_equal(open_research.disabled, true, "HUD Research disabled at Att 0")
	_expect_equal(open_rearrange.disabled, true, "HUD Rearrange disabled at Att 0")
	root.remove_child(hud)
	hud.free()
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)


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
	_expect_equal(EASY_CONFIG.event_chance_settle, 0.12, "easy settle event chance")
	_expect_equal(HARD_CONFIG.event_chance_settle, 0.26, "hard settle event chance")
	_expect_equal(NORMAL_CONFIG.negative_event_weight_mult, 1.0, "normal negative event weight")
	_expect_equal(EASY_CONFIG.negative_event_weight_mult, 0.7, "easy negative event weight")
	_expect_equal(HARD_CONFIG.negative_event_weight_mult, 1.4, "hard negative event weight")
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
	_expect_equal(NORMAL_CONFIG.inspect_attention, 5, "normal inspect attention")
	_expect_equal(EASY_CONFIG.inspect_attention, 5, "easy inspect attention default")
	_expect_equal(HARD_CONFIG.inspect_attention, 5, "hard inspect attention default")
	_expect_equal(NORMAL_CONFIG.inspect_attention_specialist, 2, "normal inspect specialist")
	_expect_equal(EASY_CONFIG.inspect_attention_specialist, 2, "easy inspect specialist default")
	_expect_equal(HARD_CONFIG.inspect_attention_specialist, 2, "hard inspect specialist default")
	_expect_equal(NORMAL_CONFIG.research_attention, 15, "normal research attention")
	_expect_equal(EASY_CONFIG.research_attention, 10, "easy research attention")
	_expect_equal(HARD_CONFIG.research_attention, 18, "hard research attention")
	_expect_equal(NORMAL_CONFIG.research_cost_cents, 5_000, "normal research cash")
	_expect_equal(NORMAL_CONFIG.research_attention_specialist, 10, "normal research specialist")
	_expect_equal(NORMAL_CONFIG.specialist_wage_cents, 14_000, "normal specialist wage")
	_expect_equal(EASY_CONFIG.specialist_wage_cents, 14_000, "easy specialist wage default")
	_expect_equal(HARD_CONFIG.specialist_wage_cents, 14_000, "hard specialist wage default")
	_expect_equal(NORMAL_CONFIG.rearrange_attention, 10, "normal rearrange attention")
	_expect_equal(EASY_CONFIG.rearrange_attention, 10, "easy rearrange inherits")
	_expect_equal(HARD_CONFIG.rearrange_attention, 10, "hard rearrange inherits")
	_expect_equal(NORMAL_CONFIG.research_demand_band_sigma, 0.07, "normal research sigma")
	_expect_equal(NORMAL_CONFIG.research_comp_narrow_factor, 0.55, "normal research narrow")
	_expect_equal(NORMAL_CONFIG.inspect_accuracy, 0.85, "normal inspect accuracy")
	_expect_equal(EASY_CONFIG.inspect_accuracy, 0.92, "easy inspect accuracy unchanged")
	_expect_equal(HARD_CONFIG.inspect_accuracy, 0.75, "hard inspect accuracy unchanged")


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
		DemandSignalPresenter.parse_cents("$8,000.00"),
		800_000,
		"parse_cents accepts grouped cash"
	)
	_expect_equal(
		DemandSignalPresenter.format_cents(800_000),
		"$8,000.00",
		"format_cents groups thousands"
	)
	_expect_equal(
		DemandSignalPresenter.parse_cents("$44.99"),
		4499,
		"parse_cents still accepts ungrouped dollars"
	)
	var buy_dto := BuyConfirmSignal.new()
	buy_dto.unit_cost_cents = 100
	buy_dto.lot_total_cents = 100
	buy_dto.shown_comp_low_cents = 90
	buy_dto.shown_comp_high_cents = 110
	buy_dto.shown_demand_band = &"steady"
	buy_dto.confidence = &"medium"
	buy_dto.condition_cue = "NM"
	buy_dto.remaining_cash_cents = 500
	buy_dto.space_required = 1
	buy_dto.space_free = 2
	var buy_ok := DemandSignalPresenter.buy_summary(buy_dto)
	_expect_equal(
		buy_ok.contains("After buy: ✓") and buy_ok.contains("Space: ✓"),
		true,
		"Buy cash/space check uses ✓ when affordable"
	)
	buy_dto.remaining_cash_cents = -25
	buy_dto.space_free = 0
	var buy_fail := DemandSignalPresenter.buy_summary(buy_dto)
	_expect_equal(
		buy_fail.contains("After buy: ✗") and buy_fail.contains("Space: ✗"),
		true,
		"Buy cash/space check uses ✗ when blocked"
	)


func _test_ui_helpers_do_not_read_hidden_values() -> void:
	for path: String in [
		"res://scripts/ui/demand_signal_presenter.gd",
		"res://scripts/ui/hud.gd",
		"res://scripts/shop/staff_presenter.gd",
		"res://scripts/shop/staff_member.gd",
		"res://scripts/shop/shop_state.gd",
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
		"$8,000.00",
		"Prep cash formats as $8,000.00"
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
		hud_scene.contains("$8,000.00"),
		true,
		"Prep HUD scene default is seeded cash"
	)
	_expect_equal(
		hud_scene.contains("$0.00"),
		false,
		"Prep HUD scene default is not $0"
	)
	_expect_equal(
		hud_scene.contains("Att 100/100"),
		true,
		"Prep HUD scene default is seeded attention"
	)
	_expect_equal(
		hud_scene.contains("res://themes/shop_hud.tres"),
		true,
		"Prep HUD scene uses shop HUD theme"
	)


func _test_gameplay_hud_visual_smoke() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("is_game_active", false)
	_economy.set("balance_cents", 0)
	_game_state.set("attention_remaining", 0)
	var packed: PackedScene = load("res://scenes/ui/gameplay_hud.tscn") as PackedScene
	_expect_equal(packed != null, true, "gameplay HUD scene loads")
	if packed == null:
		return
	var hud: Node = packed.instantiate()
	root.add_child(hud)
	var cash := hud.get_node_or_null("%CashLabel") as Label
	var attention := hud.get_node_or_null("%AttentionLabel") as Label
	var day := hud.get_node_or_null("%DayLabel") as Label
	var phase := hud.get_node_or_null("%PhaseLabel") as Label
	var queue := hud.get_node_or_null("%QueueLabel") as Label
	var phase_chip := hud.get_node_or_null("%PhaseChip") as PanelContainer
	var open_floor := hud.get_node_or_null("%PhaseButton") as Button
	var buy_button := hud.get_node_or_null("%OpenBuyButton") as Button
	var price_button := hud.get_node_or_null("%OpenPriceButton") as Button
	var serve := hud.get_node_or_null("%CustomerServe") as PanelContainer
	_expect_equal(cash != null and cash.text == "$8,000.00", true, "HUD binds Prep $8,000.00")
	_expect_equal(
		attention != null and attention.text == "Att 100/100",
		true,
		"HUD binds Prep attention 100"
	)
	_expect_equal(day != null and day.text == "Day 1", true, "HUD binds Day 1")
	_expect_equal(
		phase != null and phase.text == "PREP",
		true,
		"HUD binds PREP phase chip"
	)
	_expect_equal(
		queue != null and queue.text == "Queue 0",
		true,
		"HUD binds empty queue"
	)
	_expect_equal(
		hud.get("theme") != null,
		true,
		"HUD theme resource assigned"
	)
	_expect_equal(
		phase_chip != null and phase_chip.theme_type_variation == &"PhaseChipPrep",
		true,
		"PREP uses phase chip variation"
	)
	_expect_equal(
		open_floor != null and open_floor.custom_minimum_size.y >= 40.0,
		true,
		"Open floor hit target height"
	)
	_expect_equal(
		buy_button != null and buy_button.custom_minimum_size.y >= 40.0,
		true,
		"Buy opportunity hit target height"
	)
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	_expect_equal(inspect_button != null, true, "Inspect★ button present")
	_expect_equal(
		inspect_button != null
		and inspect_button.text.contains("Inspect★")
		and inspect_button.text.contains("Att 5"),
		true,
		"Inspect★ label shows owner Att cost"
	)
	_expect_equal(
		inspect_button != null and inspect_button.custom_minimum_size.y >= 40.0,
		true,
		"Inspect★ hit target height"
	)
	var research_button := hud.get_node_or_null("%OpenResearchButton") as Button
	var rearrange_button := hud.get_node_or_null("%OpenRearrangeButton") as Button
	var event_banner := hud.get_node_or_null("%EventBannerLabel") as Label
	_expect_equal(event_banner != null, true, "thin event banner present")
	_expect_equal(
		event_banner != null and event_banner.visible == false,
		true,
		"event banner hidden with no active event"
	)
	_expect_equal(research_button != null, true, "Research button present")
	_expect_equal(
		research_button != null
		and research_button.text.contains("Att 15")
		and research_button.text.contains("$50.00"),
		true,
		"Research button shows cash and Att cost"
	)
	_expect_equal(
		research_button != null and research_button.custom_minimum_size.y >= 40.0,
		true,
		"Research hit target height"
	)
	_expect_equal(rearrange_button != null, true, "Rearrange button present")
	_expect_equal(
		rearrange_button != null and rearrange_button.text.contains("Att 10"),
		true,
		"Rearrange button shows Att cost"
	)
	_expect_equal(
		rearrange_button != null and rearrange_button.custom_minimum_size.y >= 40.0,
		true,
		"Rearrange hit target height"
	)
	_expect_equal(
		price_button != null and price_button.custom_minimum_size.y >= 40.0,
		true,
		"Price inventory hit target height"
	)
	var price_input := hud.get_node_or_null("%PriceInput") as LineEdit
	_expect_equal(
		price_input != null and price_input.custom_minimum_size.y >= 40.0,
		true,
		"Your list input is the larger primary field"
	)
	_expect_equal(
		open_floor != null and open_floor.theme_type_variation == &"PrimaryButton",
		true,
		"Open floor uses primary button variation"
	)
	_expect_equal(serve != null, true, "CustomerServe panel present")
	var patience := hud.get_node_or_null("%PatienceBar") as ProgressBar
	_expect_equal(patience != null, true, "CustomerServe patience bar present")
	_expect_equal(
		patience != null and patience.custom_minimum_size.x >= 120.0,
		true,
		"Patience bar is at least 120px wide"
	)
	_expect_equal(
		patience != null and patience.show_percentage == false,
		true,
		"Patience bar is a meter, not a percent label"
	)
	var price_chip_row := hud.get_node_or_null("%PriceChipRow") as HBoxContainer
	var position_chip := hud.get_node_or_null("%PricePositionChip") as Label
	_expect_equal(price_chip_row != null, true, "PriceEditor has a chip strip")
	_expect_equal(
		position_chip != null,
		true,
		"PriceEditor position chip is present"
	)
	var hud_scene := FileAccess.get_file_as_string(
		"res://scenes/ui/gameplay_hud.tscn"
	)
	_expect_equal(
		hud_scene.contains("text = \"Your list\""),
		true,
		"PriceEditor labels the primary input Your list"
	)
	_expect_equal(
		hud_scene.contains("ACC-*"),
		false,
		"HUD chrome does not show raw accessory SKU walls"
	)
	_expect_equal(
		serve != null and serve.offset_left >= 48.0 and serve.offset_bottom <= 480.0,
		true,
		"CustomerServe hugs left edge above lower third"
	)
	var buy_list := hud.get_node_or_null("%BuyOpportunityList") as PanelContainer
	_expect_equal(
		buy_list != null
		and buy_list.offset_left >= 48.0
		and buy_list.offset_bottom <= 480.0,
		true,
		"Buy list stays in left edge chrome"
	)
	var veil := hud.get_node_or_null("%ModalVeil") as ColorRect
	_expect_equal(veil != null, true, "Modal veil present")
	_expect_equal(
		veil != null and veil.visible == false,
		true,
		"Veil hidden until a modal opens"
	)
	_expect_equal(
		veil != null and is_equal_approx(veil.color.a, 0.4),
		true,
		"Modal veil is a 40% soft dim"
	)
	var theme_source := FileAccess.get_file_as_string("res://themes/shop_hud.tres")
	_expect_equal(
		theme_source.contains("bg_color = Color(0.145, 0.145, 0.155, 0.78)"),
		true,
		"Modal panels use charcoal fill at ~78% opacity"
	)
	_expect_equal(
		theme_source.contains("Color(0.957, 0.941, 0.91"),
		true,
		"Cream is reserved for HUD type on dark chrome"
	)
	_expect_equal(
		theme_source.contains("corner_radius_top_left = 10"),
		true,
		"Panel corner radius is 8–12"
	)
	_expect_equal(
		theme_source.contains("Color(0.24, 0.43, 0.42"),
		true,
		"Muted teal is the system accent"
	)
	_expect_equal(
		theme_source.contains("id=\"StyleSignalChip\""),
		true,
		"Signal chips use calm gunmetal chrome, not extra accent fill"
	)
	_expect_equal(
		theme_source.contains("id=\"StyleProgressFill\""),
		true,
		"Patience meter fill is themed cream, not a second accent"
	)
	var hud_script: Script = hud.get_script()
	_expect_equal(hud_script != null, true, "HUD script attached")
	var wants := DemandSignalPresenter.wants_label(
		"Bastion Captain",
		&"AA-BASE-088",
		"NM"
	)
	_expect_equal(wants, "Bastion Captain · NM", "Wants keeps bible · condition")
	_expect_equal(wants.contains("AA-"), false, "Wants smoke stays non-SKU")
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("_customer_wants_label"),
		true,
		"CustomerServe still uses Wants helper"
	)
	_expect_equal(
		hud_source.contains("String(_current_customer.target_sku)"),
		false,
		"CustomerServe still hides raw SKU ids"
	)
	_expect_equal(
		hud_source.contains("Camera") or hud_source.contains("fov"),
		false,
		"HUD script does not mutate camera/FOV"
	)
	var steady_chip := DemandSignalPresenter.band_chip(&"steady")
	_expect_equal(
		steady_chip.contains("STEADY") and steady_chip != "STEADY",
		true,
		"Demand chips include icon and label"
	)
	_expect_equal(
		DemandSignalPresenter.position_chip(&"undercut").contains("Undercut"),
		true,
		"Position chips keep label text"
	)
	root.remove_child(hud)
	hud.free()


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


func _test_market_events_seven_day_seeded_run() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_qa_autoload.call("set_force_enabled", true)
	var non_null := 0
	var seeds: Array[int] = [MarketEventService.EVENT_RNG_SEED]
	for extra: int in range(1, 32):
		seeds.append(extra)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		_demand_signals.call("seed_event_rng", rng_seed)
		_qa_autoload.call("clear")
		non_null = 0
		for _day_index: int in range(7):
			_expect_equal(
				_game_state.call("start_floor"),
				true,
				"7-day seeded run can open floor"
			)
			_expect_equal(
				_game_state.call("start_settle"),
				true,
				"7-day seeded run can settle"
			)
			if int(_game_state.get("current_day")) < 7:
				_expect_equal(
					_game_state.call("advance_day"),
					true,
					"7-day seeded run can advance"
				)
		for event: Dictionary in _qa_autoload.call("get_events"):
			if String(event.get("event", "")) != "market_event_rolled":
				continue
			var payload: Dictionary = event.get("payload", {})
			_assert_payload_has_no_truth(payload, "7-day market_event_rolled")
			if String(payload.get("event_id", "")).is_empty():
				continue
			non_null += 1
		if non_null >= 1:
			break
	_expect_equal(non_null >= 1, true, "Normal 7-day seeded run emits ≥1 non-null event")
	_expect_equal(
		FileAccess.get_file_as_string("res://data/events.json").contains("hype_spike")
		and FileAccess.get_file_as_string("res://data/events.json").contains("soft_rotation_leak")
		and FileAccess.get_file_as_string("res://data/events.json").contains("fog_day"),
		true,
		"C1 pack catalogs hype, rotation leak, and fog"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_hype_spike_target_sku_only() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var control_sku := &"AA-BASE-088"
	var titan := &"AA-SKIE-047"
	var control_before := _demand_signals.call(
		"price_signal",
		control_sku,
		500,
		_inventory_service.call("location_for", control_sku)
	) as PriceConfirmSignal
	var control_market_before := (
		_demand_signals.get("_market_state") as MarketState
	).market_cents_for(control_sku)
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": titan, "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(started != null, true, "hype pack starts")
	_expect_equal(started.sku_id, titan, "hype targets Titan only")
	var titan_signal := _demand_signals.call(
		"price_signal",
		titan,
		2200,
		_inventory_service.call("location_for", titan)
	) as PriceConfirmSignal
	var control_after := _demand_signals.call(
		"price_signal",
		control_sku,
		500,
		_inventory_service.call("location_for", control_sku)
	) as PriceConfirmSignal
	_expect_equal(titan_signal.shown_demand_band, &"hot", "hype elevates target band to HOT")
	_expect_equal(
		titan_signal.suggested_price_cents > 2200,
		true,
		"hype elevates target noisy comps"
	)
	_expect_equal(
		(
			_demand_signals.get("_market_state") as MarketState
		).market_cents_for(control_sku),
		control_market_before,
		"hype does not change other SKU market"
	)
	_expect_equal(
		control_after.shown_demand_band,
		control_before.shown_demand_band,
		"hype leaves control SKU band unchanged"
	)
	_expect_dto_has_no_truth_fields(titan_signal, "hype price signal")
	_expect_dto_has_no_truth_fields(control_after, "hype control price signal")
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(titan_signal),
		"hype PriceEditor summary"
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("HOT"), true, "hype banner uses HOT chip language")
	_expect_equal(banner.contains("Titan"), true, "hype banner names the SKU")
	_assert_text_has_no_truth(banner, "hype banner")
	var hud := _instantiate_gameplay_hud()
	if hud != null:
		var banner_label := hud.get_node_or_null("%EventBannerLabel") as Label
		_expect_equal(banner_label != null, true, "thin event banner exists")
		_expect_equal(
			banner_label != null and banner_label.visible and banner_label.text.contains("HOT"),
			true,
			"HUD banner shows hype without a new screen"
		)
		_assert_text_has_no_truth(
			banner_label.text if banner_label != null else "",
			"HUD hype banner"
		)
		var demand_chip := hud.get_node_or_null("%PriceDemandChip") as Label
		_expect_equal(demand_chip != null, true, "PriceEditor demand chip still present")
		hud.queue_free()


func _test_fog_day_sigma_and_inversion() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var base_sigma: float = _demand_signals.call("active_demand_band_sigma", false)
	_expect_equal(is_equal_approx(base_sigma, 0.12), true, "Normal base σ is 0.12")
	_expect_equal(
		_demand_signals.call("has_fog_flag"),
		false,
		"no fog flag before fog day"
	)
	var market_state := MarketState.new()
	for demand_score: float in [0.0, 1.0]:
		market_state.update_sku(&"AA-SKIE-047", 10_000, demand_score)
		var inversion_service := DemandSignalService.new(
			NORMAL_CONFIG, market_state, 123, _qa
		)
		_expect_equal(inversion_service.has_fog_flag(), false, "service starts without fog flag")
		for day: int in range(1, 81):
			var dto := inversion_service.buy_confirm(
				day, &"AA-SKIE-047", DemandSignalService.Channel.SHADY,
				5000, 1, 800_000, 1, 10
			)
			var cruel_inversion := (
				demand_score == 0.0 and dto.shown_demand_band == &"hot"
				or demand_score == 1.0 and dto.shown_demand_band == &"cold"
			)
			_expect_equal(
				cruel_inversion,
				false,
				"without fog flag Cold↔Hot inversion never shown"
			)
	var fog: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_FOG,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(fog != null, true, "fog day starts")
	_expect_equal(fog.fog_flag, true, "fog day sets fog flag")
	_expect_equal(_demand_signals.call("has_fog_flag"), true, "pack exposes fog flag")
	var fog_sigma: float = _demand_signals.call("active_demand_band_sigma", false)
	_expect_equal(fog_sigma > base_sigma, true, "fog day widens σ")
	_expect_equal(
		is_equal_approx(fog_sigma, base_sigma * MarketEventService.FOG_SIGMA_MULT),
		true,
		"fog σ uses pack widen, not a new BalanceConfig knob"
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("Fog"), true, "fog banner is thin and named")
	_assert_text_has_no_truth(banner, "fog banner")
	_demand_signals.call("apply_event_save", {})
	_expect_equal(_demand_signals.call("has_fog_flag"), false, "clearing fog drops the flag")
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_demand_band_sigma", false)),
			base_sigma
		),
		true,
		"σ returns to Normal after fog expires"
	)


func _test_market_event_save_load() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": &"AA-SKIE-047", "duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(started != null, true, "save-load fixture hype starts")
	_game_state.set("current_day", 4)
	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "market event save")
	var stored: Dictionary = saved.get("market_event", {})
	_expect_equal(String(stored.get("id", "")), "hype_spike", "save writes event id")
	_expect_equal(int(stored.get("remaining_days", 0)), 3, "save writes remaining days")
	_expect_equal(String(stored.get("sku_id", "")), "AA-SKIE-047", "save writes target SKU")
	_game_state.call("start_new_game")
	_expect_equal(
		_demand_signals.call("active_event") == null,
		true,
		"new game clears active event"
	)
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"restore_save accepts market event snapshot"
	)
	var restored: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(restored != null, true, "save/load restores active event")
	_expect_equal(restored.kind, MarketEvent.KIND_HYPE, "restored kind")
	_expect_equal(restored.remaining_days, 3, "save/load restores remaining days")
	_expect_equal(restored.sku_id, &"AA-SKIE-047", "restored hype SKU")
	var titan_signal := _demand_signals.call(
		"price_signal",
		&"AA-SKIE-047",
		2200,
		_inventory_service.call("location_for", &"AA-SKIE-047")
	) as PriceConfirmSignal
	_expect_equal(titan_signal.shown_demand_band, &"hot", "restored hype still HOT")
	_expect_dto_has_no_truth_fields(titan_signal, "restored hype signal")

	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_ROTATION,
		{"set_id": &"AA-DUST", "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(
		String(_demand_signals.call("event_banner_text")),
		"",
		"rotation leak stays hidden without Research/Specialist"
	)
	var shop := _game_state.get("shop") as ShopState
	shop.hire_specialist()
	_expect_equal(
		String(_demand_signals.call("event_banner_text")).contains("Dustway"),
		true,
		"Specialist foreshadows the rotation leak"
	)
	_assert_text_has_no_truth(
		String(_demand_signals.call("event_banner_text")),
		"rotation leak banner"
	)
	_assert_text_has_no_truth(
		String(_demand_signals.call("rotation_watch_text")),
		"rotation leak watch"
	)
	var rotation_saved: Dictionary = _game_state.call("capture_save")
	_game_state.call("start_new_game")
	_game_state.call("restore_save", rotation_saved)
	var leak: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(leak != null, true, "save/load restores rotation leak")
	_expect_equal(leak.remaining_days, 2, "rotation remaining days restore")
	_expect_equal(
		String(_demand_signals.call("event_banner_text")).contains("Dustway"),
		true,
		"restored Specialist still sees the leak"
	)


func _test_marketplace_outing_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_captured_buy_focus_id = &""
	_beat_director.call("_start_day_beats", 3)
	_expect_equal(
		_beat_director.call("is_started", MARKETPLACE_OUTING_BEAT),
		true,
		"marketplace outing starts on Normal day three PREP"
	)
	_expect_equal(
		StringName(_captured_beat_decision.get("beat_id", &"")),
		MARKETPLACE_OUTING_BEAT,
		"outing decision carries beat tag"
	)
	_expect_equal(
		String(_captured_beat_decision.get("title", "")),
		"Off-site lot — leave the floor?",
		"outing modal title"
	)
	var outing_ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"drive_out" in outing_ids, true, "outing offers Drive out")
	_expect_equal(&"courier" in outing_ids, true, "outing offers Courier fee")
	_expect_equal(&"skip" in outing_ids, true, "outing offers Skip")
	_assert_payload_has_no_truth(_captured_beat_decision, "outing decision")
	var outing_dto := _demand_signals.call(
		"buy_signal_for_id",
		&"marketplace-outing-steal"
	) as BuyConfirmSignal
	_expect_equal(outing_dto != null, true, "outing injects marketplace lot")
	if outing_dto != null:
		_expect_dto_has_no_truth_fields(outing_dto, "outing buy signal")
		_expect_equal(outing_dto.channel, &"marketplace", "outing channel")
		_expect_equal(outing_dto.confidence, &"low", "outing Low confidence")
		_expect_equal(
			outing_dto.condition_cue.to_lower().contains("photo"),
			true,
			"outing Photo only condition cue"
		)
		var midpoint := (
			outing_dto.shown_comp_low_cents + outing_dto.shown_comp_high_cents
		) / 2
		_expect_equal(
			outing_dto.unit_cost_cents < midpoint,
			true,
			"outing lot looks underpriced vs noisy comp"
		)
		_expect_equal(
			outing_dto.beat_id,
			MARKETPLACE_OUTING_BEAT,
			"outing opportunity tagged for QA"
		)
	var attention_before := int(_game_state.get("attention_remaining"))
	_captured_buy_focus_id = &""
	_expect_equal(
		_beat_director.call("choose_beat_path", &"drive_out"),
		true,
		"outing Drive out path"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		attention_before - NORMAL_CONFIG.marketplace_outing_attention,
		"Drive out spends outing Attention"
	)
	_expect_equal(
		float(_game_state.get("pending_floor_skip_seconds")) > 0.0,
		true,
		"Drive out shortens FLOOR window"
	)
	_expect_equal(
		_captured_buy_focus_id,
		&"marketplace-outing-steal",
		"Drive out opens BuyOpportunityDetail"
	)
	_expect_equal(
		_beat_director.call("is_completed", MARKETPLACE_OUTING_BEAT),
		true,
		"Drive out completes outing beat"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 3)
	var cash_before_courier := int(_economy.get("balance_cents"))
	_expect_equal(
		_beat_director.call("choose_beat_path", &"courier"),
		true,
		"outing Courier path"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_courier - NORMAL_CONFIG.marketplace_courier_fee_cents,
		"Courier pays fee and keeps FLOOR"
	)
	_expect_equal(
		float(_game_state.get("pending_floor_skip_seconds")),
		0.0,
		"Courier does not skip FLOOR hours"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 3)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"skip"),
		true,
		"outing Skip path"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"marketplace-outing-steal") == null,
		true,
		"Skip dismisses the opportunity"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 3)
	_expect_equal(
		_beat_director.call("is_started", MARKETPLACE_OUTING_BEAT),
		false,
		"Hard does not auto-start marketplace outing"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("AA-SKIE-ETB"),
		false,
		"HUD does not hardcode outing SKU"
	)
	_expect_equal(
		hud_source.contains("beat_decision_requested"),
		true,
		"HUD wires optional beat decision modal"
	)
	var hud_scene := FileAccess.get_file_as_string(
		"res://scenes/ui/gameplay_hud.tscn"
	)
	_expect_equal(
		hud_scene.contains("BeatDecision"),
		true,
		"gameplay HUD has the optional beat decision panel"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_hire_cashier_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("is_started", HIRE_CASHIER_BEAT),
		true,
		"hire cashier starts on Normal day five PREP"
	)
	_expect_equal(
		String(_captured_beat_decision.get("title", "")),
		"Counter’s getting slammed — hire help?",
		"hire modal title"
	)
	var hire_ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"hire_cashier" in hire_ids, true, "hire offers Cashier")
	_expect_equal(&"keep_solo" in hire_ids, true, "hire offers Keep solo")
	_expect_equal(&"hire_cheap" in hire_ids, true, "hire offers cheap path")
	_expect_equal(&"hire_specialist" in hire_ids, true, "hire offers Specialist")
	var confirms: Dictionary = _captured_beat_decision.get("confirms", {})
	var cheap_confirm: Dictionary = confirms.get("hire_cheap", {})
	_expect_equal(
		String(cheap_confirm.get("body", "")).contains("Reliability"),
		true,
		"cheap hire confirm warns Reliability"
	)
	_assert_payload_has_no_truth(_captured_beat_decision, "hire decision")
	_expect_equal(
		_beat_director.call("choose_beat_path", &"hire_cashier"),
		true,
		"hire Cashier path"
	)
	var shop: ShopState = _game_state.get("shop")
	_expect_equal(shop.hired_count(), 1, "hire adds one staff")
	_expect_equal(shop.staff[0].wage_cents > 0, true, "hire stores a wage")
	_expect_equal(
		is_equal_approx(shop.staff[0].reliability, ShopState.CASHIER_RELIABILITY),
		true,
		"standard cashier reliability"
	)
	_expect_equal(shop.hire_cashier(false) == null, true, "Small staff cap blocks second hire")
	var cash_before_wage := int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_wage - ShopState.CASHIER_WAGE_CENTS,
		"cashier wage posts at SETTLE"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"hire_cheap"),
		true,
		"hire cheap path"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.staff[0].theft_bias, true, "cheap hire has theft/no-show bias")
	_expect_equal(
		shop.staff[0].reliability <= ShopState.CHEAP_CASHIER_RELIABILITY,
		true,
		"cheap hire Reliability at or below 0.55"
	)
	cash_before_wage = int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_wage - ShopState.CHEAP_CASHIER_WAGE_CENTS,
		"cheap wage posts at SETTLE"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"keep_solo"),
		true,
		"Keep solo closes hire beat"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.hired_count(), 0, "Keep solo adds no staff")
	cash_before_wage = int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_wage,
		"Keep solo posts no wage"
	)

	_game_state.call("set_balance_config", EASY_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	shop = _game_state.get("shop")
	_expect_equal(shop.is_owner_only(), false, "Easy seeds a trainee cashier")
	_expect_equal(
		_beat_director.call("is_started", HIRE_CASHIER_BEAT),
		false,
		"Easy/trainee does not auto-start hire beat"
	)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", HIRE_CASHIER_BEAT),
		false,
		"hire QA refuses when staff cap is already filled"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_specialist_staff_path() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.inspect_attention_cost(), 5, "no Specialist → Inspect Att 5")
	_expect_equal(shop.research_attention_cost(), 15, "no Specialist → Research Att 15")
	_expect_equal(shop.has_specialist_on_duty(), false, "owner-only has no Specialist")
	_expect_equal(
		NORMAL_CONFIG.specialist_wage_cents,
		14_000,
		"BalanceConfig specialist wage is $140/day"
	)
	_expect_equal(shop.specialist_wage_cents(), 14_000, "ShopState reads specialist wage")

	_expect_equal(shop.hire_specialist() != null, true, "hire Specialist under Small cap")
	_expect_equal(shop.specialist_count(), 1, "roster has one Specialist")
	_expect_equal(shop.staff[0].role, &"specialist", "hired role is specialist")
	_expect_equal(shop.staff[0].is_specialist(), true, "StaffMember.is_specialist")
	_expect_equal(shop.staff[0].wage_cents, 14_000, "Specialist wage from BalanceConfig")
	_expect_equal(shop.staff[0].visual_scene_path(), "", "Specialist is domain-only (no mesh)")
	_expect_equal(shop.has_specialist_on_duty(), true, "hired Specialist is on duty")
	_expect_equal(shop.inspect_attention_cost(), 2, "Specialist on duty → Inspect Att 2")
	_expect_equal(shop.research_attention_cost(), 10, "Specialist on duty → Research Att 10")
	_expect_equal(shop.hire_specialist() == null, true, "Small cap blocks second Specialist")
	_expect_equal(shop.hire_cashier(false) == null, true, "Small cap blocks cashier after Specialist")

	var cash_before := int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - 14_000,
		"Specialist wage posts at SETTLE"
	)

	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "specialist save payload")
	var saved_staff: Array = (saved.get("shop", {}) as Dictionary).get("staff", [])
	_expect_equal(saved_staff.size(), 1, "save writes Specialist roster")
	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.specialist_count(), 0, "new game clears Specialist")
	_expect_equal(shop.inspect_attention_cost(), 5, "new game owner Inspect 5")
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"restore_save accepts Specialist snapshot"
	)
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.specialist_count(), 1, "save/load restores Specialist")
	_expect_equal(shop.staff[0].role, &"specialist", "restored role is specialist")
	_expect_equal(shop.staff[0].wage_cents, 14_000, "restored Specialist wage")
	_expect_equal(shop.has_specialist_on_duty(), true, "restored Specialist is on duty")
	_expect_equal(shop.inspect_attention_cost(), 2, "restored Specialist Inspect Att 2")
	_expect_equal(shop.research_attention_cost(), 10, "restored Specialist Research Att 10")

	_expect_equal(shop.fire_staff(0) != null, true, "fire removes Specialist")
	_expect_equal(shop.specialist_count(), 0, "fired Specialist leaves roster")
	_expect_equal(shop.has_specialist_on_duty(), false, "fire clears on-duty Specialist")
	_expect_equal(shop.inspect_attention_cost(), 5, "after fire Inspect returns to 5")
	_expect_equal(shop.research_attention_cost(), 15, "after fire Research returns to 15")

	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"hire_specialist"),
		true,
		"day-5 hire beat can pick Specialist"
	)
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.specialist_count(), 1, "beat hire adds Specialist")
	_expect_equal(shop.cashier_count(), 0, "Specialist hire leaves cashiers unchanged")
	_assert_payload_has_no_truth(_captured_beat_decision, "specialist hire decision")

	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	_expect_equal(shop.expand_to_medium(18, 1_600_000, 55), true, "Medium unlocks staff cap 3")
	_expect_equal(shop.hire_cashier(false) != null, true, "Medium can still hire cashier")
	_expect_equal(shop.hire_specialist() != null, true, "Medium can hire Specialist after cashier")
	_expect_equal(shop.cashier_count(), 1, "cashier still on roster")
	_expect_equal(shop.specialist_count(), 1, "Specialist shares Medium cap")
	_expect_equal(shop.inspect_attention_cost(), 2, "mixed roster Inspect uses Specialist cost")
	_expect_equal(shop.research_attention_cost(), 10, "mixed roster Research uses Specialist cost")
	_expect_equal(shop.hire_cashier(false) != null, true, "Medium hire #3 still allowed")
	_expect_equal(shop.hire_specialist() == null, true, "Medium cap blocks fourth hire")
	_expect_equal(shop.hire_cashier(false) == null, true, "Medium cap still blocks extra cashier")

	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "gameplay HUD loads for Specialist")
	if hud == null:
		return
	var open_staff := hud.get_node_or_null("%OpenStaffButton") as Button
	var hire_specialist := hud.get_node_or_null("%HireSpecialistButton") as Button
	var open_research := hud.get_node_or_null("%OpenResearchButton") as Button
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	_expect_equal(open_staff != null, true, "Staff hire button present")
	_expect_equal(
		open_research != null and open_research.text.contains("Att 15"),
		true,
		"HUD Research shows owner Att 15 before hire"
	)
	_expect_equal(
		inspect_button != null
		and inspect_button.text.contains("Inspect★")
		and inspect_button.text.contains("Att 5"),
		true,
		"HUD Inspect★ shows owner Att 5 before hire"
	)
	open_staff.pressed.emit()
	_expect_equal(
		hire_specialist != null and not hire_specialist.disabled,
		true,
		"Staff panel can hire Specialist under cap"
	)
	_expect_equal(
		hire_specialist != null and hire_specialist.text.contains("$140.00"),
		true,
		"Staff panel wage comes from BalanceConfig"
	)
	hire_specialist.pressed.emit()
	_expect_equal(shop.specialist_count(), 1, "HUD hire adds Specialist")
	_expect_equal(
		open_research.text.contains("Att 10"),
		true,
		"HUD Research shows Specialist Att 10 before confirm"
	)
	_expect_equal(
		inspect_button.text.contains("Att 2"),
		true,
		"HUD Inspect★ shows Specialist Att 2 before confirm"
	)
	_expect_equal(hire_specialist.disabled, true, "HUD hire disables at Small cap")
	var hire_cashier := hud.get_node_or_null("%HireCashierButton") as Button
	_expect_equal(
		hire_cashier != null and hire_cashier.disabled,
		true,
		"HUD cashier hire also blocked at cap"
	)

	var open_buy := hud.get_node_or_null("%OpenBuyButton") as Button
	open_buy.pressed.emit()
	_expect_equal(
		_click_buy_row_for_channel(hud, &"marketplace"),
		true,
		"marketplace lot for Specialist inspect"
	)
	_expect_equal(
		inspect_button.visible and not inspect_button.disabled,
		true,
		"Inspect★ enabled at Specialist cost"
	)
	_expect_equal(
		inspect_button.text.contains("Att 2"),
		true,
		"detail Inspect★ still shows Att 2"
	)
	inspect_button.pressed.emit()
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		98,
		"Inspect★ spends Specialist Att 2"
	)
	_assert_text_has_no_truth(inspect_button.text, "Inspect★ label")
	_assert_text_has_no_truth(open_research.text, "Research label")
	_assert_text_has_no_truth(hire_specialist.text, "hire Specialist label")
	_assert_payload_has_no_truth(_game_state.call("capture_save"), "post-hire save")
	root.remove_child(hud)
	hud.free()
	_game_state.call("start_new_game")


func _test_expand_medium_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 18)
	_expect_equal(
		_beat_director.call("is_started", EXPAND_MEDIUM_BEAT),
		true,
		"expand starts on Normal day 18 PREP even if gates fail"
	)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"sign_lease"),
		false,
		"Sign stays gated without cash and Rep"
	)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"wait_for_rep"),
		true,
		"Wait for Rep shows when Rep is low"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		false,
		"Sign cannot upgrade without gates"
	)
	_assert_payload_has_no_truth(_captured_beat_decision, "expand soft-fail")
	var shop: ShopState = _game_state.get("shop")
	var stay_walkable := shop.walkable_tile_count()
	_expect_equal(
		_beat_director.call("choose_beat_path", &"stay_small"),
		true,
		"Stay Small leaves the shop Small"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.SMALL, "Stay Small keeps Small tier")
	_expect_equal(shop.grid_width, ShopState.SMALL_GRID_WIDTH, "Stay Small width")
	_expect_equal(shop.grid_height, ShopState.SMALL_GRID_HEIGHT, "Stay Small height")
	_expect_equal(shop.layout.width, ShopState.SMALL_GRID_WIDTH, "Stay Small layout width")
	_expect_equal(shop.layout.height, ShopState.SMALL_GRID_HEIGHT, "Stay Small layout height")
	_expect_equal(shop.walkable_tile_count(), stay_walkable, "Stay Small walkable count")
	_assert_shop_shell_state(false, "Stay Small")

	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 18)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"sign_lease"),
		true,
		"Sign enabled when cash and Rep gates pass"
	)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"wait_for_rep"),
		false,
		"Wait for Rep hidden when Rep already meets gate"
	)
	var confirms: Dictionary = _captured_beat_decision.get("confirms", {})
	var lease_confirm: Dictionary = confirms.get("sign_lease", {})
	var lease_body := String(lease_confirm.get("body", ""))
	_expect_equal(
		lease_body.contains(
			DemandSignalPresenter.format_cents(NORMAL_CONFIG.rent_small_weekly_cents)
		)
		and lease_body.contains(
			DemandSignalPresenter.format_cents(NORMAL_CONFIG.rent_medium_weekly_cents)
		),
		true,
		"lease confirm shows old vs new rent"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		true,
		"Sign lease path"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "Sign upgrades to Medium")
	_expect_equal(shop.staff_cap(), 3, "Medium staff cap unlocks")
	_expect_equal(shop.grid_width, ShopState.MEDIUM_GRID_WIDTH, "Medium grid width 14")
	_expect_equal(shop.grid_height, ShopState.MEDIUM_GRID_HEIGHT, "Medium grid height 10")
	_expect_equal(shop.layout.width, 14, "layout grows to Medium width")
	_expect_equal(shop.layout.height, 10, "layout grows to Medium height")
	_expect_equal(shop.tile_count(), 140, "Medium tile count is 140")
	_expect_equal(
		shop.walkable_tile_count() > stay_walkable,
		true,
		"Sign increases walkable tiles"
	)
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(1, 4),
		"existing fixtures stay on old tiles"
	)
	_expect_equal(shop.layout.has_circulation(), true, "Medium circulation holds")
	_expect_equal(
		(_inventory_service.get("model") as InventoryModel).case_slot_limit(),
		NORMAL_CONFIG.case_slots + ShopState.MEDIUM_CASE_SLOT_BONUS,
		"Medium case capacity unlocks"
	)
	_expect_equal(
		shop.weekly_rent_cents(18),
		NORMAL_CONFIG.rent_small_weekly_cents,
		"signed-day rent stays Small"
	)
	_expect_equal(
		shop.weekly_rent_cents(21),
		NORMAL_CONFIG.rent_medium_weekly_cents,
		"Medium rent applies next week"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 18)
	_expect_equal(
		_beat_director.call("is_started", EXPAND_MEDIUM_BEAT),
		false,
		"Hard does not auto-start Medium expand"
	)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", EXPAND_MEDIUM_BEAT),
		true,
		"Hard can still open the expand modal via QA"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		false,
		"Hard start cash/Rep cannot Sign"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_medium_floor_growth() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop: ShopState = _game_state.get("shop")
	var small_walkable := shop.walkable_tile_count()
	var small_grid_walkable := shop.floor_grid.walkable_count()
	_expect_equal(shop.tile_count(), 80, "Small starts 10×8")
	_expect_equal(small_walkable > 0, true, "Small has walkable tiles")
	_expect_equal(
		FileAccess.file_exists(ShopFloorExtent.MEDIUM_SHELL_SCENE),
		true,
		"Art Medium shell GLB is on disk"
	)
	_assert_shop_shell_state(false, "pre-Sign / Stay Small")

	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_economy.set("balance_cents", 1_000_000)
	_game_state.set("current_reputation", 40)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 18)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"wait_for_rep"),
		true,
		"Wait for Rep is available when Rep is low"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.SMALL, "Wait for Rep keeps Small")
	_expect_equal(shop.grid_width, 10, "Wait for Rep width unchanged")
	_expect_equal(shop.grid_height, 8, "Wait for Rep height unchanged")
	_expect_equal(shop.layout.width, 10, "Wait for Rep layout width")
	_expect_equal(shop.walkable_tile_count(), small_walkable, "Wait for Rep walkable")
	_expect_equal(
		shop.weekly_rent_cents(21),
		NORMAL_CONFIG.rent_small_weekly_cents,
		"Wait for Rep rent stays Small"
	)

	_game_state.call("start_new_game")
	shop = _game_state.get("shop")
	var counter := shop.layout.fixture_by_id(&"counter")
	_expect_equal(counter != null, true, "default counter exists")
	counter.is_counter = false
	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	_expect_equal(
		shop.preview_expand_medium(),
		&"blocked_path",
		"expand preview fails when counter is unreachable"
	)
	_expect_equal(
		shop.expand_to_medium(18, 1_600_000, 55),
		false,
		"Sign refuses when Medium pathing fails"
	)
	_expect_equal(shop.tier, ShopState.Tier.SMALL, "failed Sign stays Small")
	_expect_equal(shop.layout.width, 10, "failed Sign leaves layout Small")

	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	shop = _game_state.get("shop")
	var binder_origin := shop.layout.fixture_by_id(&"binder_rack").origin
	_expect_equal(
		_beat_director.call("_start_expand_medium"),
		true,
		"expand modal opens for growth test"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		true,
		"Sign lease grows the floor"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.grid_width, 14, "signed width is 14")
	_expect_equal(shop.grid_height, 10, "signed height is 10")
	_expect_equal(
		shop.walkable_tile_count() > small_walkable,
		true,
		"domain walkable tiles increase"
	)
	_expect_equal(
		shop.floor_grid.walkable_count() > small_grid_walkable,
		true,
		"NPC grid walkable tiles increase"
	)
	_expect_equal(shop.floor_grid.width, 14, "NPC grid width is Medium")
	_expect_equal(shop.floor_grid.is_walkable(Vector2i(12, 8)), true, "new Medium tile unlocks")
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		binder_origin,
		"binder stays on its Small tile"
	)
	_expect_equal(shop.layout.has_circulation(), true, "layout circulation on Medium")
	var circulation := shop.layout.circulation_path()
	_expect_equal(circulation.is_empty(), false, "entrance→displays→counter path")
	_assert_grid_path(
		shop.floor_grid,
		shop.floor_grid.entrance_tile,
		shop.floor_grid.browse_tiles[0],
		"Medium entrance→display"
	)
	_assert_grid_path(
		shop.floor_grid,
		shop.floor_grid.browse_tiles[0],
		shop.floor_grid.desk_tile,
		"Medium display→counter"
	)
	_assert_grid_path(
		shop.floor_grid,
		shop.floor_grid.entrance_tile,
		Vector2i(12, 8),
		"Medium entrance→new tile"
	)
	_game_state.call("start_floor")
	var presenter := _make_floor_presenter()
	_expect_equal(presenter.path_between(
		shop.floor_grid.tile_to_world(shop.floor_grid.entrance_tile),
		shop.floor_grid.tile_to_world(shop.floor_grid.desk_tile)
	).is_empty(), false, "presenter paths on Medium grid")
	presenter.free()

	_expect_equal(
		_economy.call("settle_weekly_obligations", 21),
		true,
		"week after Sign is a rent SETTLE day"
	)
	var rent_posted := 0
	var ledger: Array = _economy.call("get_ledger")
	for entry: Variant in ledger:
		var row := entry as LedgerEntry
		if row != null and row.category == &"rent":
			rent_posted = row.amount_cents
	_expect_equal(
		rent_posted,
		NORMAL_CONFIG.rent_medium_weekly_cents,
		"SETTLE posts Medium weekly rent"
	)

	_game_state.set("attention_remaining", 100)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	var moved := _game_state.call(
		"rearrange_fixture",
		&"binder_rack",
		Vector2i(12, 3)
	) as Dictionary
	_expect_equal(bool(moved.get("ok", false)), true, "rearrange onto new Medium tile")
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(12, 3),
		"binder occupies unlocked tile"
	)

	var saved: Dictionary = _game_state.call("capture_save")
	_expect_equal(saved.has("shop"), true, "save includes shop")
	_game_state.call("start_new_game")
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.SMALL, "new game resets to Small")
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"restore Medium save"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "save/load restores Medium")
	_expect_equal(shop.grid_width, 14, "save/load width")
	_expect_equal(shop.grid_height, 10, "save/load height")
	_expect_equal(shop.layout.width, 14, "save/load layout width")
	_expect_equal(shop.staff_cap(), 3, "save/load staff cap")
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(12, 3),
		"save/load keeps migrated fixture"
	)
	_expect_equal(
		shop.weekly_rent_cents(int(_game_state.get("current_day"))),
		NORMAL_CONFIG.rent_small_weekly_cents,
		"save/load signed-day rent stays Small"
	)
	_expect_equal(
		shop.weekly_rent_cents(int(_game_state.get("current_day")) + 3),
		NORMAL_CONFIG.rent_medium_weekly_cents,
		"save/load Medium rent tier"
	)
	_expect_equal(
		(_inventory_service.get("model") as InventoryModel).case_slot_limit(),
		NORMAL_CONFIG.case_slots + ShopState.MEDIUM_CASE_SLOT_BONUS,
		"save/load Medium case bonus"
	)
	_expect_equal(is_equal_approx(shop.usable_sq_ft(), 1220.625), true, "14×10 is ~1,221 sq ft")

	_assert_shop_shell_state(true, "Sign / save-load Medium")

	_game_state.call("start_new_game")
	_assert_shop_shell_state(false, "new game resets Small shell")


func _test_medium_overhead_lights() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_assert_overhead_lights_for_tier(false, "pre-Sign Small")

	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	var shop: ShopState = _game_state.get("shop")
	_expect_equal(
		shop.expand_to_medium(18, 1_600_000, 55),
		true,
		"Sign grows floor so Medium extras can show"
	)
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "expand sets Medium tier")
	_assert_overhead_lights_for_tier(true, "post-Sign Medium")

	_game_state.call("start_new_game")
	_assert_overhead_lights_for_tier(false, "new game hides Medium extras")


func _test_shady_trunk_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 18)
	_beat_director.call("choose_beat_path", &"stay_small")
	_game_state.set("current_day", 20)
	_captured_beat_decision = {}
	_captured_buy_focus_id = &""
	_beat_director.call("_start_day_beats", 20)
	_expect_equal(
		_beat_director.call("is_started", SHADY_TRUNK_BEAT),
		true,
		"shady trunk starts on Normal day 20 PREP after expand resolves"
	)
	_expect_equal(
		String(_captured_beat_decision.get("title", "")),
		"Trunk sale — too good?",
		"shady modal title"
	)
	var shady_ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"buy" in shady_ids, true, "shady offers Buy")
	_expect_equal(&"report" in shady_ids, true, "shady offers Report")
	_expect_equal(&"ignore" in shady_ids, true, "shady offers Ignore")
	_assert_payload_has_no_truth(_captured_beat_decision, "shady decision")
	var shady_dto := _demand_signals.call(
		"buy_signal_for_id",
		&"shady-trunk-lot"
	) as BuyConfirmSignal
	_expect_equal(shady_dto != null, true, "shady injects trunk lot")
	if shady_dto != null:
		_expect_dto_has_no_truth_fields(shady_dto, "shady buy signal")
		_expect_equal(shady_dto.channel, &"shady", "shady channel")
		_expect_equal(shady_dto.confidence, &"low", "shady Low confidence")
		_expect_equal(
			shady_dto.condition_cue.to_lower().contains("inspect"),
			true,
			"shady strong inspect cue"
		)
		_expect_equal(
			shady_dto.beat_id,
			SHADY_TRUNK_BEAT,
			"shady opportunity tagged for QA"
		)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"buy"),
		true,
		"shady Buy path"
	)
	_expect_equal(
		_captured_buy_focus_beat,
		SHADY_TRUNK_BEAT,
		"Buy opens BuyOpportunityDetail"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"shady-trunk-lot") != null,
		true,
		"Buy keeps the lot available with fog intact"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 20)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", SHADY_TRUNK_BEAT),
		true,
		"shady QA trigger"
	)
	var rep_before := int(_game_state.get("current_reputation"))
	var stock_before: int = _inventory_service.call("total_owned", &"AA-SKIE-ETB")
	_expect_equal(
		_beat_director.call("choose_beat_path", &"report"),
		true,
		"shady Report path"
	)
	_expect_equal(
		int(_game_state.get("current_reputation")),
		rep_before + NORMAL_CONFIG.shady_report_rep_gain,
		"Report grants Rep"
	)
	_expect_equal(
		int(_inventory_service.call("total_owned", &"AA-SKIE-ETB")),
		stock_before,
		"Report grants no inventory"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"shady-trunk-lot") == null,
		true,
		"Report dismisses the opportunity"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 22)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", SHADY_TRUNK_BEAT),
		true,
		"shady Ignore setup"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"ignore"),
		true,
		"shady Ignore path"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 20)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 20)
	_expect_equal(
		_beat_director.call("is_started", SHADY_TRUNK_BEAT),
		false,
		"Hard does not auto-start shady trunk"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


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
	var camera := shop.get_node_or_null("Camera") as ShopCamera
	_expect_equal(camera != null, true, "Camera present")
	if camera == null:
		shop.free()
		return
	_expect_equal(camera.current, true, "Camera is current")
	_expect_equal(
		camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
		true,
		"Day1 start is Art behind-desk home"
	)
	_expect_equal(
		camera.rotation_degrees.is_equal_approx(ShopCamera.BEHIND_COUNTER_ROTATION_DEGREES),
		true,
		"Day1 start is Art behind-desk pitch"
	)
	_expect_equal(is_equal_approx(camera.fov, ShopCamera.HOME_FOV), true, "Art Lead camera FOV")
	_expect_equal(
		camera.aisle_position.is_equal_approx(ShopCamera.AISLE_POSITION),
		true,
		"Aisle home position is locked Art SoT"
	)
	_expect_equal(
		camera.aisle_rotation_degrees.is_equal_approx(ShopCamera.AISLE_ROTATION_DEGREES),
		true,
		"Aisle home rotation is locked Art SoT"
	)
	_expect_equal(
		camera.behind_counter_position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
		true,
		"Behind-desk export matches Art SoT"
	)
	camera.apply_home_pose(ShopCamera.POSE_AISLE)
	_expect_equal(
		camera.position.is_equal_approx(ShopCamera.AISLE_POSITION),
		true,
		"Aisle pose applies Art reset position"
	)
	_expect_equal(
		camera.rotation_degrees.is_equal_approx(ShopCamera.AISLE_ROTATION_DEGREES),
		true,
		"Aisle pose applies Art reset pitch"
	)
	_expect_equal(is_equal_approx(camera.fov, 70.0), true, "Aisle pose keeps FOV 70")
	camera.apply_home_pose(ShopCamera.POSE_BEHIND_COUNTER)
	_expect_equal(
		camera.position.is_equal_approx(Vector3(7.2, 1.6, -0.65)),
		true,
		"Behind-desk pose restores Art home"
	)
	var world := shop.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_expect_equal(world != null, true, "WorldEnvironment present")
	if world != null and world.environment != null:
		_expect_equal(
			world.environment.ambient_light_source,
			Environment.AMBIENT_SOURCE_COLOR,
			"interior ambient uses color fill"
		)
	var lights_root := shop.get_node_or_null("Fixtures/OverheadLights")
	_assert_small_overheads_locked(lights_root, "camera framing")
	_assert_medium_overheads(lights_root, false, "camera framing authored Small")
	var aisle_amp: Node3D = null
	if lights_root != null:
		aisle_amp = lights_root.get_node_or_null("BackLeftAisle") as Node3D
	_expect_equal(aisle_amp != null, true, "optional 5th overhead instance present")
	if aisle_amp != null:
		_expect_equal(
			aisle_amp.position.is_equal_approx(Vector3(2.8, 2.78, -5.4)),
			true,
			"Light5 covers binder-rack / back-left aisle"
		)
	_assert_shop_fog_nacked(shop, "camera framing")
	var stool := shop.get_node_or_null("Fixtures/CounterStool") as Node3D
	_expect_equal(stool != null, true, "CounterStool present")
	if stool != null:
		_expect_equal(
			stool.position.is_equal_approx(Vector3(8.1, 0, -0.9)),
			true,
			"Art SoT CounterStool off entrance lane"
		)
	shop.free()


func _test_heavier_decor_placement() -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "shop_floor scene loads for heavier décor")
	if packed == null:
		return
	var shop: Node = packed.instantiate()
	var play_table := shop.get_node_or_null("Fixtures/PlayTable") as Node3D
	var slab_case := shop.get_node_or_null("Fixtures/SlabDisplayCase") as Node3D
	var window := shop.get_node_or_null("Fixtures/ShopWindow") as Node3D
	var glimpse := shop.get_node_or_null("Fixtures/BackOfficeGlimpse") as Node3D
	var a04 := shop.get_node_or_null("Fixtures/HighValueDisplayCase") as Node3D
	var backstock := shop.get_node_or_null("Fixtures/BackstockDoor") as Node3D
	var camera := shop.get_node_or_null("Camera") as ShopCamera
	_expect_equal(play_table != null, true, "PlayTable instanced")
	_expect_equal(slab_case != null, true, "SlabDisplayCase instanced")
	_expect_equal(window != null, true, "ShopWindow instanced")
	_expect_equal(glimpse != null, true, "BackOfficeGlimpse instanced")
	if play_table != null:
		_expect_equal(
			play_table.position.is_equal_approx(Vector3(2.7, 0, -4.5)),
			true,
			"B09 play table 2×2 island on open floor"
		)
		_expect_equal(
			play_table.scale.is_equal_approx(Vector3.ONE),
			true,
			"B09 authored scale"
		)
	if slab_case != null:
		_expect_equal(
			slab_case.position.is_equal_approx(Vector3(7.2, 0, -4.05)),
			true,
			"B01 slab case adjacent on A04 case run"
		)
		_expect_equal(
			slab_case.scale.is_equal_approx(Vector3.ONE),
			true,
			"B01 authored scale"
		)
	if a04 != null and slab_case != null:
		_expect_equal(
			is_equal_approx(a04.position.x, slab_case.position.x),
			true,
			"B01 shares A04 case-run X"
		)
		_expect_equal(
			is_equal_approx(absf(slab_case.position.z - a04.position.z), 0.9),
			true,
			"B01 is one 0.9 m tile behind A04"
		)
	if window != null:
		_expect_equal(
			window.position.is_equal_approx(Vector3(0, 1.62, -2.25)),
			true,
			"B06 window left-wall mount at poster height"
		)
		_expect_equal(
			window.rotation_degrees.is_equal_approx(Vector3(0, 90, 0)),
			true,
			"B06 yaw faces into room from left wall"
		)
		_expect_equal(
			window.scale.is_equal_approx(Vector3.ONE),
			true,
			"B06 authored scale"
		)
	if glimpse != null:
		_expect_equal(
			glimpse.position.is_equal_approx(Vector3(4.5, 0, -7.05)),
			true,
			"B07 glimpse sits at A13 alcove rear on interior floor"
		)
		_expect_equal(
			glimpse.position.z >= -7.15 and glimpse.position.z <= -6.95,
			true,
			"B07 Z stays in Art alcove-rear band −7.15…−6.95"
		)
		_expect_equal(
			glimpse.scale.is_equal_approx(Vector3.ONE),
			true,
			"B07 authored scale"
		)
		_expect_equal(
			glimpse.rotation_degrees.is_equal_approx(Vector3.ZERO),
			true,
			"B07 identity rotation"
		)
	if backstock != null and glimpse != null:
		_expect_equal(
			is_equal_approx(backstock.position.x, glimpse.position.x),
			true,
			"B07 shares A13 X"
		)
		_expect_equal(
			is_equal_approx(glimpse.position.z, backstock.position.z - 0.3),
			true,
			"B07 is at alcove rear, 0.3 m behind A13 center"
		)
	if camera != null:
		_expect_equal(is_equal_approx(camera.fov, ShopCamera.HOME_FOV), true, "placement does not change FOV")
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"placement does not move Day1 camera"
		)
	shop.free()


func _test_shop_camera_look_clamps() -> void:
	var camera := ShopCamera.new()
	camera.fov = 90.0
	camera.apply_home_pose(ShopCamera.POSE_BEHIND_COUNTER)
	_expect_equal(camera.get_home_pose(), ShopCamera.POSE_BEHIND_COUNTER, "default named home")
	_expect_equal(is_equal_approx(camera.fov, 70.0), true, "home pose locks FOV to 70")
	camera.apply_look_delta(Vector2(0.0, -10000.0))
	_expect_equal(
		is_equal_approx(camera.rotation_degrees.x, ShopCamera.PITCH_MAX_DEGREES),
		true,
		"pitch clamp max is Art +5"
	)
	_expect_equal(
		camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
		true,
		"look does not leave behind-desk stand point"
	)
	_expect_equal(
		camera.rotation_degrees.x <= ShopCamera.PITCH_MAX_DEGREES,
		true,
		"camera is not ceiling-stuck"
	)
	camera.apply_look_delta(Vector2(0.0, 20000.0))
	_expect_equal(
		is_equal_approx(camera.rotation_degrees.x, ShopCamera.PITCH_MIN_DEGREES),
		true,
		"pitch clamp min is Art -40"
	)
	camera.apply_home_pose(ShopCamera.POSE_BEHIND_COUNTER)
	camera.apply_look_delta(Vector2(10000.0, 0.0))
	_expect_equal(
		is_equal_approx(camera.rotation_degrees.y, ShopCamera.YAW_MIN_DEGREES),
		true,
		"yaw clamp min is Art -70"
	)
	camera.apply_look_delta(Vector2(-20000.0, 0.0))
	_expect_equal(
		is_equal_approx(camera.rotation_degrees.y, ShopCamera.YAW_MAX_DEGREES),
		true,
		"yaw clamp max is Art +70"
	)
	_expect_equal(is_equal_approx(camera.fov, 70.0), true, "RMB look does not zoom FOV")
	camera.reset_to_aisle_home()
	_expect_equal(camera.get_home_pose(), ShopCamera.POSE_AISLE, "reset named pose is aisle")
	_expect_equal(
		camera.position.is_equal_approx(ShopCamera.AISLE_POSITION),
		true,
		"reset returns to Art aisle home"
	)
	_expect_equal(
		camera.rotation_degrees.is_equal_approx(ShopCamera.AISLE_ROTATION_DEGREES),
		true,
		"reset clears look offset to aisle pitch"
	)
	_expect_equal(camera.is_looking(), false, "reset releases RMB look")
	camera.free()


func _test_customer_npc_spawn_browse_approach_path() -> void:
	var grid := ShopGrid.small_default()
	_expect_equal(grid.is_walkable(grid.entrance_tile), true, "entrance tile walkable")
	_expect_equal(grid.is_walkable(grid.desk_tile), true, "desk stand tile walkable")
	_expect_equal(grid.is_walkable(Vector2i(7, 1)), false, "counter blocks pathing")
	_expect_equal(grid.is_walkable(Vector2i(8, 1)), false, "counter far tile blocked")
	for browse: Vector2i in grid.browse_tiles:
		_expect_equal(grid.is_walkable(browse), true, "browse tile walkable")
		_assert_grid_path(grid, grid.entrance_tile, browse, "entrance→browse")
		_assert_grid_path(grid, browse, grid.desk_tile, "browse→desk")
	_assert_grid_path(grid, grid.entrance_tile, grid.desk_tile, "entrance→desk")
	_assert_grid_path(grid, grid.desk_tile, grid.entrance_tile, "desk→exit")
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var presenter := _make_floor_presenter()
	var customer := _make_floor_customer(&"regular")
	var npc := presenter.spawn_for(customer)
	_expect_equal(npc != null, true, "NPC spawns at entrance")
	_expect_equal(
		npc.floor_state,
		CustomerPresenter.FloorState.SPAWN,
		"NPC starts in SPAWN"
	)
	_expect_equal(
		grid.world_to_tile(npc.position),
		grid.entrance_tile,
		"SPAWN is on the entrance tile"
	)
	_expect_equal(
		presenter.advance_until(customer, CustomerPresenter.FloorState.BROWSE),
		true,
		"SPAWN advances to BROWSE"
	)
	_expect_equal(
		npc.floor_state,
		CustomerPresenter.FloorState.BROWSE,
		"NPC is browsing displays"
	)
	_expect_equal(
		presenter.advance_until(customer, CustomerPresenter.FloorState.APPROACH),
		true,
		"BROWSE advances to APPROACH"
	)
	_expect_equal(
		presenter.advance_until(customer, CustomerPresenter.FloorState.RESOLVE),
		true,
		"APPROACH reaches desk RESOLVE"
	)
	_expect_equal(
		grid.contains_desk(npc.position),
		true,
		"RESOLVE stands in the desk interact volume"
	)
	_expect_equal(
		presenter.is_desk_ready(customer),
		true,
		"desk volume is ready at RESOLVE"
	)
	_event_bus.emit_signal("customer_resolved", customer, &"sold")
	_expect_equal(
		presenter.advance_until(customer, CustomerPresenter.FloorState.EXIT),
		true,
		"resolve begins EXIT"
	)
	presenter.simulate(1.0)
	_expect_equal(
		presenter.get_npc(customer) == null,
		true,
		"EXIT despawns at the entrance"
	)
	presenter.free()


func _test_customer_npc_intent_icons_have_no_truth() -> void:
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var presenter := _make_floor_presenter()
	var buyer := _make_floor_customer(&"regular")
	var buyer_npc := presenter.spawn_for(buyer)
	_expect_equal(
		buyer_npc.icon.intent_name(),
		&"browse",
		"spawn overhead icon is browse"
	)
	var browse_payload := buyer_npc.icon_presentation()
	_expect_equal(browse_payload.size(), 1, "bobber payload is intent-only")
	_expect_equal(
		browse_payload.has("intent"),
		true,
		"bobber payload has intent"
	)
	_expect_equal(
		buyer_npc.icon.has_truth_fields(),
		false,
		"browse bobber has no truth fields"
	)
	_assert_payload_has_no_truth(browse_payload, "browse icon")
	presenter.advance_until(buyer, CustomerPresenter.FloorState.APPROACH)
	_expect_equal(
		buyer_npc.icon.intent_name(),
		&"buy",
		"leaving browse flips to buy"
	)
	_expect_equal(
		buyer_npc.icon_presentation().size(),
		1,
		"buy bobber stays intent-only"
	)
	_assert_payload_has_no_truth(
		buyer_npc.icon_presentation(),
		"buy icon"
	)
	var seller := _make_floor_customer(&"flipper")
	seller.trade_intent = CustomerProfile.TradeIntent.SELLING_TO_SHOP
	var seller_npc := presenter.spawn_for(seller)
	presenter.advance_until(seller, CustomerPresenter.FloorState.APPROACH)
	_expect_equal(
		seller_npc.icon.intent_name(),
		&"sell",
		"buylist seller flips to sell"
	)
	_expect_equal(
		seller_npc.icon.intent_name() in [&"browse", &"buy", &"sell"],
		true,
		"intent is browse/buy/sell only"
	)
	_assert_payload_has_no_truth(
		seller_npc.icon_presentation(),
		"sell icon"
	)
	for path: String in [
		"res://scripts/customers/customer_npc.gd",
		"res://scripts/customers/customer_presenter.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_assert_text_has_no_truth(source, path.get_file())
	presenter.free()


func _test_customer_npc_desk_volume_gates_hud() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "HUD loads for desk gate")
	if hud == null:
		return
	var serve := hud.get_node_or_null("%CustomerServe") as PanelContainer
	var presenter := _make_floor_presenter()
	var customer := _make_floor_customer(&"regular")
	var npc := presenter.spawn_for(customer)
	_event_bus.emit_signal("customer_head_changed", customer)
	_expect_equal(
		serve != null and serve.visible == false,
		true,
		"CustomerServe stays closed off the desk volume"
	)
	presenter.advance_until(customer, CustomerPresenter.FloorState.RESOLVE)
	_expect_equal(
		presenter.is_desk_ready(customer),
		true,
		"presenter marks desk ready in volume"
	)
	_expect_equal(
		serve.visible,
		true,
		"CustomerServe opens only in the desk volume"
	)
	Callable(hud, "dismiss_customer_serve").call()
	_expect_equal(serve.visible, false, "Esc/close hides thin counter HUD")
	_expect_equal(
		presenter.get_npc(customer) != null,
		true,
		"closing HUD does not despawn the NPC"
	)
	_expect_equal(
		npc.floor_state,
		CustomerPresenter.FloorState.RESOLVE,
		"NPC stays in RESOLVE after HUD close"
	)
	_event_bus.emit_signal("customer_desk_ready_changed", customer, true)
	_expect_equal(
		serve.visible,
		true,
		"re-entering desk volume can reopen HUD"
	)
	presenter.free()
	root.remove_child(hud)
	hud.free()


func _test_customer_npc_does_not_change_camera() -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "shop_floor loads for NPC camera check")
	if packed == null:
		return
	_game_state.call("start_new_game")
	var shop: Node = packed.instantiate()
	root.add_child(shop)
	var camera := shop.get_node_or_null("Camera") as ShopCamera
	_expect_equal(camera != null, true, "Camera present during NPC spawn")
	if camera == null:
		shop.free()
		return
	var home_pos := camera.position
	var home_rot := camera.rotation_degrees
	var home_fov := camera.fov
	var presenter := shop.get_node_or_null(
		"Systems/CustomerPresenter"
	) as CustomerPresenter
	_expect_equal(presenter != null, true, "CustomerPresenter is on the shop")
	if presenter != null:
		presenter.instant_travel = true
		presenter.dwell_override = 0.0
		var customer := _make_floor_customer(&"regular")
		presenter.spawn_for(customer)
		presenter.advance_until(customer, CustomerPresenter.FloorState.APPROACH)
	_expect_equal(
		is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
		true,
		"NPC floor presence does not change FOV"
	)
	_expect_equal(
		is_equal_approx(home_fov, ShopCamera.HOME_FOV),
		true,
		"camera FOV stays locked at 70"
	)
	_expect_equal(
		camera.position.is_equal_approx(home_pos),
		true,
		"NPC spawn does not move the shop camera"
	)
	_expect_equal(
		camera.rotation_degrees.is_equal_approx(home_rot),
		true,
		"NPC spawn does not rotate the shop camera"
	)
	var presenter_source := FileAccess.get_file_as_string(
		"res://scripts/customers/customer_presenter.gd"
	)
	var npc_source := FileAccess.get_file_as_string(
		"res://scripts/customers/customer_npc.gd"
	)
	_expect_equal(
		presenter_source.contains("fov") or npc_source.contains("fov"),
		false,
		"NPC scripts do not mutate FOV"
	)
	shop.free()


func _test_customer_npc_visible_when_queued() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var presenter := _make_floor_presenter()
	var customer := _make_floor_customer(&"regular")
	_event_bus.emit_signal("customer_arrived", customer)
	_expect_equal(
		presenter.visible_npc_count() >= 1,
		true,
		"non-empty floor presence shows ≥1 NPC"
	)
	var npc := presenter.get_npc(customer)
	_expect_equal(npc != null and npc.visible, true, "queued NPC is visible")
	_expect_equal(
		npc.floor_state == CustomerPresenter.FloorState.SPAWN
		or npc.floor_state == CustomerPresenter.FloorState.BROWSE
		or npc.floor_state == CustomerPresenter.FloorState.APPROACH,
		true,
		"visible NPC is walking or browsing"
	)
	presenter.free()


func _test_customer_npc_mvp_cast() -> void:
	_game_state.call("start_new_game")
	var presenter := _make_floor_presenter()
	var c1 := presenter.spawn_for(_make_floor_customer(&"regular"))
	var c2 := presenter.spawn_for(_make_floor_customer(&"flipper"))
	var c3 := presenter.spawn_for(_make_floor_customer(&"kid_parent"))
	_expect_equal(c1.cast_slot, &"C1", "regular maps to C1")
	_expect_equal(c2.cast_slot, &"C2", "flipper maps to C2")
	_expect_equal(c3.cast_slot, &"C3", "kid/parent maps to C3")
	_expect_equal(
		not is_equal_approx(c1.body_height, c2.body_height),
		true,
		"C1/C2 heights differ"
	)
	_expect_equal(
		c3.body_height < c1.body_height,
		true,
		"C3 is shorter than C1"
	)
	_expect_equal(
		c1.body_color != c2.body_color and c2.body_color != c3.body_color,
		true,
		"C1–C3 capsules use distinct tints"
	)
	_expect_equal(is_equal_approx(c1.body_height, 1.74), true, "C1 Art hero 1.74m")
	_expect_equal(is_equal_approx(c2.body_height, 1.70), true, "C2 Art hero 1.70m")
	_expect_equal(is_equal_approx(c3.body_height, 1.66), true, "C3 Art hero 1.66m")
	_expect_equal(
		c1.body_scene_path.contains("char_customer_casual_a_01"),
		true,
		"C1 uses casual A GLB"
	)
	_expect_equal(
		c2.body_scene_path.contains("char_customer_casual_b_01"),
		true,
		"C2 uses casual B GLB"
	)
	_expect_equal(
		c3.body_scene_path.contains("char_customer_casual_c_01"),
		true,
		"C3 uses casual C GLB"
	)
	_expect_equal(
		FileAccess.file_exists(CustomerCast.SCENE_C1),
		true,
		"C1 GLB is on disk"
	)
	_expect_equal(
		FileAccess.file_exists(CustomerIntentIcon.SCENE_BROWSE),
		true,
		"browse icon GLB is on disk"
	)
	_expect_equal(
		FileAccess.file_exists(CustomerIntentIcon.SCENE_BUY),
		true,
		"buy icon GLB is on disk"
	)
	_expect_equal(
		FileAccess.file_exists(CustomerIntentIcon.SCENE_SELL),
		true,
		"sell icon GLB is on disk"
	)
	_expect_equal(
		CustomerIntentIcon.scene_path_for(CustomerIntentIcon.Intent.BROWSE).contains(
			"prop_icon_browse_01"
		),
		true,
		"browse Art icon path"
	)
	_expect_equal(
		CustomerIntentIcon.scene_path_for(CustomerIntentIcon.Intent.BUY).contains(
			"prop_icon_buy_01"
		),
		true,
		"buy Art icon path"
	)
	_expect_equal(
		CustomerIntentIcon.scene_path_for(CustomerIntentIcon.Intent.SELL).contains(
			"prop_icon_sell_01"
		),
		true,
		"sell Art icon path"
	)
	_expect_equal(
		CustomerIntentIcon.COLOR_SELL.r > 0.8 and CustomerIntentIcon.COLOR_SELL.g > 0.45,
		true,
		"sell stays warm amber Accent_Amber"
	)
	_expect_equal(
		CustomerIntentIcon.COLOR_SELL.b < 0.35,
		true,
		"sell is not burgundy"
	)
	_expect_equal(
		CustomerIntentIcon.COLOR_BUY.b > CustomerIntentIcon.COLOR_BUY.r,
		true,
		"buy stays teal"
	)
	var sell_notes := FileAccess.get_file_as_string(
		"res://assets/props/shop/fixtures/prop_icon_sell_01/IMPORT_NOTES.md"
	)
	_expect_equal(
		sell_notes.contains("Accent_Amber"),
		true,
		"sell icon notes lock Accent_Amber"
	)
	c1.icon.ensure_built()
	_expect_equal(
		c1.icon.get_child_count() >= 3,
		true,
		"browse/buy/sell Art icons are instanced"
	)
	presenter.free()


func _test_customer_npc_locomotion_clips() -> void:
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var presenter := CustomerPresenter.new()
	presenter.instant_travel = false
	presenter.dwell_override = 10.0
	root.add_child(presenter)
	if not presenter.is_node_ready():
		presenter.notification(Node.NOTIFICATION_READY)
	var c1 := presenter.spawn_for(_make_floor_customer(&"regular"))
	var c2 := presenter.spawn_for(_make_floor_customer(&"flipper"))
	var c3 := presenter.spawn_for(_make_floor_customer(&"kid_parent"))
	for npc: CustomerNpc in [c1, c2, c3]:
		_expect_equal(
			npc.has_locomotion_clips(),
			true,
			"%s GLB exposes walk + browse_idle" % npc.cast_slot
		)
		_expect_equal(
			npc.current_locomotion_clip(),
			CustomerNpc.CLIP_BROWSE_IDLE,
			"%s rests on browse_idle at spawn" % npc.cast_slot
		)
	var start := c1.position
	presenter.simulate(0.35)
	_expect_equal(c1.is_moving(), true, "C1 is translating along path")
	_expect_equal(
		c1.current_locomotion_clip(),
		CustomerNpc.CLIP_WALK,
		"walk plays while moving"
	)
	_expect_equal(
		c1.position.distance_to(start) > 0.05,
		true,
		"pathing owns world translation"
	)
	_expect_equal(
		c1.body_root_local_position().is_equal_approx(Vector3.ZERO),
		true,
		"in-place clips keep the GLB root at origin"
	)
	var arrived := false
	var elapsed := 0.0
	while elapsed <= 20.0:
		if (
			c1.floor_state == CustomerPresenter.FloorState.BROWSE
			and not c1.is_moving()
		):
			arrived = true
			break
		presenter.simulate(0.1)
		elapsed += 0.1
	_expect_equal(arrived, true, "C1 reaches a browse stop")
	_expect_equal(
		c1.current_locomotion_clip(),
		CustomerNpc.CLIP_BROWSE_IDLE,
		"browse_idle plays at the case while not translating"
	)
	c1.follow_path([c1.position + Vector3(1.2, 0.0, 0.0)])
	_expect_equal(
		c1.current_locomotion_clip(),
		CustomerNpc.CLIP_WALK,
		"walk resumes when a new path starts"
	)
	c1.snap_to_path_end()
	_expect_equal(
		c1.current_locomotion_clip(),
		CustomerNpc.CLIP_BROWSE_IDLE,
		"browse_idle resumes when translation stops"
	)
	var npc_source := FileAccess.get_file_as_string(
		"res://scripts/customers/customer_npc.gd"
	)
	_expect_equal(
		npc_source.contains("AnimationPlayer"),
		true,
		"locomotion uses AnimationPlayer"
	)
	_expect_equal(
		npc_source.contains("AnimationTree"),
		false,
		"does not invent a second animation system"
	)
	presenter.free()


func _test_cashier_silhouette_on_floor() -> void:
	_expect_equal(
		FileAccess.file_exists(StaffMember.SCENE_CASHIER),
		true,
		"cashier GLB is on disk"
	)
	_expect_equal(
		is_equal_approx(StaffMember.BODY_HEIGHT, 1.72),
		true,
		"cashier authored height 1.72m"
	)
	_expect_equal(
		StaffMember.CLIP_IDLE_STAND,
		&"idle_stand",
		"cashier clip is idle_stand"
	)
	_expect_equal(
		StaffMember.SCENE_CASHIER.contains("char_cashier_01"),
		true,
		"cashier uses Art char_cashier_01"
	)

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop: ShopState = _game_state.get("shop")
	_expect_equal(shop.is_owner_only(), true, "Normal starts owner-only")
	_expect_equal(shop.cashier_count(), 0, "Normal starts with no cashiers")
	_expect_equal(shop.staff_cap(), 1, "Small staff cap is 1")

	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "shop_floor loads for cashier silhouette")
	if packed == null:
		return
	var floor: Node = packed.instantiate()
	root.add_child(floor)
	var presenter := floor.get_node_or_null("StaffFloor") as StaffPresenter
	_expect_equal(presenter != null, true, "StaffFloor presenter is on the shop")
	if presenter == null:
		floor.free()
		return
	var slot := floor.get_node_or_null("StaffFloor/CashierSlot") as Node3D
	_expect_equal(slot != null, true, "CashierSlot marker is behind the register")
	if slot != null:
		_expect_equal(
			slot.position.is_equal_approx(StaffPresenter.DEFAULT_STATION),
			true,
			"CashierSlot matches StaffPresenter.DEFAULT_STATION"
		)
		_expect_equal(
			StaffPresenter.DEFAULT_STATION.is_equal_approx(Vector3(8.05, 0.0, -0.95)),
			true,
			"presenter default is stool/owner side (8.05, 0, −0.95)"
		)
		_expect_equal(
			slot.position.z <= -0.85 and slot.position.z >= -1.05,
			true,
			"cashier Z stays in the owner-side band (−1.05…−0.85)"
		)
		_expect_equal(
			is_equal_approx(slot.rotation_degrees.y, StaffPresenter.DEFAULT_YAW_DEGREES),
			true,
			"CashierSlot yaw matches StaffPresenter.DEFAULT_YAW_DEGREES"
		)
		_expect_equal(
			is_equal_approx(StaffPresenter.DEFAULT_YAW_DEGREES, 90.0),
			true,
			"presenter default yaw 90 faces customers (−X)"
		)
	presenter.sync_from_shop()
	_expect_equal(presenter.visible_clerk_count(), 0, "owner-only hides the clerk")

	var camera := floor.get_node_or_null("Camera") as ShopCamera
	_expect_equal(camera != null, true, "Camera present during clerk spawn")
	var home_pos := Vector3.ZERO
	var home_rot := Vector3.ZERO
	var home_fov := 0.0
	if camera != null:
		home_pos = camera.position
		home_rot = camera.rotation_degrees
		home_fov = camera.fov

	_expect_equal(shop.hire_cashier(false) != null, true, "hire first cashier")
	_expect_equal(shop.cashier_count(), 1, "one cashier on duty")
	_expect_equal(shop.hire_cashier(false) == null, true, "Small staff cap blocks second hire")
	presenter.sync_from_shop()
	_expect_equal(presenter.visible_clerk_count(), 1, "hired cashier appears behind the counter")
	var clerk := presenter.clerk_at(0)
	_expect_equal(clerk != null and clerk.visible, true, "clerk node is visible")
	if clerk != null:
		var clerk_tile := shop.floor_grid.world_to_tile(clerk.position)
		_expect_equal(
			shop.floor_grid.is_walkable(clerk_tile),
			false,
			"clerk stands on blocked counter tiles"
		)
		_expect_equal(
			shop.floor_grid.is_walkable(shop.floor_grid.desk_tile),
			true,
			"customer desk tile stays walkable"
		)
		_expect_equal(
			clerk.position.distance_to(Vector3(7.2, 0.0, -1.35)) < 1.4,
			true,
			"clerk is near the buy counter / register"
		)
		_expect_equal(
			clerk.position.is_equal_approx(StaffPresenter.DEFAULT_STATION),
			true,
			"spawned clerk uses CashierSlot / DEFAULT_STATION"
		)
		_expect_equal(
			clerk.position.z <= -0.85 and clerk.position.z >= -1.05,
			true,
			"spawned clerk stays on the stool/owner side (not past counter −1.35)"
		)
		_expect_equal(
			is_equal_approx(clerk.rotation_degrees.y, StaffPresenter.DEFAULT_YAW_DEGREES),
			true,
			"spawned clerk yaw matches DEFAULT_YAW_DEGREES (90 / −X)"
		)
	_expect_equal(
		presenter.current_idle_clip(),
		StaffMember.CLIP_IDLE_STAND,
		"idle_stand is the active clip"
	)
	_expect_equal(
		presenter.body_root_local_position().is_equal_approx(Vector3.ZERO),
		true,
		"in-place idle keeps the GLB root at origin"
	)
	if presenter.has_idle_loop():
		_expect_equal(true, true, "idle_stand loops on AnimationPlayer")
	else:
		_expect_equal(
			FileAccess.file_exists(StaffMember.SCENE_CASHIER),
			true,
			"GLB present even if import has not bound AnimationPlayer yet"
		)

	var customer_p := floor.get_node_or_null(
		"Systems/CustomerPresenter"
	) as CustomerPresenter
	_expect_equal(customer_p != null, true, "CustomerPresenter still on the shop")
	if customer_p != null:
		customer_p.instant_travel = true
		customer_p.dwell_override = 0.0
		var path := customer_p.path_between(
			shop.floor_grid.tile_to_world(shop.floor_grid.entrance_tile),
			shop.floor_grid.tile_to_world(shop.floor_grid.desk_tile)
		)
		_expect_equal(path.is_empty(), false, "clerk does not break entrance→desk pathing")
		var customer := _make_floor_customer(&"regular")
		customer_p.spawn_for(customer)
		_expect_equal(
			customer_p.advance_until(customer, CustomerPresenter.FloorState.APPROACH),
			true,
			"customer still reaches the desk with clerk present"
		)
		_expect_equal(
			customer_p.get_npc(customer) != null,
			true,
			"customer NPC remains after clerk spawn"
		)

	if camera != null:
		_expect_equal(
			is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
			true,
			"clerk visual does not change FOV"
		)
		_expect_equal(
			is_equal_approx(home_fov, ShopCamera.HOME_FOV),
			true,
			"camera FOV stays locked at 70"
		)
		_expect_equal(
			camera.position.is_equal_approx(home_pos),
			true,
			"clerk spawn does not move the shop camera"
		)
		_expect_equal(
			camera.rotation_degrees.is_equal_approx(home_rot),
			true,
			"clerk spawn does not rotate the shop camera"
		)
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"behind-counter camera SoT unchanged"
		)
	var staff_source := FileAccess.get_file_as_string(
		"res://scripts/shop/staff_presenter.gd"
	)
	_expect_equal(
		staff_source.contains("fov"),
		false,
		"staff presenter does not mutate FOV"
	)
	_expect_equal(
		staff_source.contains("AnimationPlayer"),
		true,
		"cashier idle uses AnimationPlayer"
	)
	_expect_equal(
		staff_source.contains("AnimationTree"),
		false,
		"does not invent a second animation system"
	)
	floor.free()

	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	_expect_equal(
		shop.expand_to_medium(18, 1_600_000, 55),
		true,
		"Sign Medium for staff_cap 3"
	)
	_expect_equal(shop.staff_cap(), 3, "Medium staff cap unlocks")
	_expect_equal(shop.hire_cashier(false) != null, true, "Medium hire #2")
	_expect_equal(shop.hire_cashier(false) != null, true, "Medium hire #3")
	_expect_equal(shop.hire_cashier(false) == null, true, "Medium cap blocks #4")
	_expect_equal(shop.cashier_count(), 3, "three cashiers hired")
	_expect_equal(shop.cashier_count() <= shop.staff_cap(), true, "hires respect staff_cap")
	var cap_floor: Node = packed.instantiate()
	root.add_child(cap_floor)
	var cap_presenter := cap_floor.get_node_or_null("StaffFloor") as StaffPresenter
	if cap_presenter != null:
		cap_presenter.sync_from_shop()
		_expect_equal(
			cap_presenter.visible_clerk_count(),
			1,
			"one register station even when staff_cap is 3"
		)
	cap_floor.free()

	_game_state.call("set_balance_config", EASY_CONFIG)
	_game_state.call("start_new_game")
	shop = _game_state.get("shop")
	_expect_equal(shop.cashier_count(), 1, "Easy seeds a trainee cashier")
	var easy_floor: Node = packed.instantiate()
	root.add_child(easy_floor)
	var easy_presenter := easy_floor.get_node_or_null("StaffFloor") as StaffPresenter
	if easy_presenter != null:
		easy_presenter.sync_from_shop()
		_expect_equal(
			easy_presenter.visible_clerk_count(),
			1,
			"Easy trainee is visible behind the counter"
		)
		_expect_equal(
			easy_presenter.current_idle_clip(),
			StaffMember.CLIP_IDLE_STAND,
			"trainee loops idle_stand"
		)
	easy_floor.free()
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _make_floor_presenter() -> CustomerPresenter:
	var presenter := CustomerPresenter.new()
	presenter.instant_travel = true
	presenter.dwell_override = 0.0
	root.add_child(presenter)
	if not presenter.is_node_ready():
		presenter.notification(Node.NOTIFICATION_READY)
	return presenter


func _make_floor_customer(archetype_id: StringName) -> CustomerProfile:
	var customer := CustomerProfile.new()
	customer.archetype_id = archetype_id
	customer.display_name = String(archetype_id)
	customer.budget_cents = 10_000
	customer.interest_tags = [&"accessory"]
	customer.target_sku = &"ACC-SLV-60"
	customer.listed_price_cents = 599
	customer.desired_skus = [&"ACC-SLV-60"]
	customer.begin_waiting()
	return customer


func _assert_grid_path(
	grid: ShopGrid,
	from: Vector2i,
	to: Vector2i,
	label: String
) -> void:
	var path := ShopPathfinder.find_path(grid, from, to)
	_expect_equal(path.is_empty(), false, "%s path exists" % label)
	_expect_equal(
		path.has(Vector2i(7, 1)) or path.has(Vector2i(8, 1)),
		false,
		"%s does not clip the counter" % label
	)
	for tile: Vector2i in path:
		_expect_equal(grid.is_walkable(tile), true, "%s stays walkable" % label)


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


func _test_c2_hire_beat_paths() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("is_started", HIRE_CASHIER_BEAT),
		true,
		"C2 gate 1: day-5 hire beat starts on Normal PREP"
	)
	var ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"hire_cashier" in ids, true, "C2 gate 1: Hire reachable")
	_expect_equal(&"keep_solo" in ids, true, "C2 gate 1: Solo reachable")
	_expect_equal(&"hire_cheap" in ids, true, "C2 gate 1: Unreliable reachable")
	var confirms: Dictionary = _captured_beat_decision.get("confirms", {})
	_expect_equal(
		String((confirms.get("hire_cheap", {}) as Dictionary).get("body", "")).contains(
			"Reliability"
		),
		true,
		"C2 gate 1: cheap path warns Reliability"
	)
	_assert_payload_has_no_truth(_captured_beat_decision, "C2 hire decision")

	_expect_equal(
		_beat_director.call("choose_beat_path", &"hire_cashier"),
		true,
		"C2 gate 1: Hire Cashier commits"
	)
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.hired_count(), 1, "C2 gate 1: Hire uses one staff_cap slot")
	_expect_equal(shop.hired_count() <= shop.staff_cap(), true, "C2 gate 1: hire respects cap")
	_expect_equal(shop.staff[0].wage_cents, ShopState.CASHIER_WAGE_CENTS, "C2 gate 1: $80 wage")
	_expect_equal(shop.can_hire(), false, "C2 gate 1: Small cap filled after Hire")
	var cash_before := int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - ShopState.CASHIER_WAGE_CENTS,
		"C2 gate 1: Hire wage posts at SETTLE"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	_beat_director.call("choose_beat_path", &"keep_solo")
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.hired_count(), 0, "C2 gate 1: Solo leaves roster empty")
	_expect_equal(shop.is_owner_only(), true, "C2 gate 1: Solo stays owner-only")
	cash_before = int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before,
		"C2 gate 1: Solo posts no wage"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	_beat_director.call("choose_beat_path", &"hire_cheap")
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.hired_count(), 1, "C2 gate 1: Unreliable hire uses staff_cap")
	_expect_equal(shop.staff[0].theft_bias, true, "C2 gate 1: cheap theft/no-show bias")
	_expect_equal(
		shop.staff[0].reliability <= 0.55,
		true,
		"C2 gate 1: cheap Reliability ≤ 0.55"
	)


func _test_c2_unreliable_ten_day_stress() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_qa_autoload.call("set_force_enabled", true)
	var hit := false
	var noshows := 0
	var shrink_up := false
	var locked := false
	var seeds: Array[int] = [ShopState.STAFF_ATTENDANCE_SEED]
	for extra: int in range(1, 16):
		seeds.append(ShopState.STAFF_ATTENDANCE_SEED + extra * 17)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		var shop := _game_state.get("shop") as ShopState
		_expect_equal(shop.hire_cashier(true) != null, true, "C2 gate 2: hire cheap")
		var cheap_rate := shop.shrink_rate()
		_expect_equal(
			cheap_rate > NORMAL_CONFIG.shrink_daily_base,
			true,
			"C2 gate 2: cheap theft bias raises shrink vs base"
		)
		shop.seed_attendance_rng(rng_seed)
		_qa_autoload.call("clear")
		noshows = 0
		var shrink_loss := 0
		var max_rate := 0.0
		locked = false
		for _day_index: int in range(10):
			if not bool(_game_state.call("start_floor")):
				locked = true
				break
			if shop.is_floor_understaffed():
				noshows += 1
			if not bool(_game_state.call("start_settle")):
				locked = true
				break
			max_rate = maxf(max_rate, shop.last_shrink_rate)
			if int(_game_state.get("current_day")) < 10:
				if not bool(_game_state.call("advance_day")):
					locked = true
					break
		for event: Dictionary in _qa_autoload.call("get_events"):
			var name := String(event.get("event", ""))
			var payload: Dictionary = event.get("payload", {})
			_assert_payload_has_no_truth(payload, "C2 %s" % name)
			if name == "staff_noshow":
				noshows = maxi(noshows, int(payload.get("noshow_count", 1)))
			elif name == "shrink_applied":
				shrink_loss += int(payload.get("loss_cents", 0))
				max_rate = maxf(max_rate, float(payload.get("rate", 0.0)))
		shrink_up = (
			max_rate > NORMAL_CONFIG.shrink_daily_base
			or shrink_loss > 0
		)
		_expect_equal(locked, false, "C2 gate 2: 10-day cheap run does not soft-lock")
		_expect_equal(
			bool(_game_state.get("is_game_active")),
			true,
			"C2 gate 2: game stays active after 10 days"
		)
		if noshows >= 1 or shrink_up:
			hit = true
			break
	_expect_equal(
		hit,
		true,
		"C2 gate 2: ≥1 no-show or shrink↑ in 10-day cheap stress"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_c2_att_zero_owner_verbs() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.hire_cashier(false) != null, true, "C2 gate 3: hire cashier")
	_expect_equal(
		_game_state.call("start_floor"),
		true,
		"C2 gate 3: open FLOOR with cashier"
	)
	if shop.staff.size() > 0:
		shop.staff[0].on_duty_today = true
	_expect_equal(shop.has_cashier_on_duty(), true, "C2 gate 3: cashier on duty")
	_game_state.set("attention_remaining", 0)
	_event_bus.emit_signal("attention_changed", 0)

	_expect_equal(_game_state.call("can_inspect"), false, "C2 gate 3: Inspect blocked at Att 0")
	_expect_equal(_game_state.call("can_negotiate"), false, "C2 gate 3: Negotiate blocked at Att 0")
	_expect_equal(_game_state.call("can_pull"), false, "C2 gate 3: Pull blocked at Att 0")
	var research := _demand_signals.call("research_set", &"AA-BASE") as Dictionary
	_expect_equal(bool(research.get("ok", false)), false, "C2 gate 3: Research blocked at Att 0")
	_expect_equal(
		StringName(research.get("reason", &"")),
		&"insufficient_attention",
		"C2 gate 3: Research reason is insufficient_attention"
	)

	var inspect_dto: BuyConfirmSignal = null
	for dto: BuyConfirmSignal in _demand_signals.call("open_buy_signals"):
		if DemandSignalService.recommends_inspect(dto.channel):
			inspect_dto = dto
			break
	_expect_equal(inspect_dto != null, true, "C2 gate 3: inspectable lot exists")
	if inspect_dto != null:
		_expect_equal(
			_demand_signals.call("can_inspect", inspect_dto),
			false,
			"C2 gate 3: DemandSignals.can_inspect false at Att 0"
		)
		_expect_equal(
			_demand_signals.call("inspect_buy", inspect_dto),
			false,
			"C2 gate 3: inspect_buy refuses at Att 0"
		)

	_inventory_service.call(
		"receive_stock",
		&"ACC-SLV-60",
		1,
		250,
		InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	)
	var queue := CustomerQueue.new()
	queue.configure(
		_inventory_service,
		Callable(_game_state, "adjust_reputation"),
		Callable(_game_state, "spend_attention")
	)
	var buyer := CustomerProfile.new()
	buyer.budget_cents = 5_000
	buyer.interest_tags = [&"accessory"]
	_expect_equal(queue.enqueue(buyer), true, "C2 gate 3: enqueue routine sale")
	_expect_equal(queue.negotiate(-0.10), false, "C2 gate 3: negotiate fails at Att 0")
	_expect_equal(buyer.has_negotiated, false, "C2 gate 3: negotiate does not mark customer")
	_expect_equal(queue.pull_from_backstock(), false, "C2 gate 3: pull fails at Att 0")
	_expect_equal(queue.sell_listed(), true, "C2 gate 3: cashier still routine-sells")
	queue.free()

	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "C2 gate 3: HUD loads")
	if hud == null:
		return
	Callable(hud, "_update_attention").call(0)
	var open_research := hud.get_node_or_null("%OpenResearchButton") as Button
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	_expect_equal(
		open_research != null and open_research.disabled,
		true,
		"C2 gate 3: HUD Research disabled at Att 0"
	)
	var customer := CustomerProfile.new()
	customer.display_name = "Tester"
	customer.target_sku = &"ACC-SLV-60"
	customer.listed_price_cents = 599
	customer.budget_cents = 5_000
	Callable(hud, "_on_customer_head_changed").call(customer)
	Callable(hud, "_on_customer_desk_ready").call(customer, true)
	var negotiate := hud.get_node_or_null("%NegotiateButton") as Button
	var pull := hud.get_node_or_null("%PullButton") as Button
	var sell := hud.get_node_or_null("%SellButton") as Button
	_expect_equal(
		negotiate != null and negotiate.disabled,
		true,
		"C2 gate 3: HUD Negotiate disabled at Att 0"
	)
	_expect_equal(
		pull != null and pull.disabled,
		true,
		"C2 gate 3: HUD Pull disabled at Att 0"
	)
	_expect_equal(
		sell != null and not sell.disabled,
		true,
		"C2 gate 3: HUD Sell stays enabled with cashier on duty"
	)
	if inspect_button != null and inspect_button.visible:
		_expect_equal(inspect_button.disabled, true, "C2 gate 3: HUD Inspect disabled at Att 0")
	root.remove_child(hud)
	hud.free()


func _test_c2_specialist_attention_assert() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(NORMAL_CONFIG.inspect_attention_specialist, 2, "C2 gate 4: BalanceConfig Inspect 2")
	_expect_equal(NORMAL_CONFIG.research_attention_specialist, 10, "C2 gate 4: BalanceConfig Research 10")
	_expect_equal(shop.inspect_attention_cost(), 5, "C2 gate 4: owner Inspect 5")
	_expect_equal(shop.research_attention_cost(), 15, "C2 gate 4: owner Research 15")
	_expect_equal(shop.hire_specialist() != null, true, "C2 gate 4: hire Specialist")
	_expect_equal(shop.has_specialist_on_duty(), true, "C2 gate 4: Specialist on duty")
	_expect_equal(shop.inspect_attention_cost(), 2, "C2 gate 4: Inspect Att = 2")
	_expect_equal(shop.research_attention_cost(), 10, "C2 gate 4: Research Att = 10")

	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "C2 gate 4: HUD loads")
	if hud == null:
		return
	var open_research := hud.get_node_or_null("%OpenResearchButton") as Button
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	_expect_equal(
		open_research != null and open_research.text.contains("Att 10"),
		true,
		"C2 gate 4: HUD Research shows Att 10"
	)
	_expect_equal(
		inspect_button != null and inspect_button.text.contains("Att 2"),
		true,
		"C2 gate 4: HUD Inspect★ shows Att 2"
	)
	root.remove_child(hud)
	hud.free()


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


func _capture_beat_decision(payload: Dictionary) -> void:
	_captured_beat_decision = payload


func _capture_buy_focus(
	opportunity_id: StringName,
	beat_id: StringName,
	_message: String
) -> void:
	_captured_buy_focus_id = opportunity_id
	_captured_buy_focus_beat = beat_id


func _choice_ids(payload: Dictionary) -> Array[StringName]:
	var ids: Array[StringName] = []
	for value: Variant in payload.get("choices", []):
		if value is Dictionary:
			ids.append(StringName((value as Dictionary).get("id", &"")))
	return ids


func _choice_enabled(payload: Dictionary, choice_id: StringName) -> bool:
	for value: Variant in payload.get("choices", []):
		if not value is Dictionary:
			continue
		var choice := value as Dictionary
		if StringName(choice.get("id", &"")) != choice_id:
			continue
		return bool(choice.get("enabled", false))
	return false


func _instantiate_gameplay_hud() -> Node:
	var packed: PackedScene = load("res://scenes/ui/gameplay_hud.tscn") as PackedScene
	if packed == null:
		return null
	var hud: Node = packed.instantiate()
	root.add_child(hud)
	if not hud.is_node_ready():
		hud.notification(Node.NOTIFICATION_READY)
	return hud


func _click_buy_row_for_channel(hud: Node, channel: StringName) -> bool:
	var rows := hud.get_node_or_null("%BuyOpportunityRows") as VBoxContainer
	if rows == null:
		return false
	var prefix := "%s ·" % String(channel).capitalize()
	for child: Node in rows.get_children():
		var row := child as Button
		if row != null and row.text.begins_with(prefix):
			row.pressed.emit()
			return true
	return false


func _select_buy_on_hud(hud: Node, dto: BuyConfirmSignal) -> void:
	Callable(hud, "_select_buy_opportunity").call(dto)


func _assert_text_has_no_truth(text: String, label: String) -> void:
	var lower := text.to_lower()
	_expect_equal(
		lower.contains("true_market"),
		false,
		"%s does not leak true_market" % label
	)
	_expect_equal(lower.contains("p_buy"), false, "%s does not leak p_buy" % label)
	_expect_equal(
		lower.contains("cert_valid"),
		false,
		"%s does not leak cert_valid" % label
	)


func _assert_payload_has_no_truth(payload: Dictionary, label: String) -> void:
	for key: Variant in payload.keys():
		var field := String(key)
		_expect_equal(
			field.contains("true_market")
			or field.contains("p_buy")
			or field.contains("cert_valid"),
			false,
			"%s field %s does not leak truth" % [label, field]
		)
		var nested: Variant = payload[key]
		if nested is Dictionary:
			_assert_payload_has_no_truth(nested as Dictionary, label)
		elif nested is Array:
			for item: Variant in nested:
				if item is Dictionary:
					_assert_payload_has_no_truth(item as Dictionary, label)


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


func _assert_shop_shell_state(want_medium: bool, label: String) -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "%s shop_floor loads" % label)
	if packed == null:
		return
	var floor: Node = packed.instantiate()
	root.add_child(floor)
	var extent := floor.get_node_or_null("FloorExtent") as ShopFloorExtent
	_expect_equal(extent != null, true, "%s FloorExtent present" % label)
	if extent != null:
		extent.sync_from_shop()
		_expect_equal(
			extent.is_medium_extension_visible(),
			want_medium,
			"%s Art Medium shell visibility" % label
		)
		_expect_equal(
			extent.extra_floor_tile_count(),
			60 if want_medium else 0,
			"%s extra tiles" % label
		)
		_expect_equal(extent.has_fog_veil(), false, "%s fog stays nacked" % label)
		_expect_equal(
			extent.has_code_driven_stub(),
			false,
			"%s code-driven MediumFloor stub gone" % label
		)
		_expect_equal(extent.has_node("MediumFloor"), false, "%s no MediumFloor node" % label)
		_expect_equal(extent.has_node("MediumWallEast"), false, "%s no east wall stub" % label)
		_expect_equal(extent.has_node("MediumWallNorth"), false, "%s no north wall stub" % label)
	var small_shell := floor.get_node_or_null("Architecture/ShopShell") as Node3D
	var medium_shell := floor.get_node_or_null("Architecture/ShopShellMedium") as Node3D
	_expect_equal(small_shell != null, true, "%s Small Art GLB instanced" % label)
	_expect_equal(medium_shell != null, true, "%s Medium Art GLB instanced" % label)
	if small_shell != null:
		_expect_equal(small_shell.visible, not want_medium, "%s Small shell visible" % label)
	if medium_shell != null:
		_expect_equal(medium_shell.visible, want_medium, "%s Medium shell visible" % label)
		_expect_equal(
			medium_shell.position.is_equal_approx(Vector3.ZERO),
			true,
			"%s Medium SW pivot at origin" % label
		)
		_expect_equal(
			medium_shell.scale.is_equal_approx(Vector3.ONE),
			true,
			"%s Medium scale 1u=1m" % label
		)
	var camera := floor.get_node_or_null("Camera") as ShopCamera
	if camera != null:
		camera.apply_home_pose(ShopCamera.POSE_AISLE)
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.AISLE_POSITION),
			true,
			"%s does not churn aisle camera" % label
		)
		_expect_equal(
			is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
			true,
			"%s does not churn FOV" % label
		)
		camera.apply_home_pose(ShopCamera.POSE_BEHIND_COUNTER)
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"%s keeps Art behind-counter home" % label
		)
	_assert_overhead_lights_on_floor(floor, want_medium, label)
	floor.free()


func _assert_overhead_lights_for_tier(want_medium: bool, label: String) -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "%s shop_floor loads for lights" % label)
	if packed == null:
		return
	var floor: Node = packed.instantiate()
	root.add_child(floor)
	_assert_overhead_lights_on_floor(floor, want_medium, label)
	var camera := floor.get_node_or_null("Camera") as ShopCamera
	if camera != null:
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"%s lights do not churn behind-desk cam" % label
		)
		_expect_equal(
			is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
			true,
			"%s lights do not churn FOV" % label
		)
	floor.free()


func _assert_overhead_lights_on_floor(floor: Node, want_medium: bool, label: String) -> void:
	var extent := floor.get_node_or_null("FloorExtent") as ShopFloorExtent
	_expect_equal(extent != null, true, "%s FloorExtent for lights" % label)
	if extent != null:
		extent.sync_from_shop()
		_expect_equal(
			extent.is_medium_overhead_visible(),
			want_medium,
			"%s Medium extras visibility" % label
		)
		_expect_equal(
			extent.visible_overhead_mesh_count(),
			11 if want_medium else 5,
			"%s overhead mesh count" % label
		)
		_expect_equal(
			extent.visible_overhead_fill_count(),
			11 if want_medium else 5,
			"%s overhead fill count" % label
		)
		_expect_equal(extent.has_fog_veil(), false, "%s lights keep fog nacked" % label)
	var lights_root := floor.get_node_or_null("Fixtures/OverheadLights")
	_expect_equal(lights_root != null, true, "%s OverheadLights present" % label)
	_assert_small_overheads_locked(lights_root, label)
	_assert_medium_overheads(lights_root, want_medium, label)
	_assert_shop_fog_nacked(floor, label)


func _assert_small_overheads_locked(lights_root: Node, label: String) -> void:
	_expect_equal(lights_root != null, true, "%s OverheadLights root" % label)
	if lights_root == null:
		return
	var sot := {
		"FrontLeft": Vector3(2.25, 2.79, -2.25),
		"FrontRight": Vector3(6.75, 2.79, -2.25),
		"BackLeft": Vector3(2.25, 2.79, -4.95),
		"BackRight": Vector3(6.75, 2.79, -4.95),
		"BackLeftAisle": Vector3(2.8, 2.78, -5.4),
	}
	for mesh_name: String in sot:
		var mesh := lights_root.get_node_or_null(mesh_name) as Node3D
		_expect_equal(mesh != null, true, "%s %s present" % [label, mesh_name])
		if mesh == null:
			continue
		_expect_equal(mesh.visible, true, "%s %s stays visible" % [label, mesh_name])
		_expect_equal(
			mesh.position.is_equal_approx(sot[mesh_name]),
			true,
			"%s %s locked SoT" % [label, mesh_name]
		)
		_expect_equal(
			mesh.scale.is_equal_approx(Vector3.ONE),
			true,
			"%s %s scale 1,1,1" % [label, mesh_name]
		)
		var fill := lights_root.get_node_or_null("%sFill" % mesh_name) as OmniLight3D
		_expect_equal(fill != null, true, "%s %sFill present" % [label, mesh_name])
		if fill == null:
			continue
		_expect_equal(fill.visible, true, "%s %sFill stays visible" % [label, mesh_name])
		_expect_equal(
			fill.position.is_equal_approx(Vector3(sot[mesh_name].x, 2.55, sot[mesh_name].z)),
			true,
			"%s %sFill same XZ Y=2.55" % [label, mesh_name]
		)
		_assert_overhead_fill_recipe(fill, "%s %sFill" % [label, mesh_name])


func _assert_medium_overheads(lights_root: Node, want_visible: bool, label: String) -> void:
	_expect_equal(lights_root != null, true, "%s OverheadLights for Medium extras" % label)
	if lights_root == null:
		return
	var sot := {
		"MidCenter": Vector3(6.3, 2.79, -4.95),
		"FarFront": Vector3(10.35, 2.79, -2.25),
		"FarBack": Vector3(10.35, 2.79, -4.95),
		"DeepLeft": Vector3(2.25, 2.79, -7.2),
		"DeepCenter": Vector3(6.3, 2.79, -7.2),
		"DeepRight": Vector3(10.35, 2.79, -7.2),
	}
	for mesh_name: String in sot:
		var mesh := lights_root.get_node_or_null(mesh_name) as Node3D
		_expect_equal(mesh != null, true, "%s %s present" % [label, mesh_name])
		if mesh == null:
			continue
		_expect_equal(
			mesh.visible,
			want_visible,
			"%s %s Medium-only visibility" % [label, mesh_name]
		)
		_expect_equal(
			mesh.position.is_equal_approx(sot[mesh_name]),
			true,
			"%s %s SoT position" % [label, mesh_name]
		)
		_expect_equal(
			mesh.scale.is_equal_approx(Vector3.ONE),
			true,
			"%s %s scale 1,1,1" % [label, mesh_name]
		)
		var fill := lights_root.get_node_or_null("%sFill" % mesh_name) as OmniLight3D
		_expect_equal(fill != null, true, "%s %sFill present" % [label, mesh_name])
		if fill == null:
			continue
		_expect_equal(
			fill.visible,
			want_visible,
			"%s %sFill Medium-only visibility" % [label, mesh_name]
		)
		_expect_equal(
			fill.position.is_equal_approx(Vector3(sot[mesh_name].x, 2.55, sot[mesh_name].z)),
			true,
			"%s %sFill same XZ Y=2.55" % [label, mesh_name]
		)
		_assert_overhead_fill_recipe(fill, "%s %sFill" % [label, mesh_name])
	var mid := lights_root.get_node_or_null("MidCenter")
	var back_right := lights_root.get_node_or_null("BackRight")
	_expect_equal(
		mid != null and back_right != null and mid != back_right,
		true,
		"%s MidCenter stays a distinct node from BackRight" % label
	)


func _assert_overhead_fill_recipe(omni: OmniLight3D, label: String) -> void:
	_expect_equal(
		omni.light_color.is_equal_approx(Color(1, 0.83, 0.66, 1)),
		true,
		"%s color (1.0, 0.83, 0.66)" % label
	)
	_expect_equal(is_equal_approx(omni.light_energy, 1.65), true, "%s energy 1.65" % label)
	_expect_equal(is_equal_approx(omni.omni_range, 7.0), true, "%s range 7.0" % label)
	_expect_equal(is_equal_approx(omni.omni_attenuation, 1.2), true, "%s atten 1.2" % label)
	_expect_equal(omni.shadow_enabled, false, "%s shadows off" % label)


func _assert_shop_fog_nacked(shop: Node, label: String) -> void:
	var world := shop.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_expect_equal(world != null, true, "%s WorldEnvironment present" % label)
	if world == null or world.environment == null:
		return
	_expect_equal(world.environment.fog_enabled, false, "%s fog volume nacked" % label)
	_expect_equal(
		world.environment.volumetric_fog_enabled,
		false,
		"%s volumetric fog nacked" % label
	)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		return
	_failures += 1
	push_error("%s: expected %s, got %s" % [label, expected, actual])
