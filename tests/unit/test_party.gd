extends GutTest

# Unit tests for Party model
# Tests party creation, validation, and behavior

var party: Party

func before_each():
	party = Party.new()

func test_party_initialization():
	assert_eq(party.name, "", "Party name should be empty on initialization")
	assert_eq(party.abbreviation, "", "Party abbreviation should be empty on initialization")
	assert_eq(party.ideology_scores.size(), 0, "Ideology scores should be empty on initialization")
	assert_eq(party.policy_keywords.size(), 0, "Policy keywords should be empty on initialization")

func test_party_display_name():
	party.name = "Test Party"
	party.abbreviation = "TP"

	assert_eq(party.get_display_name(), "Test Party (TP)", "Display name should combine name and abbreviation")

	party.abbreviation = ""
	assert_eq(party.get_display_name(), "Test Party", "Display name should return just name when no abbreviation")

func test_party_validation_success():
	party.name = "Progressive Alliance"
	party.abbreviation = "PA"
	party.description = "A forward-thinking progressive party"
	party.ideology_scores = {
		"economic_left_right": -0.3,
		"social_conservative_liberal": 0.4
	}
	party.policy_keywords = ["universal_healthcare", "climate_action"]
	party.color_primary = Color.BLUE
	party.color_secondary = Color.LIGHT_BLUE

	var result = party.validate()
	assert_true(result.valid, "Valid party should pass validation")
	assert_eq(result.errors.size(), 0, "Valid party should have no errors")

func test_party_validation_missing_name():
	party.abbreviation = "PA"
	party.description = "Test description"

	var result = party.validate()
	assert_false(result.valid, "Party without name should fail validation")
	assert_true(result.errors.has("Party name is required"), "Should report missing name error")

func test_party_validation_missing_abbreviation():
	party.name = "Progressive Alliance"
	party.description = "Test description"

	var result = party.validate()
	assert_false(result.valid, "Party without abbreviation should fail validation")
	assert_true(result.errors.has("Party abbreviation is required"), "Should report missing abbreviation error")

func test_party_validation_missing_description():
	party.name = "Progressive Alliance"
	party.abbreviation = "PA"

	var result = party.validate()
	assert_false(result.valid, "Party without description should fail validation")
	assert_true(result.errors.has("Party description is required"), "Should report missing description error")

func test_party_validation_ideology_scores():
	party.name = "Test Party"
	party.abbreviation = "TP"
	party.description = "Test description"
	party.ideology_scores = {
		"economic_left_right": 1.5  # Out of range
	}

	var result = party.validate()
	assert_false(result.valid, "Party with out-of-range ideology scores should fail validation")
	assert_true(result.errors.has("Ideology score 'economic_left_right' must be between -1.0 and 1.0"),
		"Should report out-of-range ideology score error")

func test_party_policy_conflicts():
	party.policy_keywords = ["progressive_taxation", "tax_reduction"]

	var has_conflicts = party.has_policy_conflicts()
	assert_true(has_conflicts, "Party with conflicting policies should detect conflicts")

func test_party_no_policy_conflicts():
	party.policy_keywords = ["universal_healthcare", "climate_action"]

	var has_conflicts = party.has_policy_conflicts()
	assert_false(has_conflicts, "Party with compatible policies should not detect conflicts")

func test_party_serialization():
	party.name = "Green Future"
	party.abbreviation = "GF"
	party.description = "Environmental party"
	party.ideology_scores = {"economic_left_right": -0.2}
	party.policy_keywords = ["climate_action", "green_energy_transition"]
	party.color_primary = Color.GREEN

	var serialized = party.to_dict()

	assert_eq(serialized["name"], "Green Future", "Serialized name should match")
	assert_eq(serialized["abbreviation"], "GF", "Serialized abbreviation should match")
	assert_eq(serialized["description"], "Environmental party", "Serialized description should match")
	assert_eq(serialized["ideology_scores"]["economic_left_right"], -0.2, "Serialized ideology scores should match")
	assert_eq(serialized["policy_keywords"].size(), 2, "Serialized policy keywords should match")

func test_party_deserialization():
	var data = {
		"name": "Liberal Democrats",
		"abbreviation": "LD",
		"description": "Liberal democratic party",
		"ideology_scores": {"economic_left_right": 0.1},
		"policy_keywords": ["democratic_reform", "civil_rights"],
		"color_primary": Color.YELLOW
	}

	party.from_dict(data)

	assert_eq(party.name, "Liberal Democrats", "Deserialized name should match")
	assert_eq(party.abbreviation, "LD", "Deserialized abbreviation should match")
	assert_eq(party.description, "Liberal democratic party", "Deserialized description should match")
	assert_eq(party.ideology_scores["economic_left_right"], 0.1, "Deserialized ideology scores should match")
	assert_eq(party.policy_keywords.size(), 2, "Deserialized policy keywords should match")

func test_party_equality():
	var party1 = Party.new()
	party1.name = "Test Party"
	party1.abbreviation = "TP"

	var party2 = Party.new()
	party2.name = "Test Party"
	party2.abbreviation = "TP"

	var party3 = Party.new()
	party3.name = "Different Party"
	party3.abbreviation = "DP"

	assert_true(party1.equals(party2), "Parties with same data should be equal")
	assert_false(party1.equals(party3), "Parties with different data should not be equal")

func test_party_ideology_classification():
	party.ideology_scores = {"economic_left_right": -0.5}
	assert_eq(party.get_ideology_label(), "Left-wing", "Should classify left-wing correctly")

	party.ideology_scores = {"economic_left_right": 0.5}
	assert_eq(party.get_ideology_label(), "Right-wing", "Should classify right-wing correctly")

	party.ideology_scores = {"economic_left_right": 0.0}
	assert_eq(party.get_ideology_label(), "Centrist", "Should classify centrist correctly")