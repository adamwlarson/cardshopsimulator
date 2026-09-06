extends Control

signal start_requested


func _ready() -> void:
	_sync_campaign_copy()


func _sync_campaign_copy() -> void:
	var campaign := get_node_or_null("%CampaignLabel") as Label
	if campaign != null:
		campaign.text = "Campaign: Flagship"
	var prestige := get_node_or_null("%PrestigeLabel") as Label
	if prestige == null:
		return
	if GameState.last_prestige == GameState.FLAGSHIP_MODE:
		prestige.text = "Last prestige: Flagship"
		prestige.show()
	else:
		prestige.hide()


func _on_start_button_pressed() -> void:
	start_requested.emit()
