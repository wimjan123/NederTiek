extends Panel
class_name PartyCard

# PartyCard - Reusable UI component for displaying party information
# Used in party selection screen and other places where parties are shown

signal party_selected(party: Party)

@onready var color_indicator = $CardContainer/Header/ColorIndicator
@onready var party_name = $CardContainer/Header/NameContainer/PartyName
@onready var party_abbrev = $CardContainer/Header/NameContainer/PartyAbbrev
@onready var description = $CardContainer/Description
@onready var policy_list = $CardContainer/PolicyContainer/PolicyList
@onready var ideology_label = $CardContainer/Footer/IdeologyLabel
@onready var select_button = $CardContainer/Footer/SelectButton

var party_data: Party = null
var is_selected: bool = false

func setup_party(party: Party):
	party_data = party
	_update_display()

func _update_display():
	if party_data == null:
		return

	# Update header
	party_name.text = party_data.name
	party_abbrev.text = party_data.abbreviation
	color_indicator.color = party_data.color_primary

	# Update description
	description.text = party_data.description

	# Update policy keywords (show first 3)
	if party_data.policy_keywords.size() > 0:
		var display_keywords = party_data.policy_keywords.slice(0, 3)
		policy_list.text = ", ".join(display_keywords)
		if party_data.policy_keywords.size() > 3:
			policy_list.text += "..."
	else:
		policy_list.text = "No policies specified"

	# Update ideology display
	ideology_label.text = _get_ideology_description()

func _get_ideology_description() -> String:
	if party_data == null or party_data.ideology_scores.size() == 0:
		return "Unknown"

	var economic_score = party_data.ideology_scores.get("economic_left_right", 0.0)

	if economic_score < -0.4:
		return "Left-wing"
	elif economic_score < -0.1:
		return "Center-left"
	elif economic_score > 0.4:
		return "Right-wing"
	elif economic_score > 0.1:
		return "Center-right"
	else:
		return "Centrist"

func set_selected(selected: bool):
	is_selected = selected
	_update_visual_state()

func _update_visual_state():
	if is_selected:
		modulate = Color(0.9, 1.0, 0.9, 1)
		select_button.text = "Selected"
		select_button.disabled = true
	else:
		modulate = Color(1, 1, 1, 1)
		select_button.text = "Select"
		select_button.disabled = false

func _on_select_button_pressed():
	if party_data != null:
		party_selected.emit(party_data)

# Public interface
func get_party() -> Party:
	return party_data

func set_button_text(text: String):
	select_button.text = text

func set_button_enabled(enabled: bool):
	select_button.disabled = not enabled