extends Node

# GameSetupState - Singleton autoload for managing new game setup flow
# This persists across scene changes and coordinates the entire setup process

# Current setup data
var selected_party: Party
var custom_party_data: Dictionary = {}
var selected_background: LeaderBackground
var leader: Leader
var interview_responses: Array = []
var setup_complete: bool = false

# Current phase tracking
var current_phase: String = "party_selection"
var previous_phase: String = ""

# Generated data cache
var generated_parties: Array = []
var available_backgrounds: Array = []
var question_pool: Array = []

# Flow control signals
signal setup_phase_changed(phase: String)
signal setup_completed(game_data: Dictionary)
signal setup_cancelled()

# Data update signals
signal party_data_updated(party: Party)
signal leader_data_updated(leader: Leader)
signal treasury_calculated(amount: int)
signal popularity_calculated(percentage: float)

# Error handling signals
signal validation_error(field: String, message: String)
signal system_error(error_code: String, message: String)
signal data_load_error(resource_path: String, error: String)

func _ready():
	# Initialize the setup state
	reset()

	# Load background data
	_load_backgrounds()

# Reset all setup data to start fresh
func reset():
	selected_party = null
	custom_party_data.clear()
	selected_background = null
	leader = null
	interview_responses.clear()
	setup_complete = false
	current_phase = "party_selection"
	previous_phase = ""

	print("GameSetupState: Reset to initial state")

# Advance to the next phase of setup
func advance_phase():
	previous_phase = current_phase

	match current_phase:
		"party_selection":
			if selected_party != null:
				current_phase = "leader_creation"
				setup_phase_changed.emit(current_phase)
			else:
				validation_error.emit("party", "No party selected")

		"leader_creation":
			if leader != null and selected_background != null:
				current_phase = "media_interview"
				setup_phase_changed.emit(current_phase)
			else:
				validation_error.emit("leader", "Leader not fully created")

		"media_interview":
			if interview_responses.size() >= 4:  # Minimum 4 questions
				current_phase = "review"
				_finalize_setup()
				setup_phase_changed.emit(current_phase)
			else:
				validation_error.emit("interview", "Interview not complete")

		"review":
			current_phase = "complete"
			setup_complete = true
			var game_data = compile_game_start_data()
			setup_completed.emit(game_data)

		_:
			system_error.emit("ERR_INVALID_PHASE", "Cannot advance from phase: " + current_phase)

# Go back to the previous phase
func go_back():
	if previous_phase.length() > 0:
		var temp = current_phase
		current_phase = previous_phase
		previous_phase = temp
		setup_phase_changed.emit(current_phase)
		print("GameSetupState: Went back to phase: " + current_phase)
	else:
		print("GameSetupState: No previous phase to go back to")

# Set the selected party (from existing or custom)
func set_party(party: Party):
	if party == null:
		validation_error.emit("party", "Cannot set null party")
		return

	var validation = party.validate()
	if not validation["valid"]:
		validation_error.emit("party", "Invalid party: " + str(validation["errors"]))
		return

	selected_party = party
	party_data_updated.emit(party)
	print("GameSetupState: Party set - " + party.get_display_name())

# Create and set a custom party
func create_custom_party(party_data: Dictionary):
	var party = Party.new()
	party.id = "custom_" + str(Time.get_unix_time_from_system())
	party.name = party_data.get("name", "")
	party.abbreviation = party_data.get("abbreviation", "")
	party.description = party_data.get("description", "Custom party created by player")
	party.policy_keywords = party_data.get("policy_keywords", [])
	party.color_primary = party_data.get("color_primary", Color.BLUE)
	party.color_secondary = party_data.get("color_secondary", Color.LIGHT_BLUE)
	party.is_custom = true

	# Calculate ideology scores based on policy keywords
	_calculate_party_ideology(party)

	set_party(party)

# Set the selected background and update leader
func set_background(background: LeaderBackground):
	if background == null:
		validation_error.emit("background", "Cannot set null background")
		return

	selected_background = background

	# Update leader if it exists
	if leader != null:
		leader.background_id = background.id
		leader.apply_attribute_modifier(background.attribute_modifiers)
		leader_data_updated.emit(leader)

	print("GameSetupState: Background set - " + background.name)

# Create the leader with basic information
func create_leader(first_name: String, last_name: String):
	leader = Leader.new()
	leader.id = "leader_" + str(Time.get_unix_time_from_system())
	leader.first_name = first_name
	leader.last_name = last_name

	if selected_party != null:
		leader.party_id = selected_party.id

	if selected_background != null:
		leader.background_id = selected_background.id
		leader.apply_attribute_modifier(selected_background.attribute_modifiers)

	var validation = leader.validate()
	if not validation["valid"]:
		validation_error.emit("leader", "Invalid leader: " + str(validation["errors"]))
		return

	leader_data_updated.emit(leader)
	print("GameSetupState: Leader created - " + leader.get_full_name())

# Add an interview response
func add_interview_response(answer: MediaAnswer):
	if answer == null:
		validation_error.emit("interview", "Cannot add null answer")
		return

	interview_responses.append(answer)

	# Apply answer to leader if possible
	if leader != null:
		answer.apply_to_leader(leader)
		leader_data_updated.emit(leader)

	print("GameSetupState: Interview response added (" + str(interview_responses.size()) + " total)")

