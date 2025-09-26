extends Control

# NewGameFlow - Main orchestrator for the new game setup process
# Manages scene transitions, progress tracking, and overall flow control

@onready var back_button = $MainContainer/Header/BackButton
@onready var title_label = $MainContainer/Header/Title
@onready var progress_label = $MainContainer/Header/Progress
@onready var content_area = $MainContainer/ContentArea
@onready var sub_viewport = $MainContainer/ContentArea/SubViewport
@onready var status_label = $MainContainer/Footer/StatusLabel
@onready var continue_button = $MainContainer/Footer/ContinueButton

# Current phase scene references
var current_scene: Node = null
var phase_scenes: Dictionary = {}

# Phase configuration
var phases = [
	{
		"id": "party_selection",
		"title": "Choose Your Party",
		"scene_path": "res://scenes/new_game/PartySelection.tscn",
		"status_text": "Select or create your political party"
	},
	{
		"id": "leader_creation",
		"title": "Create Your Leader",
		"scene_path": "res://scenes/new_game/LeaderCreation.tscn",
		"status_text": "Define your party leader's background and details"
	},
	{
		"id": "media_interview",
		"title": "Media Interview",
		"scene_path": "res://scenes/new_game/MediaInterview.tscn",
		"status_text": "Answer questions to establish your political positions"
	},
	{
		"id": "review",
		"title": "Review & Confirm",
		"scene_path": "",  # No separate scene, handled internally
		"status_text": "Review your setup and start the game"
	}
]

var current_phase_index: int = 0

func _ready():
	# Connect to GameSetupState signals
	GameSetupState.setup_phase_changed.connect(_on_setup_phase_changed)
	GameSetupState.setup_completed.connect(_on_setup_completed)
	GameSetupState.party_data_updated.connect(_on_party_updated)
	GameSetupState.leader_data_updated.connect(_on_leader_updated)

	# Connect to window resizing
	get_viewport().size_changed.connect(_on_viewport_size_changed)

	# Initialize - try to load saved state, otherwise start from beginning
	if not load_setup_state():
		_load_phase(0)

func _load_phase(phase_index: int):
	current_phase_index = phase_index

	if phase_index < 0 or phase_index >= phases.size():
		push_error("Invalid phase index: " + str(phase_index))
		return

	var phase = phases[phase_index]

	# Sync GameSetupState's current phase with our phase
	GameSetupState.current_phase = phase["id"]

	# Debug: Check what data we have
	print("DEBUG: Loading phase ", phase["id"], " with party=", GameSetupState.selected_party, " leader=", GameSetupState.leader)

	# Update UI
	title_label.text = phase["title"]
	progress_label.text = "Step %d of %d" % [phase_index + 1, phases.size()]
	status_label.text = phase["status_text"]

	# Update back button visibility
	back_button.visible = phase_index > 0

	# Clear current scene
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null

	# Load new scene
	if phase["scene_path"] != "":
		_load_scene(phase["scene_path"])
	else:
		_load_review_phase()

	# Update continue button state
	_update_continue_button()

	# Auto-save progress (except on initial load)
	if phase_index > 0:
		save_setup_state()

func _load_scene(scene_path: String):
	print("DEBUG: Loading scene: ", scene_path)
	var scene_resource = load(scene_path)
	if scene_resource == null:
		push_error("Failed to load scene: " + scene_path)
		return

	current_scene = scene_resource.instantiate()
	print("DEBUG: Scene instantiated: ", current_scene.name)
	sub_viewport.add_child(current_scene)
	print("DEBUG: Scene added to SubViewport")
	print("DEBUG: SubViewport size: ", sub_viewport.size)
	print("DEBUG: current_scene size: ", current_scene.size)
	print("DEBUG: current_scene visible: ", current_scene.visible)

	# ContentArea is now a SubViewportContainer - it handles SubViewport display automatically
	print("DEBUG: ContentArea (SubViewportContainer) setup complete")
	var content_area = $MainContainer/ContentArea
	print("DEBUG: ContentArea size: ", content_area.size)
	print("DEBUG: SubViewport size: ", sub_viewport.size)
	print("DEBUG: Current scene size: ", current_scene.size)

	# Connect phase-specific signals
	_connect_phase_signals()

