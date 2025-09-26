extends GutTest

# Validation tests based on quickstart.md scenarios
# Tests the complete user workflows described in the quickstart guide

var game_setup_state: GameSetupState
var party_generator: PartyGenerator

func before_each():
	game_setup_state = GameSetupState
	game_setup_state.reset_setup()
	party_generator = PartyGenerator.new()

# Scenario 1: Launch Game & Start New Game
func test_launch_and_start_new_game():
	# Test initial state
	assert_eq(game_setup_state.current_phase, "party_selection",
		"Should start in party selection phase")
	assert_null(game_setup_state.selected_party,
		"Should have no selected party initially")

# Scenario 2: Test Party Selection - Browse Generated Parties
func test_browse_generated_parties():
	var parties = party_generator.generate_parties(20)

	# Verify we have ~20 parties
	assert_eq(parties.size(), 20, "Should generate 20 parties")

	# Verify each party has required display elements
	for party in parties:
		assert_ne(party.name, "", "Party should have name")
		assert_ne(party.abbreviation, "", "Party should have abbreviation")
		assert_ne(party.description, "", "Party should have full description")
		assert_true(party.policy_keywords.size() >= 3, "Party should have policy positions")
		assert_not_null(party.color_primary, "Party should have color identity")

	# Test selecting a party (VVD equivalent)
	var test_party = parties[0]  # Use first party as test
	game_setup_state.set_party(test_party)

	assert_eq(game_setup_state.selected_party, test_party, "Should select the party")
	assert_true(game_setup_state.can_advance_from_phase("party_selection"),
		"Should be able to continue with selected party")

# Scenario 3: Test Party Selection - Create Custom Party
func test_create_custom_party():
	var custom_party = Party.new()
	custom_party.name = "Test Partij"
	custom_party.abbreviation = "TP"
	custom_party.description = "Test party description"

	# Select exactly 7 policy keywords across categories as specified
	custom_party.policy_keywords = [
		# 2 Economic policies
		"progressive_taxation", "business_friendly_policy",
		# 2 Social policies
		"universal_healthcare", "civil_rights",
		# 2 Environmental policies
		"green_energy_transition", "climate_action",
		# 1 EU policy
		"eu_integration"
	]

	custom_party.ideology_scores = {
		"economic_left_right": -0.2,
		"social_conservative_liberal": 0.3
	}
	custom_party.color_primary = Color.GREEN
	custom_party.color_secondary = Color.LIGHT_GREEN

	# Test validation passes
	var validation = custom_party.validate()
	assert_true(validation.valid, "Custom party should pass validation: " + str(validation.errors))

	# Test party creation workflow
	game_setup_state.set_party(custom_party)
	assert_eq(game_setup_state.selected_party, custom_party, "Should set custom party")

	# Test proceeding to leader creation
	game_setup_state.advance_phase()
	assert_eq(game_setup_state.current_phase, "leader_creation",
		"Should proceed to leader creation")

# Scenario 4: Test Leader Creation
func test_leader_creation():
	# Set up prerequisites
	_setup_test_party()
	game_setup_state.advance_phase()  # Move to leader_creation

	# Create leader background options - should have 8 backgrounds
	var background_types = [
		"Career Politician", "Business Executive", "Academic/Professor",
		"Activist/NGO Leader", "Media Personality", "Local Administrator",
		"Union Leader", "Military/Security Background"
	]

	# Test Business Executive background selection
	var business_background = LeaderBackground.new()
	business_background.name = "Business Executive"
	business_background.description = "Experience in corporate leadership and management"
	business_background.attribute_modifiers = {
		"charisma": 2,
		"intelligence": 3,
		"experience": 4,
		"integrity": -1
	}
	business_background.treasury_modifier = 1.3  # Better starting funds
	business_background.popularity_modifier = -2.0  # Less popular initially

	game_setup_state.set_background(business_background)
	assert_eq(game_setup_state.selected_background, business_background,
		"Should set business background")

	# Create leader with Dutch name
	var leader = Leader.new()
	leader.first_name = "Jan"
	leader.last_name = "de Vries"
	leader.age = 45
	leader.gender = "Male"
	leader.background = business_background

	var leader_validation = leader.validate()
	assert_true(leader_validation.valid, "Leader should be valid: " + str(leader_validation.errors))

	game_setup_state.create_leader(leader)
	assert_eq(game_setup_state.created_leader, leader, "Should create leader")

	# Test proceeding to media interview
	game_setup_state.advance_phase()
	assert_eq(game_setup_state.current_phase, "media_interview",
		"Should proceed to media interview")

