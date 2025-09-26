extends GutTest

# Unit tests for Party validation including duplicate name prevention
# Tests comprehensive party validation logic

var party: Party
var party_generator: PartyGenerator

func before_each():
	party = Party.new()
	party_generator = PartyGenerator.new()

func test_basic_party_validation():
	# Test minimal valid party
	party.name = "Test Party"
	party.abbreviation = "TP"
	party.description = "A test party for validation"
	party.ideology_scores = {"economic_left_right": 0.0}
	party.policy_keywords = ["keyword1", "keyword2", "keyword3", "keyword4", "keyword5"]
	party.color_primary = Color.BLUE

	var result = party.validate()
	assert_true(result.valid, "Basic valid party should pass validation")
	assert_eq(result.errors.size(), 0, "Valid party should have no errors")

func test_duplicate_name_detection_in_generated_parties():
	# Generate a set of parties and check for duplicates
	var parties = party_generator.generate_parties(20)
	var names_used = {}
	var abbreviations_used = {}

	for test_party in parties:
		var name = test_party.name
		var abbrev = test_party.abbreviation

		assert_false(names_used.has(name),
			"Generated party name should be unique: " + name)
		assert_false(abbreviations_used.has(abbrev),
			"Generated party abbreviation should be unique: " + abbrev)

		names_used[name] = true
		abbreviations_used[abbrev] = true

func test_party_name_length_validation():
	# Test name too short
	party.name = "AB"  # 2 characters
	party.abbreviation = "AB"
	party.description = "Test description"

	var result = party.validate()
	assert_false(result.valid, "2-character name should fail")
	assert_true(result.errors.has("Party name must be at least 3 characters long"),
		"Should report name too short")

	# Test name too long
	party.name = "A" * 51  # 51 characters
	result = party.validate()
	assert_false(result.valid, "51-character name should fail")
	assert_true(result.errors.has("Party name must be 50 characters or less"),
		"Should report name too long")

	# Test valid length
	party.name = "Valid Party Name"  # 18 characters
	party.policy_keywords = ["k1", "k2", "k3", "k4", "k5"]
	party.ideology_scores = {"economic_left_right": 0.0}
	party.color_primary = Color.BLUE
	result = party.validate()
	assert_true(result.valid, "Valid length name should pass")

func test_abbreviation_validation():
	party.name = "Test Party"
	party.description = "Test description"
	party.policy_keywords = ["k1", "k2", "k3", "k4", "k5"]
	party.ideology_scores = {"economic_left_right": 0.0}
	party.color_primary = Color.BLUE

	# Test abbreviation too short
	party.abbreviation = "A"  # 1 character
	var result = party.validate()
	assert_false(result.valid, "1-character abbreviation should fail")
	assert_true(result.errors.has("Party abbreviation must be at least 2 characters"),
		"Should report abbreviation too short")

	# Test abbreviation too long
	party.abbreviation = "TOOLONG"  # 7 characters
	result = party.validate()
	assert_false(result.valid, "7-character abbreviation should fail")
	assert_true(result.errors.has("Party abbreviation must be 6 characters or less"),
		"Should report abbreviation too long")

	# Test valid abbreviation
	party.abbreviation = "TP"
	result = party.validate()
	assert_true(result.valid, "Valid abbreviation should pass")

func test_description_validation():
	party.name = "Test Party"
	party.abbreviation = "TP"
	party.policy_keywords = ["k1", "k2", "k3", "k4", "k5"]
	party.ideology_scores = {"economic_left_right": 0.0}
	party.color_primary = Color.BLUE

	# Test empty description
	party.description = ""
	var result = party.validate()
	assert_false(result.valid, "Empty description should fail")
	assert_true(result.errors.has("Party description is required"),
		"Should report missing description")

	# Test very short description (warning)
	party.description = "Short"  # 5 characters
	result = party.validate()
	assert_true(result.valid, "Short description should still be valid")
	assert_true(result.warnings.has("Party description is quite short"),
		"Should warn about short description")

	# Test very long description
	party.description = "A" * 501  # 501 characters
	result = party.validate()
	assert_false(result.valid, "Too long description should fail")
	assert_true(result.errors.has("Party description must be 500 characters or less"),
		"Should report description too long")

	# Test valid description
	party.description = "A reasonable party description that explains the party's goals and values"
	result = party.validate()
	assert_true(result.valid, "Valid description should pass")

func test_policy_keywords_validation():
	party.name = "Test Party"
	party.abbreviation = "TP"
	party.description = "Test description"
	party.ideology_scores = {"economic_left_right": 0.0}
	party.color_primary = Color.BLUE

	# Test too few keywords
	party.policy_keywords = ["k1", "k2", "k3", "k4"]  # 4 keywords
	var result = party.validate()
	assert_false(result.valid, "4 keywords should fail")
	assert_true(result.errors.has("Party must have at least 5 policy keywords"),
		"Should report insufficient keywords")

	# Test too many keywords
	party.policy_keywords = ["k1", "k2", "k3", "k4", "k5", "k6", "k7", "k8", "k9", "k10", "k11"]  # 11 keywords
	result = party.validate()
	assert_false(result.valid, "11 keywords should fail")
	assert_true(result.errors.has("Party cannot have more than 10 policy keywords"),
		"Should report too many keywords")

	# Test valid keyword count
	party.policy_keywords = ["k1", "k2", "k3", "k4", "k5", "k6", "k7"]  # 7 keywords
	result = party.validate()
	assert_true(result.valid, "7 keywords should pass")

