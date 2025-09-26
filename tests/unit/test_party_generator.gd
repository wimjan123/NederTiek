extends GutTest

# Unit tests for PartyGenerator
# Tests party generation logic and template usage

var generator: PartyGenerator

func before_each():
	generator = PartyGenerator.new()

func test_generator_initialization():
	assert_not_null(generator, "Generator should initialize")
	assert_true(generator.templates.size() > 0, "Generator should load templates")

func test_generate_parties_count():
	var parties = generator.generate_parties(5)
	assert_eq(parties.size(), 5, "Should generate requested number of parties")

func test_generate_default_count():
	var parties = generator.generate_parties()
	assert_eq(parties.size(), 20, "Should generate default 20 parties when no count specified")

func test_generated_parties_are_valid():
	var parties = generator.generate_parties(3)

	for party in parties:
		assert_not_null(party, "Generated party should not be null")
		assert_true(party is Party, "Generated item should be Party instance")

		var validation = party.validate()
		assert_true(validation.valid, "Generated party should be valid: " + str(validation.errors))

func test_generated_parties_are_unique():
	var parties = generator.generate_parties(10)
	var names = []

	for party in parties:
		assert_false(names.has(party.name), "Party names should be unique: " + party.name)
		names.append(party.name)

func test_generated_parties_have_required_fields():
	var parties = generator.generate_parties(3)

	for party in parties:
		assert_ne(party.name, "", "Generated party should have a name")
		assert_ne(party.abbreviation, "", "Generated party should have an abbreviation")
		assert_ne(party.description, "", "Generated party should have a description")
		assert_true(party.ideology_scores.size() > 0, "Generated party should have ideology scores")
		assert_true(party.policy_keywords.size() >= 3, "Generated party should have at least 3 policy keywords")

func test_ideology_score_ranges():
	var parties = generator.generate_parties(10)

	for party in parties:
		for score_key in party.ideology_scores.keys():
			var score = party.ideology_scores[score_key]
			assert_true(score >= -1.0 and score <= 1.0,
				"Ideology score %s should be in range [-1.0, 1.0]: %f" % [score_key, score])

func test_policy_keyword_validity():
	var parties = generator.generate_parties(5)

	# Get all available keywords from the generator
	var all_keywords = []
	for template in generator.templates:
		for keyword in template.get("typical_keywords", []):
			if not all_keywords.has(keyword):
				all_keywords.append(keyword)

	for party in parties:
		for keyword in party.policy_keywords:
			assert_true(all_keywords.has(keyword),
				"Policy keyword should be from available set: " + keyword)

func test_party_colors_are_set():
	var parties = generator.generate_parties(3)

	for party in parties:
		assert_not_null(party.color_primary, "Generated party should have primary color")
		assert_not_null(party.color_secondary, "Generated party should have secondary color")
		assert_ne(party.color_primary, Color.WHITE, "Primary color should not be default white")

func test_template_coverage():
	var parties = generator.generate_parties(16)  # 2x number of templates
	var template_usage = {}

	# Count how many parties use each template
	for party in parties:
		var party_type = _identify_party_type(party)
		if party_type != "":
			template_usage[party_type] = template_usage.get(party_type, 0) + 1

	assert_true(template_usage.size() >= 6, "Should use multiple different templates")

func _identify_party_type(party: Party) -> String:
	# Simplified template identification based on policy keywords
	var keywords = party.policy_keywords

	if keywords.has("progressive_taxation") or keywords.has("wealth_redistribution"):
		return "social_democratic"
	elif keywords.has("free_market_economy") or keywords.has("business_friendly_policy"):
		return "liberal"
	elif keywords.has("traditional_values"):
		return "conservative"
	elif keywords.has("green_energy_transition") or keywords.has("climate_action"):
		return "green"
	elif keywords.has("universal_basic_income"):
		return "progressive"
	elif keywords.has("eu_integration"):
		return "pro_eu"

	return ""

func test_dutch_political_context():
	var parties = generator.generate_parties(10)
	var has_eu_keywords = false
	var has_dutch_relevant_policies = false

	for party in parties:
		for keyword in party.policy_keywords:
			if keyword in ["eu_integration", "national_sovereignty"]:
				has_eu_keywords = true
			if keyword in ["social_housing", "development_aid", "direct_democracy"]:
				has_dutch_relevant_policies = true

	assert_true(has_eu_keywords, "Generated parties should include EU-related policies")
	assert_true(has_dutch_relevant_policies, "Generated parties should include Dutch-relevant policies")

func test_policy_conflict_avoidance():
	var parties = generator.generate_parties(20)

	for party in parties:
		assert_false(party.has_policy_conflicts(),
			"Generated party should not have conflicting policies: " + party.name)

func test_template_loading():
	# Test that templates are properly loaded and structured
	assert_true(generator.templates.size() >= 8, "Should load at least 8 party templates")

	for template in generator.templates:
		assert_true(template.has("name"), "Template should have name field")
		assert_true(template.has("ideology_range"), "Template should have ideology_range field")
		assert_true(template.has("typical_keywords"), "Template should have typical_keywords field")
		assert_true(template["typical_keywords"].size() >= 3, "Template should have at least 3 keywords")

func test_error_handling_invalid_count():
	var parties = generator.generate_parties(-1)
	assert_eq(parties.size(), 0, "Should return empty array for invalid negative count")

	parties = generator.generate_parties(0)
	assert_eq(parties.size(), 0, "Should return empty array for zero count")

func test_large_generation():
	var parties = generator.generate_parties(50)
	assert_eq(parties.size(), 50, "Should handle large generation requests")

	# Verify all are still valid and unique
	var names = []
	for party in parties:
		assert_false(names.has(party.name), "All party names should remain unique in large generation")
		names.append(party.name)
		assert_true(party.validate().valid, "All parties should remain valid in large generation")