func _connect_phase_signals():
	if current_scene == null:
		return

	var phase = phases[current_phase_index]

	match phase["id"]:
		"party_selection":
			if current_scene.has_signal("party_selected"):
				current_scene.party_selected.connect(_on_party_selected)
			if current_scene.has_signal("custom_party_created"):
				current_scene.custom_party_created.connect(_on_custom_party_created)
			if current_scene.has_signal("selection_changed"):
				current_scene.selection_changed.connect(_on_selection_changed)

		"leader_creation":
			if current_scene.has_signal("leader_created"):
				current_scene.leader_created.connect(_on_leader_created)
			if current_scene.has_signal("background_selected"):
				current_scene.background_selected.connect(_on_background_selected)
			if current_scene.has_signal("validation_changed"):
				current_scene.validation_changed.connect(_on_validation_changed)

		"media_interview":
			if current_scene.has_signal("interview_complete"):
				current_scene.interview_complete.connect(_on_interview_complete)
			if current_scene.has_signal("question_answered"):
				current_scene.question_answered.connect(_on_question_answered)
			if current_scene.has_signal("progress_changed"):
				current_scene.progress_changed.connect(_on_interview_progress_changed)

func _load_review_phase():
	# Create review content directly in the viewport
	var review_container = VBoxContainer.new()
	sub_viewport.add_child(review_container)
	current_scene = review_container

	# Add review content
	var summary_label = Label.new()
	summary_label.text = "Review Your Setup"
	summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	review_container.add_child(summary_label)

	var separator = HSeparator.new()
	review_container.add_child(separator)

	# Party summary
	var party_panel = _create_summary_panel("Selected Party", _get_party_summary())
	review_container.add_child(party_panel)

	# Leader summary
	var leader_panel = _create_summary_panel("Your Leader", _get_leader_summary())
	review_container.add_child(leader_panel)

	# Starting conditions
	var conditions_panel = _create_summary_panel("Starting Conditions", _get_conditions_summary())
	review_container.add_child(conditions_panel)

	# Enable continue button for final step
	continue_button.disabled = false
	continue_button.text = "Start Game"

func _create_summary_panel(title: String, content: String) -> Panel:
	var panel = Panel.new()
	var container = VBoxContainer.new()
	panel.add_child(container)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_stylebox_override("normal", StyleBoxFlat.new())
	container.add_child(title_label)

	var content_label = Label.new()
	content_label.text = content
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	container.add_child(content_label)

	return panel

func _get_party_summary() -> String:
	if GameSetupState.selected_party == null:
		return "No party selected"

	var party = GameSetupState.selected_party
	var summary = "%s (%s)\n\n%s" % [party.name, party.abbreviation, party.description]

	if party.policy_keywords.size() > 0:
		summary += "\n\nKey Policies: " + ", ".join(party.policy_keywords)

	return summary

func _get_leader_summary() -> String:
	if GameSetupState.leader == null:
		return "No leader created"

	var leader = GameSetupState.leader
	var background = GameSetupState.selected_background

	var summary = "%s\nBackground: %s" % [leader.get_full_name(), background.name if background else "None"]

	# Add attributes
	summary += "\n\nAttributes:"
	for attr_key in leader.attributes.keys():
		var value = leader.attributes[attr_key]
		summary += "\n• %s: %d" % [attr_key.capitalize(), value]

	return summary

func _get_conditions_summary() -> String:
	if GameSetupState.leader == null:
		return "Setup incomplete"

	var leader = GameSetupState.leader
	var summary = "Starting Treasury: %s\n" % leader.get_formatted_treasury()
	summary += "Initial Popularity: %.1f%%" % leader.starting_popularity

	if GameSetupState.interview_responses.size() > 0:
		summary += "\n\nInterview Responses: %d questions answered" % GameSetupState.interview_responses.size()

	return summary

func _update_continue_button():
	var can_continue = false
	var button_text = "Continue"

	match current_phase_index:
		0:  # Party selection
			can_continue = GameSetupState.selected_party != null
			button_text = "Continue to Leader Creation"
		1:  # Leader creation
			can_continue = GameSetupState.leader != null and GameSetupState.selected_background != null
			button_text = "Continue to Interview"
		2:  # Media interview
			can_continue = GameSetupState.interview_responses.size() >= 4
			button_text = "Continue to Review"
		3:  # Review
			can_continue = true
			button_text = "Start Game"

	continue_button.disabled = not can_continue
	continue_button.text = button_text

# Signal handlers for UI
func _on_back_button_pressed():
	if current_phase_index > 0:
		_load_phase(current_phase_index - 1)
		GameSetupState.go_back()

func _on_continue_button_pressed():
	print("DEBUG: Continue button pressed, current_phase_index = ", current_phase_index)
	if current_phase_index < phases.size() - 1:
		print("DEBUG: Calling GameSetupState.advance_phase()")
		GameSetupState.advance_phase()
	else:
		# Final step - start the game
		_start_game()

# Signal handlers for GameSetupState
func _on_setup_phase_changed(phase: String):
	# Find the phase index
	for i in range(phases.size()):
		if phases[i]["id"] == phase:
			if i != current_phase_index:
				_load_phase(i)
			break

