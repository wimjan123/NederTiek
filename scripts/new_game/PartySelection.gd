extends Control

# PartySelection - UI for browsing generated parties or creating custom party
# Handles party generation, filtering, custom party creation, and validation

signal party_selected(party: Party)
signal custom_party_created(party: Party)
signal selection_changed()

@onready var browse_button = $MainContainer/OptionButtons/BrowsePartiesButton
@onready var create_button = $MainContainer/OptionButtons/CreatePartyButton
@onready var party_browser = $MainContainer/ContentStack/PartyBrowser
@onready var party_creator = $MainContainer/ContentStack/PartyCreator
@onready var ideology_filter = $MainContainer/ContentStack/PartyBrowser/FilterContainer/IdeologyFilter
@onready var party_list = $MainContainer/ContentStack/PartyBrowser/PartyScroll/PartyList
@onready var name_input = $MainContainer/ContentStack/PartyCreator/CreationForm/NameInput
@onready var abbrev_input = $MainContainer/ContentStack/PartyCreator/CreationForm/AbbrevInput
@onready var desc_input = $MainContainer/ContentStack/PartyCreator/CreationForm/DescInput
@onready var keywords_list = $MainContainer/ContentStack/PartyCreator/KeywordsScroll/KeywordsList
@onready var validation_label = $MainContainer/ContentStack/PartyCreator/ValidationLabel
@onready var preview_title = $MainContainer/SelectedPartyPreview/PreviewContainer/PreviewTitle
@onready var preview_details = $MainContainer/SelectedPartyPreview/PreviewContainer/PreviewDetails

var generated_parties: Array[Party] = []
var filtered_parties: Array[Party] = []
var selected_party: Party = null
var current_mode: String = "browse"  # "browse" or "create"

# Custom party creation data
var custom_keywords: Array[String] = []
var keyword_buttons: Array[CheckBox] = []

# Available policy keywords by category
var available_keywords = {
	"Economic": ["progressive_taxation", "tax_reduction", "free_market_economy", "wealth_redistribution", "universal_basic_income"],
	"Social": ["universal_healthcare", "social_housing", "traditional_values", "progressive_values", "welfare_expansion"],
	"Environmental": ["green_energy_transition", "climate_action", "environmental_protection", "sustainable_development"],
	"EU & International": ["eu_integration", "national_sovereignty", "european_cooperation", "international_solidarity"],
	"Governance": ["direct_democracy", "democratic_reform", "pragmatic_governance", "decentralization"]
}

func _ready():
	# Debug: Check if all @onready nodes are properly connected
	print("DEBUG: Checking @onready nodes...")
	print("  browse_button: %s" % ("OK" if browse_button != null else "NULL"))
	print("  create_button: %s" % ("OK" if create_button != null else "NULL"))
	print("  party_browser: %s" % ("OK" if party_browser != null else "NULL"))
	print("  party_creator: %s" % ("OK" if party_creator != null else "NULL"))
	print("  party_list: %s" % ("OK" if party_list != null else "NULL"))

	if party_list != null:
		print("  party_list path: %s" % party_list.get_path())

	# Initialize the party selection interface
	_setup_ui()
	_generate_parties()
	_setup_keyword_selection()
	_switch_to_browse_mode()

func _setup_ui():
	# Setup ideology filter
	ideology_filter.add_item("All Parties")
	ideology_filter.add_item("Left-wing")
	ideology_filter.add_item("Center-left")
	ideology_filter.add_item("Centrist")
	ideology_filter.add_item("Center-right")
	ideology_filter.add_item("Right-wing")

func _generate_parties():
	print("PartySelection: Generating parties...")
	var generator = PartyGenerator.new()
	generated_parties = generator.generate_parties(20)
	filtered_parties = generated_parties.duplicate()
	_populate_party_list()
	print("PartySelection: Generated %d parties" % generated_parties.size())