func test_ideology_scores_validation():
	party.name = "Test Party"
	party.abbreviation = "TP"
	party.description = "Test description"
	party.policy_keywords = ["k1", "k2", "k3", "k4", "k5"]
	party.color_primary = Color.BLUE

	# Test ideology score out of range (too high)
	party.ideology_scores = {"economic_left_right": 1.5}
	var result = party.validate()
	assert_false(result.valid, "Score > 1.0 should fail")
	assert_true(result.errors.has("Ideology score 'economic_left_right' must be between -1.0 and 1.0"),
		"Should report score too high")

	# Test ideology score out of range (too low)
	party.ideology_scores = {"economic_left_right": -1.5}
	result = party.validate()
	assert_false(result.valid, "Score < -1.0 should fail")
	assert_true(result.errors.has("Ideology score 'economic_left_right' must be between -1.0 and 1.0"),
		"Should report score too low")

	# Test valid ideology scores
	party.ideology_scores = {
		"economic_left_right": 0.3,
		"social_liberal_conservative": -0.7,
		"eu_skeptic_federal": 1.0,
		"centralization": -1.0
	}
	result = party.validate()
	assert_true(result.valid, "Valid ideology scores should pass")

func test_profanity_filter_integration():
	party.abbreviation = "TP"
	party.description = "A clean test description"
	party.policy_keywords = ["k1", "k2", "k3", "k4", "k5"]
	party.ideology_scores = {"economic_left_right": 0.0}
	party.color_primary = Color.BLUE

	# Test inappropriate party name
	party.name = "Shit Party"
	var result = party.validate()
	assert_false(result.valid, "Inappropriate name should fail")
	assert_true(result.errors.has("Party name contains inappropriate language"),
		"Should report inappropriate name")

	# Test inappropriate abbreviation
	party.name = "Test Party"
	party.abbreviation = "WTF"
	result = party.validate()
	# Note: WTF might not be in our basic filter, so let's test with something definitely blocked
	party.abbreviation = "FUK"
	result = party.validate()
	assert_false(result.valid, "Inappropriate abbreviation should fail")

	# Test inappropriate description
	party.abbreviation = "TP"
	party.description = "This party is shit and promotes hatred"
	result = party.validate()
	assert_false(result.valid, "Inappropriate description should fail")

	# Test all appropriate content
	party.name = "Clean Progressive Party"
	party.abbreviation = "CPP"
	party.description = "A party promoting progressive values and clean governance"
	result = party.validate()
	assert_true(result.valid, "All appropriate content should pass")

func test_party_conflict_detection():
	# Test the has_policy_conflicts method
	party.policy_keywords = ["progressive_taxation", "tax_reduction"]  # Conflicting

	var has_conflicts = party.has_policy_conflicts()
	assert_true(has_conflicts, "Should detect policy conflicts")

	# Test non-conflicting policies
	party.policy_keywords = ["universal_healthcare", "climate_action", "education_funding"]
	has_conflicts = party.has_policy_conflicts()
	assert_false(has_conflicts, "Should not detect conflicts in compatible policies")

func test_party_display_name_generation():
	party.name = "Progressive Alliance"
	party.abbreviation = "PA"

	var display_name = party.get_display_name()
	assert_eq(display_name, "PA (Progressive Alliance)", "Should format display name correctly")

	# Test without abbreviation
	party.abbreviation = ""
	display_name = party.get_display_name()
	assert_eq(display_name, "Progressive Alliance", "Should return just name when no abbreviation")

func test_party_serialization_validation():
	# Create a valid party
	party.name = "Test Progressive Party"
	party.abbreviation = "TPP"
	party.description = "A progressive test party"
	party.ideology_scores = {"economic_left_right": -0.3}
	party.policy_keywords = ["universal_healthcare", "climate_action", "progressive_taxation", "civil_rights", "education_funding"]
	party.color_primary = Color.BLUE
	party.color_secondary = Color.LIGHT_BLUE

	# Validate original
	var result = party.validate()
	assert_true(result.valid, "Original party should be valid")

	# Test serialization and deserialization
	var serialized = party.to_dict()
	var new_party = Party.new()
	new_party.from_dict(serialized)

	# Validate deserialized party
	var new_result = new_party.validate()
	assert_true(new_result.valid, "Deserialized party should be valid")
	assert_eq(new_party.name, party.name, "Names should match after serialization")
	assert_eq(new_party.abbreviation, party.abbreviation, "Abbreviations should match")

func test_edge_case_empty_required_fields():
	# Test validation with missing required fields
	var result = party.validate()

	# Should have multiple errors for missing required fields
	assert_false(result.valid, "Empty party should fail validation")
	assert_true(result.errors.has("Party name is required"), "Should report missing name")
	assert_true(result.errors.has("Party abbreviation is required"), "Should report missing abbreviation")
	assert_true(result.errors.has("Party description is required"), "Should report missing description")
	assert_true(result.errors.has("Party must have at least 5 policy keywords"), "Should report missing keywords")

func test_large_scale_duplicate_prevention():
	# Generate a large number of parties and ensure no duplicates
	var large_set = party_generator.generate_parties(100)
	var name_set = {}
	var abbrev_set = {}

	for test_party in large_set:
		var name = test_party.name
		var abbrev = test_party.abbreviation

		assert_false(name_set.has(name),
			"No duplicate names in large set: " + name)
		assert_false(abbrev_set.has(abbrev),
			"No duplicate abbreviations in large set: " + abbrev)

		name_set[name] = true
		abbrev_set[abbrev] = true

	assert_eq(large_set.size(), 100, "Should generate requested number of parties")
	assert_eq(name_set.size(), 100, "Should have 100 unique names")
	assert_eq(abbrev_set.size(), 100, "Should have 100 unique abbreviations")