func _on_setup_completed(game_data: Dictionary):
	print("Setup completed with data: ", game_data)
	_start_game()

# Signal handlers for phase scenes
func _on_party_selected(party: Party):
	GameSetupState.set_party(party)
	_update_continue_button()

func _on_custom_party_created(party: Party):
	GameSetupState.set_party(party)
	_update_continue_button()

func _on_selection_changed():
	_update_continue_button()

func _on_leader_created(leader: Leader):
	# Store the leader in GameSetupState so continue button can check it
	GameSetupState.leader = leader
	_update_continue_button()

func _on_background_selected(background: LeaderBackground):
	GameSetupState.set_background(background)
	_update_continue_button()

func _on_validation_changed():
	_update_continue_button()

func _on_interview_complete(responses: Array):
	print("Interview completed with %d responses" % responses.size())
	_update_continue_button()

func _on_question_answered(answer: MediaAnswer):
	GameSetupState.add_interview_response(answer)
	_update_continue_button()

func _on_interview_progress_changed():
	_update_continue_button()

func _on_party_updated(party: Party):
	print("Party updated: " + party.get_display_name())
	_update_continue_button()

func _on_leader_updated(leader: Leader):
	print("Leader updated: " + leader.get_full_name())
	_update_continue_button()

# Game start handling
func _start_game():
	print("Starting game with completed setup")

	# Compile final game data
	var game_data = GameSetupState.compile_game_start_data()

	# Save the completed setup before transitioning
	save_setup_state()

	# TODO: Transition to main game scene
	# For now, just return to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

# Save/Load functionality using ConfigFile
func save_setup_state():
	var config = ConfigFile.new()
	var save_data = GameSetupState.save_setup_state()

	config.set_value("setup", "phase", current_phase_index)
	config.set_value("setup", "party_data", save_data.get("party", {}))
	config.set_value("setup", "leader_data", save_data.get("leader", {}))
	config.set_value("setup", "background_data", save_data.get("background", {}))
	config.set_value("setup", "interview_responses", save_data.get("interview_responses", []))
	config.set_value("setup", "timestamp", Time.get_unix_time_from_system())

	var error = config.save("user://new_game_setup.cfg")
	if error == OK:
		print("Setup state saved successfully")
	else:
		print("Failed to save setup state: ", error)

func load_setup_state() -> bool:
	var config = ConfigFile.new()
	var error = config.load("user://new_game_setup.cfg")

	if error != OK:
		print("No saved setup state found or failed to load")
		return false

	# Load phase
	current_phase_index = config.get_value("setup", "phase", 0)

	# Load data into GameSetupState
	var save_data = {
		"party": config.get_value("setup", "party_data", {}),
		"leader": config.get_value("setup", "leader_data", {}),
		"background": config.get_value("setup", "background_data", {}),
		"interview_responses": config.get_value("setup", "interview_responses", [])
	}

	GameSetupState.load_setup_state(save_data)

	# Load the appropriate phase
	_load_phase(current_phase_index)

	print("Setup state loaded successfully")
	return true

func clear_saved_state():
	var dir = DirAccess.open("user://")
	if dir.file_exists("new_game_setup.cfg"):
		dir.remove("new_game_setup.cfg")
		print("Saved setup state cleared")

# Public interface for external navigation
func jump_to_phase(phase_id: String):
	for i in range(phases.size()):
		if phases[i]["id"] == phase_id:
			_load_phase(i)
			return true
	return false

func get_current_phase_id() -> String:
	if current_phase_index >= 0 and current_phase_index < phases.size():
		return phases[current_phase_index]["id"]
	return ""

func can_go_back() -> bool:
	return current_phase_index > 0

func can_go_forward() -> bool:
	return GameSetupState.can_advance()

func _on_viewport_size_changed():
	# SubViewportContainer handles resizing automatically with stretch=true
	print("DEBUG: Window resized - SubViewportContainer handles SubViewport sizing automatically")

# Development/testing helpers
func skip_to_review():
	# Create dummy data for testing
	if GameSetupState.selected_party == null:
		var test_party = Party.new()
		test_party.name = "Test Party"
		test_party.abbreviation = "TP"
		test_party.description = "A test party for development"
		GameSetupState.set_party(test_party)

	if GameSetupState.leader == null:
		var test_background = LeaderBackground.create_business_executive()
		GameSetupState.set_background(test_background)
		GameSetupState.create_leader("Test", "Leader")

	if GameSetupState.interview_responses.size() == 0:
		# Add dummy responses
		for i in range(4):
			var dummy_answer = MediaAnswer.new()
			dummy_answer.text = "Test answer %d" % (i + 1)
			GameSetupState.add_interview_response(dummy_answer)

	_load_phase(3)  # Jump to review