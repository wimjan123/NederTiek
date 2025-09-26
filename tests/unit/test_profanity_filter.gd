extends GutTest

# Unit tests for ProfanityFilter
# Tests content filtering for party names and descriptions

func test_appropriate_names_pass():
	var appropriate_names = [
		"Progressive Party",
		"Democratic Alliance",
		"Liberal Democrats",
		"Green Future",
		"Workers Union",
		"Citizens Movement",
		"Reform Coalition",
		"Social Democrats"
	]

	for name in appropriate_names:
		var result = ProfanityFilter.is_appropriate(name)
		assert_true(result.valid, "Appropriate name should pass: '%s'" % name)
		assert_eq(result.reason, "", "Appropriate name should have no reason: '%s'" % name)

func test_empty_names_fail():
	var empty_names = ["", " ", "   ", "\t", "\n"]

	for name in empty_names:
		var result = ProfanityFilter.is_appropriate(name)
		assert_false(result.valid, "Empty name should fail: '%s'" % name)
		assert_eq(result.reason, "Party name cannot be empty", "Should report empty name")

func test_profanity_blocked():
	var profane_names = [
		"Kut Party",
		"Shit Coalition",
		"F*ck Democrats",
		"Nazi Alliance",
		"Hitler Youth Party",
		"Terrorist Movement"
	]

	for name in profane_names:
		var result = ProfanityFilter.is_appropriate(name)
		assert_false(result.valid, "Profane name should be blocked: '%s'" % name)
		assert_true(result.reason.contains("inappropriate"),
			"Should report inappropriate content for: '%s'" % name)

func test_substitution_character_bypass_blocked():
	var substitution_names = [
		"K@t Party",      # @ for a
		"Sh1t Coalition", # 1 for i
		"F*ck D3m0crats", # 3 for e, 0 for o
		"N4z1 Alliance"   # 4 for a, 1 for i
	]

	for name in substitution_names:
		var result = ProfanityFilter.is_appropriate(name)
		assert_false(result.valid, "Substitution bypass should be blocked: '%s'" % name)

func test_dutch_party_impersonation_blocked():
	var impersonation_names = [
		"VVD2",
		"New VVD",
		"PVV Plus",
		"D66 Reformed",
		"Alternative CDA",
		"GroenLinks Future"
	]

	for name in impersonation_names:
		var result = ProfanityFilter.is_appropriate(name)
		assert_false(result.valid, "Party impersonation should be blocked: '%s'" % name)
		assert_true(result.reason.contains("similar to existing") or result.reason.contains("political party"),
			"Should report impersonation for: '%s'" % name)

func test_politician_name_references_blocked():
	var politician_names = [
		"Rutte Party",
		"Wilders Alliance",
		"Baudet Movement",
		"Klaver Coalition",
		"Segers Democrats"
	]

	for name in politician_names:
		var result = ProfanityFilter.is_appropriate(name)
		assert_false(result.valid, "Politician reference should be blocked: '%s'" % name)
		assert_true(result.reason.contains("politicians") or result.reason.contains("reference"),
			"Should report politician reference for: '%s'" % name)

func test_excessive_repetition_blocked():
	var repetitive_names = [
		"aaaaaaa",        # Character repetition
		"Test Test Test", # Word repetition
		"Party Party",    # Simple word repetition
		"xxxxxxxxxx"      # Spam-like
	]

	for name in repetitive_names:
		var result = ProfanityFilter.is_appropriate(name)
		assert_false(result.valid, "Excessive repetition should be blocked: '%s'" % name)
		assert_true(result.reason.contains("repetition"),
			"Should report repetition for: '%s'" % name)

func test_non_alphabetic_spam_blocked():
	var spam_names = [
		"!!!!!!",
		"@@@@@@",
		"123456",
		"######",
		"$$$$$$",
		"!@#$%^"
	]

	for name in spam_names:
		var result = ProfanityFilter.is_appropriate(name)
		assert_false(result.valid, "Non-alphabetic spam should be blocked: '%s'" % name)
		assert_true(result.reason.contains("meaningful text"),
			"Should report non-alphabetic content for: '%s'" % name)