# Finalize setup by calculating final values
func _finalize_setup():
	if leader == null or selected_party == null or selected_background == null:
		system_error.emit("ERR_INCOMPLETE_SETUP", "Cannot finalize incomplete setup")
		return

	# Calculate final treasury
	var setup_data_manager = SetupDataManager.new()
	var final_treasury = setup_data_manager.calculate_treasury(leader, selected_party, interview_responses)
	leader.starting_treasury = final_treasury
	treasury_calculated.emit(final_treasury)

	# Calculate final popularity
	var final_popularity = setup_data_manager.calculate_popularity(leader, selected_party, interview_responses)
	leader.starting_popularity = final_popularity
	popularity_calculated.emit(final_popularity)

	# Apply background modifiers to final values
	leader.starting_treasury = int(leader.starting_treasury * selected_background.treasury_modifier)
	leader.starting_popularity = clamp(leader.starting_popularity + selected_background.popularity_modifier, 0.0, 100.0)

	print("GameSetupState: Setup finalized - Treasury: €%d, Popularity: %.1f%%" % [leader.starting_treasury, leader.starting_popularity])

# Compile all setup data into a game start configuration
func compile_game_start_data() -> Dictionary:
	if not setup_complete:
		print("Warning: Compiling game data before setup is complete")

	return {
		"party": selected_party,
		"leader": leader,
		"background": selected_background,
		"interview_responses": interview_responses,
		"starting_date": Time.get_datetime_dict_from_system(),
		"difficulty_modifiers": {},  # Placeholder for future difficulty settings
		"setup_metadata": {
			"version": "0.1.0",
			"created_timestamp": Time.get_unix_time_from_system(),
			"total_responses": interview_responses.size()
		}
	}

# Load background data from resources
func _load_backgrounds():
	available_backgrounds.clear()

	# Create the 8 standard backgrounds using static methods
	available_backgrounds.append(LeaderBackground.create_career_politician())
	available_backgrounds.append(LeaderBackground.create_business_executive())
	available_backgrounds.append(LeaderBackground.create_academic())
	available_backgrounds.append(LeaderBackground.create_activist())
	available_backgrounds.append(LeaderBackground.create_media_personality())
	available_backgrounds.append(LeaderBackground.create_local_administrator())
	available_backgrounds.append(LeaderBackground.create_union_leader())
	available_backgrounds.append(LeaderBackground.create_military_security())

	print("GameSetupState: Loaded %d backgrounds" % available_backgrounds.size())

# Calculate party ideology based on policy keywords
func _calculate_party_ideology(party: Party):
	# Initialize all scores to zero
	for ideology_key in party.ideology_scores.keys():
		party.ideology_scores[ideology_key] = 0.0

	# This would be expanded with actual policy keyword impacts
	# For now, just set some reasonable defaults based on keywords
	var keyword_count = party.policy_keywords.size()
	if keyword_count > 0:
		# Simple heuristic based on common keywords
		for keyword in party.policy_keywords:
			match keyword.to_lower():
				"progressive_taxation", "universal_healthcare", "welfare_expansion":
					party.ideology_scores["economic_left_right"] += -0.2
				"free_market", "tax_cuts", "deregulation":
					party.ideology_scores["economic_left_right"] += 0.2
				"traditional_values", "law_and_order":
					party.ideology_scores["social_liberal_conservative"] += 0.2
				"progressive_values", "civil_rights":
					party.ideology_scores["social_liberal_conservative"] += -0.2
				"eu_integration", "european_cooperation":
					party.ideology_scores["eu_skeptic_federal"] += 0.2
				"national_sovereignty", "eu_skepticism":
					party.ideology_scores["eu_skeptic_federal"] += -0.2

		# Normalize scores to stay within bounds
		for ideology_key in party.ideology_scores.keys():
			party.ideology_scores[ideology_key] = clamp(party.ideology_scores[ideology_key], -1.0, 1.0)

# Get the current phase for UI display
func get_current_phase() -> String:
	return current_phase

# Check if we can advance to the next phase
func can_advance() -> bool:
	match current_phase:
		"party_selection":
			return selected_party != null
		"leader_creation":
			return leader != null and selected_background != null
		"media_interview":
			return interview_responses.size() >= 4
		"review":
			return true
		_:
			return false

# Get setup progress as a percentage
func get_setup_progress() -> float:
	var total_phases = 4.0  # party, leader, interview, review
	var completed_phases = 0.0

	if selected_party != null:
		completed_phases += 1.0
	if leader != null and selected_background != null:
		completed_phases += 1.0
	if interview_responses.size() >= 4:
		completed_phases += 1.0
	if setup_complete:
		completed_phases += 1.0

	return (completed_phases / total_phases) * 100.0

# Save setup state for resuming later
func save_setup_state() -> Dictionary:
	return {
		"current_phase": current_phase,
		"selected_party": selected_party,
		"custom_party_data": custom_party_data,
		"selected_background": selected_background,
		"leader": leader,
		"interview_responses": interview_responses,
		"timestamp": Time.get_unix_time_from_system()
	}

# Load previously saved setup state
func load_setup_state(state_data: Dictionary):
	if state_data.has("current_phase"):
		current_phase = state_data["current_phase"]
	if state_data.has("selected_party"):
		selected_party = state_data["selected_party"]
	if state_data.has("custom_party_data"):
		custom_party_data = state_data["custom_party_data"]
	if state_data.has("selected_background"):
		selected_background = state_data["selected_background"]
	if state_data.has("leader"):
		leader = state_data["leader"]
	if state_data.has("interview_responses"):
		interview_responses = state_data["interview_responses"]

	print("GameSetupState: Loaded setup state for phase: " + current_phase)