# Scenario 5: Test Media Interview
func test_media_interview():
	# Set up prerequisites
	_setup_full_prerequisites()

	# Create 4-6 contextual questions
	var interview_responses = [
		_create_test_response("economic_policy", "business_friendly_policy", {"experience": 1}, 1.0),
		_create_test_response("social_policy", "civil_rights", {"charisma": 1}, 2.0),
		_create_test_response("environmental_policy", "sustainable_development", {"intelligence": 1}, 1.5),
		_create_test_response("eu_policy", "eu_integration", {"experience": 1}, 1.0),
		_create_test_response("leadership_style", "transparency", {"integrity": 2}, 3.0)
	]

	# Add responses to setup state
	for response in interview_responses:
		game_setup_state.add_interview_response(response)

	assert_eq(game_setup_state.interview_responses.size(), 5,
		"Should have 5 interview responses")

	# Test advancing to review
	game_setup_state.advance_phase()
	assert_eq(game_setup_state.current_phase, "review", "Should proceed to review")

	# Test final game data compilation
	var game_data = game_setup_state.compile_game_start_data()

	# Verify summary data
	assert_true(game_data.has("starting_attributes"), "Should have final leader attributes")
	assert_true(game_data.has("starting_treasury"), "Should have starting treasury")
	assert_true(game_data.has("starting_popularity"), "Should have initial popularity")

	# Verify treasury range (€10,000 - €1,000,000)
	var treasury = game_data["starting_treasury"]
	assert_true(treasury >= 10000 and treasury <= 1000000,
		"Treasury should be in range €10,000 - €1,000,000: " + str(treasury))

	# Verify popularity range (5% - 25%)
	var popularity = game_data["starting_popularity"]
	assert_true(popularity >= 5.0 and popularity <= 25.0,
		"Popularity should be in range 5% - 25%: " + str(popularity))

# Scenario 6: Test Navigation
func test_back_navigation():
	# Set up complete flow
	_setup_full_prerequisites()

	# Add interview response
	var response = _create_test_response("test", "test_policy", {}, 0.0)
	game_setup_state.add_interview_response(response)
	game_setup_state.advance_phase()  # Move to review

	assert_eq(game_setup_state.current_phase, "review", "Should be in review")

	# Test going back through phases
	game_setup_state.go_back()
	assert_eq(game_setup_state.current_phase, "media_interview", "Should go back to interview")

	game_setup_state.go_back()
	assert_eq(game_setup_state.current_phase, "leader_creation", "Should go back to leader creation")

	game_setup_state.go_back()
	assert_eq(game_setup_state.current_phase, "party_selection", "Should go back to party selection")

	# Verify data is preserved
	assert_not_null(game_setup_state.selected_party, "Party should be preserved")
	assert_not_null(game_setup_state.created_leader, "Leader should be preserved")
	assert_eq(game_setup_state.interview_responses.size(), 1,
		"Interview responses should be preserved")

# Scenario 7: Test Edge Cases
func test_invalid_party_name():
	var party = Party.new()

	# Test too short name
	party.name = "X"
	party.abbreviation = "X"
	party.description = "Test"

	var validation = party.validate()
	assert_false(validation.valid, "Single character party name should fail validation")
	assert_true(validation.errors.has("Party name must be at least 3 characters long"),
		"Should report name too short error")

	# Test too long name (51+ characters)
	party.name = "A" * 51  # 51 characters
	validation = party.validate()
	assert_false(validation.valid, "51+ character party name should fail validation")

