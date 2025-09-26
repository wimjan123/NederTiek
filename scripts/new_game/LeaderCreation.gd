extends Control

# LeaderCreation - UI for selecting background and creating party leader
# Handles background selection, leader customization, and attribute preview

signal leader_created(leader: Leader)
signal background_selected(background: LeaderBackground)
signal validation_changed()

@onready var background_list = $MainContainer/ContentArea/BackgroundPanel/BackgroundContainer/BackgroundScroll/BackgroundList
@onready var portrait_rect = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/PortraitContainer/PortraitRect
@onready var portrait_button = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/PortraitContainer/PortraitButton
@onready var first_name_input = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/NameForm/FirstNameInput
@onready var last_name_input = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/NameForm/LastNameInput
@onready var validation_label = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/ValidationLabel
@onready var preview_title = $MainContainer/LeaderPreview/PreviewContainer/PreviewTitle
@onready var preview_details = $MainContainer/LeaderPreview/PreviewContainer/PreviewDetails

# Attribute progress bars
@onready var charisma_progress = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/CharismaBar/CharismaProgress
@onready var charisma_value = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/CharismaBar/CharismaValue
@onready var intelligence_progress = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/IntelligenceBar/IntelligenceProgress
@onready var intelligence_value = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/IntelligenceBar/IntelligenceValue
@onready var integrity_progress = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/IntegrityBar/IntegrityProgress
@onready var integrity_value = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/IntegrityBar/IntegrityValue
@onready var experience_progress = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/ExperienceBar/ExperienceProgress
@onready var experience_value = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/ExperienceBar/ExperienceValue
@onready var energy_progress = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/EnergyBar/EnergyProgress
@onready var energy_value = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/EnergyBar/EnergyValue
@onready var networking_progress = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/NetworkingBar/NetworkingProgress
@onready var networking_value = $MainContainer/ContentArea/DetailsPanel/DetailsContainer/AttributesContainer/NetworkingBar/NetworkingValue

var available_backgrounds: Array[LeaderBackground] = []
var selected_background: LeaderBackground = null
var current_leader: Leader = null
var current_portrait_index: int = 0

# Portrait colors for simple avatar generation
var portrait_colors = [
	Color(0.8, 0.7, 0.6, 1),  # Light skin
	Color(0.7, 0.6, 0.5, 1),  # Medium skin
	Color(0.6, 0.4, 0.3, 1),  # Dark skin
	Color(0.9, 0.8, 0.7, 1),  # Very light skin
]

func _ready():
	_load_backgrounds()
	_populate_background_list()
	_update_validation()

func _load_backgrounds():
	# Use the backgrounds loaded by GameSetupState
	available_backgrounds = GameSetupState.available_backgrounds.duplicate()
	print("LeaderCreation: Loaded %d backgrounds" % available_backgrounds.size())

func _populate_background_list():
	print("DEBUG: _populate_background_list called")
	print("DEBUG: available_backgrounds size: ", available_backgrounds.size())
	print("DEBUG: background_list node: ", background_list)

	# Clear existing background cards
	for child in background_list.get_children():
		child.queue_free()

	# Create background cards
	for background in available_backgrounds:
		print("DEBUG: Creating card for background: ", background.name)
		var card = _create_background_card(background)
		background_list.add_child(card)

func _create_background_card(background: LeaderBackground) -> Control:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(0, 150)

	var container = VBoxContainer.new()
	card.add_child(container)

	# Background name
	var name_label = Label.new()
	name_label.text = background.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(name_label)

	# Description
	var desc_label = Label.new()
	desc_label.text = background.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.custom_minimum_size.y = 60
	container.add_child(desc_label)

	# Impact summary
	var impact_label = Label.new()
	impact_label.text = background.get_impact_summary()
	impact_label.modulate = Color(0.8, 0.8, 1, 1)
	impact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(impact_label)

	# Select button
	var select_button = Button.new()
	select_button.text = "Select Background"
	select_button.pressed.connect(_on_background_selected.bind(background))
	container.add_child(select_button)

	return card

func _update_attribute_display():
	if selected_background == null:
		# Reset to base values
		_set_attribute_display("charisma", 50)
		_set_attribute_display("intelligence", 50)
		_set_attribute_display("integrity", 50)
		_set_attribute_display("experience", 50)
		_set_attribute_display("energy", 50)
		_set_attribute_display("networking", 50)
	else:
		# Show modified values
		var base_attributes = {
			"charisma": 50,
			"intelligence": 50,
			"integrity": 50,
			"experience": 50,
			"energy": 50,
			"networking": 50
		}

		for attr_key in base_attributes.keys():
			var base_value = base_attributes[attr_key]
			var modifier = selected_background.attribute_modifiers.get(attr_key, 0)
			var final_value = clamp(base_value + modifier, 0, 100)
			_set_attribute_display(attr_key, final_value)

