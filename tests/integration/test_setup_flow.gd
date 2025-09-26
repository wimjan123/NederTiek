extends GutTest

# Integration tests for the complete new game setup flow
# Tests the full workflow from party selection to game start

var game_setup_state: GameSetupState
var new_game_flow: NewGameFlow
var test_party: Party
var test_background: LeaderBackground
var test_leader: Leader

func before_each():
	# Get the singleton instance
	game_setup_state = GameSetupState

	# Reset state for each test
	game_setup_state.reset_setup()

	# Create test data
	_create_test_data()

func _create_test_data():
	# Create test party
	test_party = Party.new()
	test_party.name = "Test Progressive Party"
	test_party.abbreviation = "TPP"
	test_party.description = "A test progressive party for integration testing"
	test_party.ideology_scores = {
		"economic_left_right": -0.3,
		"social_conservative_liberal": 0.4
	}
	test_party.policy_keywords = ["universal_healthcare", "climate_action", "progressive_taxation"]
	test_party.color_primary = Color.BLUE
	test_party.color_secondary = Color.LIGHT_BLUE

	# Create test background
	test_background = LeaderBackground.new()
	test_background.name = "Political Activist"
	test_background.description = "Years of grassroots organizing and advocacy"
	test_background.attribute_modifiers = {
		"charisma": 3,
		"integrity": 2,
		"intelligence": 1
	}
	test_background.treasury_modifier = 0.9
	test_background.popularity_modifier = 5.0
	test_background.special_traits = ["Community Organizer"]

	# Create test leader
	test_leader = Leader.new()
	test_leader.first_name = "Alex"
	test_leader.last_name = "Johnson"
	test_leader.age = 42
	test_leader.gender = "Non-binary"
	test_leader.background = test_background

func test_initial_setup_state():
	assert_eq(game_setup_state.current_phase, "party_selection", "Should start in party_selection phase")
	assert_null(game_setup_state.selected_party, "Should have no selected party initially")
	assert_null(game_setup_state.created_leader, "Should have no created leader initially")
	assert_eq(game_setup_state.interview_responses.size(), 0, "Should have no interview responses initially")

func test_party_selection_workflow():
	# Test setting a party
	game_setup_state.set_party(test_party)

	assert_eq(game_setup_state.selected_party, test_party, "Should set the selected party")
	assert_true(game_setup_state.can_advance_from_phase("party_selection"), "Should be able to advance after party selection")

	# Test advancing phase
	game_setup_state.advance_phase()
	assert_eq(game_setup_state.current_phase, "leader_creation", "Should advance to leader_creation phase")

func test_leader_creation_workflow():
	# Set up prerequisites
	game_setup_state.set_party(test_party)
	game_setup_state.advance_phase()  # Move to leader_creation

	# Test setting background
	game_setup_state.set_background(test_background)
	assert_eq(game_setup_state.selected_background, test_background, "Should set the selected background")

	# Test creating leader
	game_setup_state.create_leader(test_leader)
	assert_eq(game_setup_state.created_leader, test_leader, "Should set the created leader")
	assert_true(game_setup_state.can_advance_from_phase("leader_creation"), "Should be able to advance after leader creation")

	# Test advancing phase
	game_setup_state.advance_phase()
	assert_eq(game_setup_state.current_phase, "media_interview", "Should advance to media_interview phase")

func test_media_interview_workflow():
	# Set up prerequisites
	_complete_party_and_leader_phases()

	# Create test interview responses
	var test_answers = [
		_create_test_answer("economic_policy", "progressive_taxation"),
		_create_test_answer("social_policy", "universal_healthcare"),
		_create_test_answer("environmental_policy", "climate_action")
	]

	# Add interview responses
	for answer in test_answers:
		game_setup_state.add_interview_response(answer)

	assert_eq(game_setup_state.interview_responses.size(), 3, "Should have 3 interview responses")
	assert_true(game_setup_state.can_advance_from_phase("media_interview"), "Should be able to advance after interview")

	# Test advancing to final phase
	game_setup_state.advance_phase()
	assert_eq(game_setup_state.current_phase, "review", "Should advance to review phase")

func test_complete_setup_flow():
	# Test the entire flow from start to finish
	assert_eq(game_setup_state.current_phase, "party_selection", "Should start in party_selection")

	# Complete party selection
	game_setup_state.set_party(test_party)
	game_setup_state.advance_phase()
	assert_eq(game_setup_state.current_phase, "leader_creation", "Should be in leader_creation")

	# Complete leader creation
	game_setup_state.set_background(test_background)
	game_setup_state.create_leader(test_leader)
	game_setup_state.advance_phase()
	assert_eq(game_setup_state.current_phase, "media_interview", "Should be in media_interview")

	# Complete interview
	var test_answers = [
		_create_test_answer("economic_policy", "progressive_taxation"),
		_create_test_answer("social_policy", "universal_healthcare"),
		_create_test_answer("environmental_policy", "climate_action")
	]
	for answer in test_answers:
		game_setup_state.add_interview_response(answer)

	game_setup_state.advance_phase()
	assert_eq(game_setup_state.current_phase, "review", "Should be in review phase")

	# Test setup completion
	assert_true(game_setup_state.is_setup_complete(), "Setup should be complete")

