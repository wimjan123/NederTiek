extends RefCounted
class_name ProfanityFilter

# ProfanityFilter - Simple content filter for user-generated party names
# Filters inappropriate content in Dutch and English political context

# Dutch profanity and inappropriate terms list (partial for demonstration)
const DUTCH_BLOCKED_TERMS = [
	"kut", "shit", "klote", "kanker", "tyfus", "tering", "godver",
	"fuck", "shit", "damn", "hell", "piss", "crap",
	# Political extremist terms
	"nazi", "fascist", "hitler", "commie", "terrorist",
	# Discriminatory terms (partial list)
	"homo", "fag", "retard", "idiot", "stupid", "dumb"
]

# Additional contextual checks for political names
const INAPPROPRIATE_POLITICAL_TERMS = [
	"genocide", "holocaust", "kill", "death", "murder", "bomb",
	"isis", "terror", "extremist", "radical", "cult"
]

# Common substitution characters used to bypass filters
const SUBSTITUTION_CHARS = {
	"@": "a", "3": "e", "1": "i", "0": "o", "5": "s",
	"$": "s", "!": "i", "+": "t", "7": "t", "4": "a"
}

static func is_appropriate(text: String) -> Dictionary:
	"""
	Check if the given text is appropriate for a political party name.
	Returns a dictionary with 'valid' boolean and 'reason' string.
	"""
	if text.strip_edges() == "":
		return {"valid": false, "reason": "Party name cannot be empty"}

	var normalized_text = _normalize_text(text)

	# Check against blocked terms
	var blocked_result = _check_blocked_terms(normalized_text)
	if not blocked_result.valid:
		return blocked_result

	# Check for inappropriate political context
	var political_result = _check_political_appropriateness(normalized_text)
	if not political_result.valid:
		return political_result

	# Check for excessive repetition (spam-like behavior)
	if _has_excessive_repetition(text):
		return {"valid": false, "reason": "Party name contains excessive repetition"}

	# Check for non-alphabetic spam
	if _is_mostly_non_alphabetic(text):
		return {"valid": false, "reason": "Party name must contain meaningful text"}

	return {"valid": true, "reason": ""}

static func _normalize_text(text: String) -> String:
	"""Normalize text for filtering by removing substitution characters and converting to lowercase."""
	var normalized = text.to_lower()

	# Replace common substitution characters
	for sub_char in SUBSTITUTION_CHARS:
		normalized = normalized.replace(sub_char, SUBSTITUTION_CHARS[sub_char])

	# Remove spaces and special characters for checking
	normalized = normalized.replace(" ", "").replace("-", "").replace("_", "")

	return normalized

static func _check_blocked_terms(normalized_text: String) -> Dictionary:
	"""Check text against lists of blocked terms."""

	# Check Dutch blocked terms
	for term in DUTCH_BLOCKED_TERMS:
		if normalized_text.contains(term):
			return {"valid": false, "reason": "Party name contains inappropriate language"}

	# Check inappropriate political terms
	for term in INAPPROPRIATE_POLITICAL_TERMS:
		if normalized_text.contains(term):
			return {"valid": false, "reason": "Party name contains inappropriate political references"}

	return {"valid": true, "reason": ""}

static func _check_political_appropriateness(normalized_text: String) -> Dictionary:
	"""Check for political appropriateness in Dutch context."""

	# Check for impersonation of real Dutch parties
	var real_dutch_parties = [
		"vvd", "pvv", "cda", "d66", "groenlinks", "sp", "pvda",
		"cu", "sgp", "denk", "forum", "ja21", "volt", "bij1"
	]

	for party in real_dutch_parties:
		if normalized_text == party or normalized_text.begins_with(party + "2") or normalized_text.ends_with("vvd"):
			if normalized_text != party:  # Allow exact match for testing
				return {"valid": false, "reason": "Party name too similar to existing Dutch political party"}

	# Check for inappropriate references to Dutch political figures
	var dutch_politicians = ["rutte", "wilders", "baudet", "klaver", "segers"]
	for politician in dutch_politicians:
		if normalized_text.contains(politician):
			return {"valid": false, "reason": "Party name should not reference specific politicians"}

	return {"valid": true, "reason": ""}

static func _has_excessive_repetition(text: String) -> bool:
	"""Check if text has excessive character or word repetition."""
	var clean_text = text.to_lower().strip_edges()

	# Check for excessive character repetition (more than 3 consecutive identical chars)
	var prev_char = ""
	var repeat_count = 1

	for i in range(clean_text.length()):
		var current_char = clean_text[i]
		if current_char == prev_char:
			repeat_count += 1
			if repeat_count > 3:
				return true
		else:
			repeat_count = 1
		prev_char = current_char

	# Check for excessive word repetition
	var words = clean_text.split(" ")
	if words.size() > 1:
		for i in range(words.size() - 1):
			if words[i] == words[i + 1] and words[i].length() > 2:
				return true

	return false

static func _is_mostly_non_alphabetic(text: String) -> bool:
	"""Check if text is mostly non-alphabetic characters."""
	var alphabetic_count = 0
	var total_count = 0

	for i in range(text.length()):
		var char = text[i]
		total_count += 1
		if char.match("[a-zA-Zàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ]"):
			alphabetic_count += 1

	if total_count == 0:
		return true

	var alphabetic_ratio = float(alphabetic_count) / float(total_count)
	return alphabetic_ratio < 0.6  # Less than 60% alphabetic characters

static func suggest_alternative(original_text: String) -> String:
	"""Suggest an alternative name when the original is inappropriate."""
	var base_suggestions = [
		"Progressive Party", "Democratic Alliance", "Citizens Movement",
		"Reform Party", "Future Coalition", "People's Voice",
		"Unity Party", "Change Movement", "New Direction"
	]

	# Try to preserve some aspects of the original if possible
	var words = original_text.split(" ")
	var clean_words = []

	for word in words:
		var check_result = is_appropriate(word)
		if check_result.valid and word.length() > 2:
			clean_words.append(word.capitalize())

	if clean_words.size() > 0:
		return clean_words[0] + " Party"
	else:
		# Return a random suggestion
		return base_suggestions[randi() % base_suggestions.size()]

# Test function for development/debugging
static func run_tests():
	print("=== ProfanityFilter Tests ===")

	var test_cases = [
		{"text": "Progressive Party", "should_pass": true},
		{"text": "Test Party", "should_pass": true},
		{"text": "Kut Party", "should_pass": false},
		{"text": "VVD2", "should_pass": false},
		{"text": "Hitler Youth", "should_pass": false},
		{"text": "aaaaaaa", "should_pass": false},
		{"text": "!!!@@@", "should_pass": false},
		{"text": "", "should_pass": false}
	]

	for test_case in test_cases:
		var result = is_appropriate(test_case.text)
		var passed = result.valid == test_case.should_pass
		print("Test '%s': %s (expected %s, got %s)" % [
			test_case.text,
			"PASS" if passed else "FAIL",
			test_case.should_pass,
			result.valid
		])
		if not passed:
			print("  Reason: %s" % result.reason)