func _set_attribute_display(attribute: String, value: int):
	match attribute:
		"charisma":
			charisma_progress.value = value
			charisma_value.text = str(value)
		"intelligence":
			intelligence_progress.value = value
			intelligence_value.text = str(value)
		"integrity":
			integrity_progress.value = value
			integrity_value.text = str(value)
		"experience":
			experience_progress.value = value
			experience_value.text = str(value)
		"energy":
			energy_progress.value = value
			energy_value.text = str(value)
		"networking":
			networking_progress.value = value
			networking_value.text = str(value)

func _update_portrait():
	# Simple colored rectangle as portrait
	if current_portrait_index < portrait_colors.size():
		portrait_rect.color = portrait_colors[current_portrait_index]
	else:
		portrait_rect.color = Color.GRAY

func _validate_leader_data() -> Dictionary:
	var errors: Array[String] = []

	# Check required fields
	if first_name_input.text.strip_edges().length() < 2:
		errors.append("First name must be at least 2 characters")
	elif first_name_input.text.strip_edges().length() > 30:
		errors.append("First name must be 30 characters or less")

	if last_name_input.text.strip_edges().length() < 2:
		errors.append("Last name must be at least 2 characters")
	elif last_name_input.text.strip_edges().length() > 30:
		errors.append("Last name must be 30 characters or less")

	if selected_background == null:
		errors.append("Please select a background")

	return {
		"valid": errors.size() == 0,
		"errors": errors
	}

func _update_validation():
	var validation = _validate_leader_data()

	if validation["valid"]:
		validation_label.text = "✓ Leader created and ready"
		validation_label.modulate = Color(0.5, 1, 0.5, 1)
		# Automatically create leader when validation passes (only if we don't have one)
		if current_leader == null:
			_create_leader()
	else:
		validation_label.text = "Issues: " + ", ".join(validation["errors"])
		validation_label.modulate = Color(1, 0.5, 0.5, 1)

	_update_preview()
	validation_changed.emit()

func _create_leader():
	var validation = _validate_leader_data()
	if not validation["valid"]:
		return null

	# Create the leader
	var leader = Leader.new()
	leader.id = "leader_" + str(Time.get_unix_time_from_system())
	leader.first_name = first_name_input.text.strip_edges()
	leader.last_name = last_name_input.text.strip_edges()
	leader.background_id = selected_background.id
	leader.portrait_index = current_portrait_index

	# Apply background modifiers
	leader.apply_attribute_modifier(selected_background.attribute_modifiers)

	# Set party relationship
	if GameSetupState.selected_party != null:
		leader.party_id = GameSetupState.selected_party.id

	current_leader = leader
	leader_created.emit(leader)

	# Also notify GameSetupState
	GameSetupState.create_leader(leader.first_name, leader.last_name)

	return leader

func _update_preview():
	if current_leader != null or _validate_leader_data()["valid"]:
		var leader_name = first_name_input.text.strip_edges() + " " + last_name_input.text.strip_edges()
		preview_title.text = "Leader Preview: " + leader_name

		var details = ""
		if selected_background != null:
			details += "Background: " + selected_background.name + "\n\n"
			details += selected_background.description + "\n\n"
			details += "Special Traits: " + ", ".join(selected_background.special_traits)

		preview_details.text = details
	else:
		preview_title.text = "Leader Preview: Not Ready"
		preview_details.text = "Complete the form above to create your leader"

# Signal handlers
func _on_background_selected(background: LeaderBackground):
	selected_background = background
	background_selected.emit(background)

	# Update GameSetupState
	GameSetupState.set_background(background)

	_update_attribute_display()
	_update_validation()

	print("Background selected: " + background.name)

func _on_portrait_button_pressed():
	current_portrait_index = (current_portrait_index + 1) % portrait_colors.size()
	_update_portrait()

func _on_first_name_input_text_changed(_new_text: String):
	_update_validation()

func _on_last_name_input_text_changed(_new_text: String):
	_update_validation()

# Public interface
func get_current_leader() -> Leader:
	return current_leader

func can_create_leader() -> bool:
	return _validate_leader_data()["valid"]

func create_leader_if_valid() -> Leader:
	if can_create_leader():
		return _create_leader()
	return null

func get_selected_background() -> LeaderBackground:
	return selected_background