func test_borderline_cases():
	# Test cases that are on the edge of acceptable
	var borderline_cases = [
		{"name": "VVD", "should_pass": true},  # Exact match for testing
		{"name": "Test", "should_pass": false}, # Too short (needs 3+ chars in context)
		{"name": "Progressive Progressives", "should_pass": true}, # Similar words but not identical
		{"name": "New Democratic Party", "should_pass": true}, # Generic terms
		{"name": "Freedom Alliance", "should_pass": true}  # Political terms but appropriate
	]

	for case in borderline_cases:
		var result = ProfanityFilter.is_appropriate(case.name)
		assert_eq(result.valid, case.should_pass,
			"Borderline case '%s' should %s: %s" % [
				case.name,
				"pass" if case.should_pass else "fail",
				result.reason
			])

func test_normalization_logic():
	# Test that the normalization correctly handles various inputs
	var normalization_tests = [
		{"input": "Te$t P@rty", "should_contain": "testparty"},
		{"input": "Pr0gr3$$1v3", "should_contain": "progressive"},
		{"input": "D3m0cr@t$", "should_contain": "democrats"}
	]

	# We can't directly test the private _normalize_text function,
	# but we can test that substitution characters are properly handled
	for test in normalization_tests:
		var result = ProfanityFilter.is_appropriate(test.input)
		# These should be blocked because they contain substitution characters for inappropriate terms
		assert_false(result.valid, "Substitution text should be caught: '%s'" % test.input)

func test_suggestion_system():
	var inappropriate_names = [
		"Shit Party",
		"Nazi Alliance",
		"F*ck Coalition"
	]

	for name in inappropriate_names:
		var suggestion = ProfanityFilter.suggest_alternative(name)

		# Suggestion should be appropriate
		var suggestion_result = ProfanityFilter.is_appropriate(suggestion)
		assert_true(suggestion_result.valid,
			"Suggestion should be appropriate: '%s' -> '%s'" % [name, suggestion])

		# Suggestion should be different from original
		assert_ne(suggestion, name, "Suggestion should be different from original")

		# Suggestion should be reasonable length
		assert_true(suggestion.length() >= 3 and suggestion.length() <= 50,
			"Suggestion should be reasonable length: '%s'" % suggestion)

func test_case_sensitivity():
	# Test that filtering works regardless of case
	var case_variations = [
		"SHIT PARTY",
		"shit party",
		"Shit Party",
		"ShIt PaRtY"
	]

	for name in case_variations:
		var result = ProfanityFilter.is_appropriate(name)
		assert_false(result.valid, "Case variation should be blocked: '%s'" % name)

func test_whitespace_handling():
	# Test that extra whitespace doesn't bypass filters
	var whitespace_tests = [
		"  Shit Party  ",
		"Shit  Party",
		"Shit\tParty",
		"Shit\nParty"
	]

	for name in whitespace_tests:
		var result = ProfanityFilter.is_appropriate(name)
		assert_false(result.valid, "Whitespace variation should be blocked: '%s'" % name)

func test_performance_with_long_strings():
	# Test that filter performs reasonably with longer strings
	var long_appropriate = "This is a very long but completely appropriate political party name that should pass validation"
	var long_inappropriate = "This is a very long political party name that contains shit which should fail validation"

	var result1 = ProfanityFilter.is_appropriate(long_appropriate)
	assert_true(result1.valid, "Long appropriate string should pass")

	var result2 = ProfanityFilter.is_appropriate(long_inappropriate)
	assert_false(result2.valid, "Long inappropriate string should fail")

func test_run_internal_tests():
	# Test the internal test function
	ProfanityFilter.run_tests()
	# This should complete without errors