func _populate_party_list():
	# Debug: Check if party_list node exists
	if party_list == null:
		print("ERROR: party_list node is null! Check scene structure.")
		return

	print("DEBUG: party_list node found: %s" % party_list.name)
	print("DEBUG: party_list children before clear: %d" % party_list.get_child_count())

	# Clear existing party cards
	for child in party_list.get_children():
		child.queue_free()

	print("DEBUG: Creating %d party cards..." % filtered_parties.size())
	# Create party cards for filtered parties
	for i in range(filtered_parties.size()):
		var party = filtered_parties[i]
		var party_card = _create_party_card(party)
		party_list.add_child(party_card)
		print("DEBUG: Added card %d for %s" % [i, party.name])

		# Add spacing between cards
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 10)
		party_list.add_child(spacer)

	print("DEBUG: party_list children after adding: %d" % party_list.get_child_count())
	print("DEBUG: party_list visible: %s" % party_list.visible)
	print("DEBUG: party_list size: %s" % str(party_list.size))

func _create_party_card(party: Party) -> Control:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(0, 120)

	# Add visible background style
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.3, 1.0)  # Dark blue-gray background
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = party.color_primary
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("panel", style_box)

	var container = VBoxContainer.new()
	container.position = Vector2(10, 10)  # Add padding
	container.size = Vector2(card.custom_minimum_size.x - 20, card.custom_minimum_size.y - 20)
	container.anchor_right = 1.0
	container.anchor_bottom = 1.0
	container.offset_left = 10
	container.offset_top = 10
	container.offset_right = -10
	container.offset_bottom = -10
	card.add_child(container)

	# Header with party name and colors
	var header = HBoxContainer.new()
	container.add_child(header)

	var color_rect = ColorRect.new()
	color_rect.custom_minimum_size = Vector2(20, 20)
	color_rect.color = party.color_primary
	header.add_child(color_rect)

	var name_label = Label.new()
	name_label.text = party.get_display_name()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.modulate = Color.WHITE  # Ensure text is visible
	header.add_child(name_label)

	# Description
	var desc_label = Label.new()
	desc_label.text = party.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.custom_minimum_size.y = 40
	desc_label.modulate = Color(0.9, 0.9, 0.9, 1)  # Light gray text
	container.add_child(desc_label)

	# Keywords
	if party.policy_keywords.size() > 0:
		var keywords_label = Label.new()
		keywords_label.text = "Policies: " + ", ".join(party.policy_keywords.slice(0, 3))
		if party.policy_keywords.size() > 3:
			keywords_label.text += "..."
		keywords_label.modulate = Color(0.7, 0.7, 0.7, 1)  # Darker gray for keywords
		container.add_child(keywords_label)

	# Select button
	var select_button = Button.new()
	select_button.text = "Select This Party"
	select_button.pressed.connect(_on_party_card_selected.bind(party))
	container.add_child(select_button)

	return card

func _setup_keyword_selection():
	# Clear existing keyword checkboxes
	for child in keywords_list.get_children():
		child.queue_free()
	keyword_buttons.clear()

	# Create checkboxes for each category
	for category in available_keywords.keys():
		var category_label = Label.new()
		category_label.text = category + " (select 2+ from this category):"
		category_label.add_theme_stylebox_override("normal", StyleBoxFlat.new())
		keywords_list.add_child(category_label)

		for keyword in available_keywords[category]:
			var checkbox = CheckBox.new()
			checkbox.text = keyword.replace("_", " ").capitalize()
			checkbox.toggled.connect(_on_keyword_toggled.bind(keyword))
			keywords_list.add_child(checkbox)
			keyword_buttons.append(checkbox)

func _switch_to_browse_mode():
	current_mode = "browse"
	party_browser.visible = true
	party_creator.visible = false
	browse_button.disabled = true
	create_button.disabled = false
	_update_preview()

func _switch_to_create_mode():
	current_mode = "create"
	party_browser.visible = false
	party_creator.visible = true
	browse_button.disabled = false
	create_button.disabled = true
	selected_party = null
	_update_preview()

