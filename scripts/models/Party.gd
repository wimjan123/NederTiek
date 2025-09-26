extends Resource
class_name Party

# Unique identifier for this party
@export var id: String = ""

# Party identification
@export var name: String = ""
@export var abbreviation: String = ""
@export var description: String = ""

# Visual identity
@export var color_primary: Color = Color.WHITE
@export var color_secondary: Color = Color.GRAY

# Political positioning
@export var policy_keywords: Array = []
@export var ideology_scores: Dictionary = {}

# Generation metadata
@export var is_custom: bool = false
@export var is_official: bool = false  # True for real Dutch parties
@export var generation_seed: int = 0

func _init():
	# Initialize ideology scores with default values
	ideology_scores = {
		"economic_left_right": 0.0,
		"social_liberal_conservative": 0.0,
		"eu_skeptic_federal": 0.0,
		"environment_economy": 0.0,
		"centralization": 0.0
	}

# Validation function for party data
func validate() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	# Name validation
	if name.length() == 0:
		errors.append("Party name is required")
	elif name.length() < 3:
		errors.append("Party name must be at least 3 characters long")
	elif name.length() > 50:
		errors.append("Party name must be 50 characters or less")
	elif not is_official:
		# Check for appropriate content (skip for official parties)
		var profanity_check = ProfanityFilter.is_appropriate(name)
		if not profanity_check.valid:
			errors.append(profanity_check.reason)

	# Abbreviation validation
	if abbreviation.length() == 0:
		errors.append("Party abbreviation is required")
	elif abbreviation.length() < 2:
		errors.append("Party abbreviation must be at least 2 characters")
	elif abbreviation.length() > 6:
		errors.append("Party abbreviation must be 6 characters or less")
	elif not is_official:
		# Check for appropriate content (skip for official parties)
		var abbrev_profanity_check = ProfanityFilter.is_appropriate(abbreviation)
		if not abbrev_profanity_check.valid:
			errors.append("Abbreviation: " + abbrev_profanity_check.reason)

	# Description validation
	if description.length() == 0:
		errors.append("Party description is required")
	elif description.length() < 10:
		warnings.append("Party description is quite short")
	elif description.length() > 500:
		errors.append("Party description must be 500 characters or less")
	else:
		# Check for appropriate content in description
		var desc_profanity_check = ProfanityFilter.is_appropriate(description)
		if not desc_profanity_check.valid:
			errors.append("Description: " + desc_profanity_check.reason)

	# Policy keywords validation
	if policy_keywords.size() < 5:
		errors.append("Party must have at least 5 policy keywords")
	elif policy_keywords.size() > 10:
		errors.append("Party cannot have more than 10 policy keywords")

	# Ideology scores validation
	for score_key in ideology_scores.keys():
		var score = ideology_scores[score_key]
		if score < -1.0 or score > 1.0:
			errors.append("Ideology score '%s' must be between -1.0 and 1.0" % score_key)

	return {
		"valid": errors.size() == 0,
		"errors": errors,
		"warnings": warnings
	}

# Get display name (abbreviation if available, otherwise full name)
func get_display_name() -> String:
	if abbreviation.length() > 0:
		return "%s (%s)" % [abbreviation, name]
	else:
		return name

# Check if this party conflicts with another on policy keywords
func has_policy_conflicts(other_party: Party) -> bool:
	# This could be expanded with actual conflict logic
	# For now, just check for exact same keywords
	for keyword in policy_keywords:
		if keyword in other_party.policy_keywords:
			return true
	return false