func test_insufficient_keywords():
	var party = Party.new()
	party.name = "Test Party"
	party.abbreviation = "TP"
	party.description = "Test description"
	party.policy_keywords = ["keyword1", "keyword2", "keyword3"]  # Only 3 keywords
	party.ideology_scores = {"economic_left_right": 0.0}
	party.color_primary = Color.BLUE

	var validation = party.validate()
	assert_false(validation.valid, "Party with <5 keywords should fail validation")
	assert_true(validation.errors.has("Party must have at least 5 policy keywords"),
		"Should report insufficient keywords error")

func test_conflicting_keywords():
	var party = Party.new()
	party.name = "Test Party"
	party.abbreviation = "TP"
	party.description = "Test description"
	party.policy_keywords = [
		"free_market_economy", "wealth_redistribution",  # Conflicting
		"universal_healthcare", "climate_action", "civil_rights"
	]
	party.ideology_scores = {"economic_left_right": 0.0}
	party.color_primary = Color.BLUE

	assert_true(party.has_policy_conflicts(), "Should detect conflicting keywords")

# Scenario 8: Test Save & Load
func test_save_and_load():
	# Complete full setup
	_setup_full_prerequisites()
	var response = _create_test_response("test", "test_policy", {"charisma": 1}, 1.0)
	game_setup_state.add_interview_response(response)
	game_setup_state.advance_phase()

	# Test save functionality
	var save_data = game_setup_state.save_setup_state()
	assert_true(save_data.has("party"), "Save data should include party")
	assert_true(save_data.has("leader"), "Save data should include leader")
	assert_true(save_data.has("background"), "Save data should include background")
	assert_true(save_data.has("interview_responses"), "Save data should include responses")

	# Store original data for comparison
	var original_party_name = game_setup_state.selected_party.name
	var original_leader_name = game_setup_state.created_leader.get_full_name()

	# Reset and test load
	game_setup_state.reset_setup()
	assert_null(game_setup_state.selected_party, "Should be reset")

	game_setup_state.load_setup_state(save_data)
	assert_not_null(game_setup_state.selected_party, "Should restore party")
	assert_eq(game_setup_state.selected_party.name, original_party_name,
		"Should restore correct party data")
	assert_not_null(game_setup_state.created_leader, "Should restore leader")
	assert_eq(game_setup_state.created_leader.get_full_name(), original_leader_name,
		"Should restore correct leader data")

# Helper functions
func _setup_test_party():
	var party = Party.new()
	party.name = "Test Progressive Party"
	party.abbreviation = "TPP"
	party.description = "A test progressive party"
	party.ideology_scores = {"economic_left_right": -0.2}
	party.policy_keywords = ["universal_healthcare", "climate_action", "progressive_taxation",
		"civil_rights", "eu_integration"]
	party.color_primary = Color.BLUE
	party.color_secondary = Color.LIGHT_BLUE

	game_setup_state.set_party(party)

func _setup_full_prerequisites():
	_setup_test_party()
	game_setup_state.advance_phase()  # -> leader_creation

	var background = LeaderBackground.new()
	background.name = "Business Executive"
	background.attribute_modifiers = {"charisma": 2, "intelligence": 3}
	background.treasury_modifier = 1.2
	background.popularity_modifier = -1.0

	var leader = Leader.new()
	leader.first_name = "Jan"
	leader.last_name = "de Vries"
	leader.age = 45
	leader.gender = "Male"
	leader.background = background

	game_setup_state.set_background(background)
	game_setup_state.create_leader(leader)
	game_setup_state.advance_phase()  # -> media_interview

func _create_test_response(question_id: String, keyword: String,
	attributes: Dictionary, popularity: float) -> MediaAnswer:
	var answer = MediaAnswer.new()
	answer.question_id = question_id
	answer.response_text = "Test response for " + question_id
	answer.policy_keyword = keyword
	answer.attribute_effects = attributes
	answer.popularity_effect = popularity
	return answer