func _filter_parties_by_ideology(ideology_index: int):
	if ideology_index == 0:  # All parties
		filtered_parties = generated_parties.duplicate()
	else:
		filtered_parties.clear()
		var ideology_ranges = [
			{"min": -1.0, "max": -0.4},  # Left-wing
			{"min": -0.4, "max": -0.1},  # Center-left
			{"min": -0.1, "max": 0.1},   # Centrist
			{"min": 0.1, "max": 0.4},    # Center-right
			{"min": 0.4, "max": 1.0}     # Right-wing
		]

		var range_data = ideology_ranges[ideology_index - 1]
		for party in generated_parties:
			var economic_score = party.ideology_scores.get("economic_left_right", 0.0)
			if economic_score >= range_data["min"] and economic_score <= range_data["max"]:
				filtered_parties.append(party)

	_populate_party_list()

func _validate_custom_party() -> Dictionary:
	var party_data = {
		"name": name_input.text.strip_edges(),
		"abbreviation": abbrev_input.text.strip_edges().to_upper(),
		"description": desc_input.text.strip_edges(),
		"policy_keywords": custom_keywords
	}

	var generator = PartyGenerator.new()
	return generator.validate_custom_party(party_data)

func _update_custom_party_validation():
	var validation = _validate_custom_party()

	if validation["valid"]:
		validation_label.text = "✓ Party ready to create"
		validation_label.modulate = Color(0.5, 1, 0.5, 1)
	else:
		validation_label.text = "Issues: " + ", ".join(validation["errors"])
		validation_label.modulate = Color(1, 0.5, 0.5, 1)

	_update_preview()

func _create_custom_party():
	var validation = _validate_custom_party()
	if not validation["valid"]:
		return

	var generator = PartyGenerator.new()
	var party = generator.create_custom_party(validation["data"])

	if party != null:
		selected_party = party
		custom_party_created.emit(party)
		_update_preview()

func _update_preview():
	if selected_party != null:
		preview_title.text = "Selected Party: " + selected_party.get_display_name()

		var details = selected_party.description
		if selected_party.policy_keywords.size() > 0:
			details += "\n\nKey Policies:\n• " + "\n• ".join(selected_party.policy_keywords)

		preview_details.text = details
	elif current_mode == "create" and _validate_custom_party()["valid"]:
		preview_title.text = "Custom Party Preview"
		var data = _validate_custom_party()["data"]
		var details = "%s (%s)\n\n%s" % [data["name"], data["abbreviation"], data["description"]]
		if data["policy_keywords"].size() > 0:
			details += "\n\nSelected Policies:\n• " + "\n• ".join(data["policy_keywords"])
		preview_details.text = details
	else:
		preview_title.text = "Selected Party: None"
		preview_details.text = "No party selected"

# Signal handlers
func _on_browse_parties_button_pressed():
	_switch_to_browse_mode()

func _on_create_party_button_pressed():
	_switch_to_create_mode()

func _on_ideology_filter_item_selected(index: int):
	_filter_parties_by_ideology(index)

func _on_party_card_selected(party: Party):
	selected_party = party
	party_selected.emit(party)
	_update_preview()
	selection_changed.emit()

func _on_name_input_text_changed(_new_text: String):
	_update_custom_party_validation()

func _on_abbrev_input_text_changed(_new_text: String):
	_update_custom_party_validation()

func _on_desc_input_text_changed():
	_update_custom_party_validation()

func _on_keyword_toggled(keyword: String, pressed: bool):
	if pressed:
		if keyword not in custom_keywords:
			custom_keywords.append(keyword)
	else:
		custom_keywords.erase(keyword)

	_update_custom_party_validation()

# Public interface
func get_selected_party() -> Party:
	return selected_party

func can_continue() -> bool:
	return selected_party != null or (current_mode == "create" and _validate_custom_party()["valid"])

func create_party_if_valid() -> Party:
	if current_mode == "create" and _validate_custom_party()["valid"]:
		_create_custom_party()
	return selected_party