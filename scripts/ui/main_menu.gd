extends Control

signal start_requested

const MODE_ORDER: Array[int] = [0, 1, 2, 3]
const MODE_BUTTON_NAMES: Array[String] = [
	"FlagshipButton",
	"SurviveYear1Button",
	"LiquidityKingButton",
	"SandboxButton",
]


func _ready() -> void:
	_build_mode_picker()
	_sync_campaign_copy()


func select_displayed_mode(mode: int) -> bool:
	if not GameState.select_campaign_mode(mode as GameState.CampaignMode):
		_sync_campaign_copy()
		return false
	_sync_campaign_copy()
	return true


func _build_mode_picker() -> void:
	var host := get_node_or_null("%ModePicker") as GridContainer
	if host == null:
		return
	for child: Node in host.get_children():
		host.remove_child(child)
		child.free()
	var group := ButtonGroup.new()
	group.allow_unpress = false
	for index: int in MODE_ORDER.size():
		var mode: int = MODE_ORDER[index]
		var button := Button.new()
		button.name = MODE_BUTTON_NAMES[index]
		button.text = GameState.campaign_title(GameState.campaign_id(mode as GameState.CampaignMode))
		button.toggle_mode = true
		button.button_group = group
		button.custom_minimum_size = Vector2(0, 40)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 16)
		button.pressed.connect(_on_mode_button_pressed.bind(mode))
		host.add_child(button)
		button.unique_name_in_owner = true


func _on_mode_button_pressed(mode: int) -> void:
	select_displayed_mode(mode)


func _sync_campaign_copy() -> void:
	var campaign := get_node_or_null("%CampaignLabel") as Label
	if campaign != null:
		campaign.text = "Campaign: %s" % GameState.campaign_title(
			GameState.campaign_mode_id()
		)
	var blurb := get_node_or_null("%ModeBlurb") as Label
	if blurb != null:
		blurb.text = GameState.campaign_goal_copy()
	_sync_mode_buttons()
	_sync_sandbox_bests()
	var prestige := get_node_or_null("%PrestigeLabel") as Label
	if prestige == null:
		return
	if (
		GameState.last_prestige == GameState.FLAGSHIP_MODE
		or GameState.last_prestige == GameState.SURVIVE_Y1_MODE
		or GameState.last_prestige == GameState.LIQUIDITY_KING_MODE
	):
		prestige.text = "Last prestige: %s" % GameState.campaign_title(
			GameState.last_prestige
		)
		prestige.show()
	else:
		prestige.hide()


func _sync_mode_buttons() -> void:
	var selected := int(GameState.campaign_mode)
	for index: int in MODE_ORDER.size():
		var button := get_node_or_null("%" + MODE_BUTTON_NAMES[index]) as Button
		if button == null:
			continue
		button.set_pressed_no_signal(MODE_ORDER[index] == selected)


func _sync_sandbox_bests() -> void:
	var bests := get_node_or_null("%SandboxBests") as Label
	if bests == null:
		return
	if (
		GameState.campaign_mode != GameState.CampaignMode.SANDBOX
		or (GameState.sandbox_best_day <= 0 and GameState.sandbox_best_cash_cents <= 0)
	):
		bests.hide()
		return
	bests.text = "Personal best: day %d · %s" % [
		GameState.sandbox_best_day,
		DemandSignalPresenter.format_cents(GameState.sandbox_best_cash_cents),
	]
	bests.show()


func _on_start_button_pressed() -> void:
	start_requested.emit()