func test_back_navigation():
	# Move through phases
	game_setup_state.set_party(test_party)
	game_setup_state.advance_phase()  # -> leader_creation
	game_setup_state.set_background(test_background)
	game_setup_state.create_leader(test_leader)
	game_setup_state.advance_phase()  # -> media_interview

	assert_eq(game_setup_state.current_phase, "media_interview", "Should be in media_interview")

	# Test going back
	game_setup_state.go_back()
	assert_eq(game_setup_state.current_phase, "leader_creation", "Should go back to leader_creation")

	game_setup_state.go_back()
	assert_eq(game_setup_state.current_phase, "party_selection", "Should go back to party_selection")

	# Test that data is preserved
	assert_eq(game_setup_state.selected_party, test_party, "Party selection should be preserved")
	assert_eq(game_setup_state.created_leader, test_leader, "Leader should be preserved")

func test_data_persistence():
	# Complete full setup
	_complete_full_setup()

	# Test save functionality
	var save_data = game_setup_state.save_setup_state()
	assert_true(save_data.has("party"), "Save data should include party")
	assert_true(save_data.has("leader"), "Save data should include leader")
	assert_true(save_data.has("background"), "Save data should include background")
	assert_true(save_data.has("interview_responses"), "Save data should include interview responses")

	# Reset and load
	game_setup_state.reset_setup()
	assert_null(game_setup_state.selected_party, "Should be reset")

	game_setup_state.load_setup_state(save_data)
	assert_not_null(game_setup_state.selected_party, "Should restore party")
	assert_eq(game_setup_state.selected_party.name, test_party.name, "Should restore correct party")
	assert_not_null(game_setup_state.created_leader, "Should restore leader")
	assert_eq(game_setup_state.interview_responses.size(), 3, "Should restore interview responses")

func test_game_start_compilation():
	_complete_full_setup()

	var game_data = game_setup_state.compile_game_start_data()

	assert_true(game_data.has("party"), "Game data should include party")
	assert_true(game_data.has("leader"), "Game data should include leader")
	assert_true(game_data.has("starting_attributes"), "Game data should include starting attributes")
	assert_true(game_data.has("starting_treasury"), "Game data should include starting treasury")
	assert_true(game_data.has("starting_popularity"), "Game data should include starting popularity")

	# Verify calculated values
	var starting_attrs = game_data["starting_attributes"]
	assert_true(starting_attrs.has("charisma"), "Should calculate charisma attribute")
	assert_true(starting_attrs.has("integrity"), "Should calculate integrity attribute")

func test_validation_across_phases():
	# Test that phase validation works correctly
	assert_false(game_setup_state.can_advance_from_phase("party_selection"), "Should not advance without party")

	game_setup_state.set_party(test_party)
	assert_true(game_setup_state.can_advance_from_phase("party_selection"), "Should advance with party")

	game_setup_state.advance_phase()
	assert_false(game_setup_state.can_advance_from_phase("leader_creation"), "Should not advance without leader")

	game_setup_state.set_background(test_background)
	game_setup_state.create_leader(test_leader)
	assert_true(game_setup_state.can_advance_from_phase("leader_creation"), "Should advance with leader")

func test_signal_emissions():
	var signal_watcher = SignalWatcher.new()
	add_child_autofree(signal_watcher)

	signal_watcher.watch_signals(game_setup_state)

	# Test phase change signal
	game_setup_state.set_party(test_party)
	game_setup_state.advance_phase()

	assert_signal_emitted(game_setup_state, "setup_phase_changed", "Should emit phase changed signal")

	# Test data update signals
	game_setup_state.set_background(test_background)
	assert_signal_emitted(game_setup_state, "party_data_updated", "Should emit party data updated signal")

func _complete_party_and_leader_phases():
	game_setup_state.set_party(test_party)
	game_setup_state.advance_phase()
	game_setup_state.set_background(test_background)
	game_setup_state.create_leader(test_leader)
	game_setup_state.advance_phase()

func _complete_full_setup():
	_complete_party_and_leader_phases()

	# Add interview responses
	var test_answers = [
		_create_test_answer("economic_policy", "progressive_taxation"),
		_create_test_answer("social_policy", "universal_healthcare"),
		_create_test_answer("environmental_policy", "climate_action")
	]
	for answer in test_answers:
		game_setup_state.add_interview_response(answer)

	game_setup_state.advance_phase()

func _create_test_answer(question_id: String, keyword: String) -> MediaAnswer:
	var answer = MediaAnswer.new()
	answer.question_id = question_id
	answer.response_text = "Test response"
	answer.policy_keyword = keyword
	answer.attribute_effects = {"charisma": 1}
	answer.popularity_effect = 2.0
	return answer