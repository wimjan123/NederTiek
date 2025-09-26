extends Resource
class_name Leader

# Basic identification
@export var id: String = ""
@export var first_name: String = ""
@export var last_name: String = ""

# Relationships
@export var background_id: String = ""
@export var party_id: String = ""

# Visual representation
@export var portrait_index: int = 0

# Core attributes (0-100 scale)
@export var attributes: Dictionary = {}

# Starting conditions calculated after interview
@export var starting_treasury: int = 0  # In euros
@export var starting_popularity: float = 0.0  # Percentage (0-100)

# Reference data for save/replay
@export var media_interview_responses: Array = []

func _init():
	# Initialize attributes with default values
	attributes = {
		"charisma": 50,        # Media appeal, rally effectiveness
		"intelligence": 50,    # Policy development, debate performance
		"integrity": 50,       # Scandal resistance, coalition trust
		"experience": 50,      # Crisis management, negotiation skill
		"energy": 50,          # Campaign stamina, action points
		"networking": 50       # Coalition building, fundraising
	}

# Validation function for leader data
func validate() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	# Name validation
	if first_name.length() < 2:
		errors.append("First name must be at least 2 characters")
	elif first_name.length() > 30:
		errors.append("First name must be 30 characters or less")

	if last_name.length() < 2:
		errors.append("Last name must be at least 2 characters")
	elif last_name.length() > 30:
		errors.append("Last name must be 30 characters or less")

	# Attributes validation
	for attr_key in attributes.keys():
		var value = attributes[attr_key]
		if value < 0:
			errors.append("Attribute '%s' cannot be negative" % attr_key)
		elif value > 100:
			errors.append("Attribute '%s' cannot exceed 100" % attr_key)

	# Treasury validation
	if starting_treasury < 10000:
		warnings.append("Starting treasury is quite low (minimum recommended: €10,000)")
	elif starting_treasury > 1000000:
		warnings.append("Starting treasury is exceptionally high (maximum recommended: €1,000,000)")

	# Popularity validation
	if starting_popularity < 0.0:
		errors.append("Starting popularity cannot be negative")
	elif starting_popularity > 100.0:
		errors.append("Starting popularity cannot exceed 100%")

	return {
		"valid": errors.size() == 0,
		"errors": errors,
		"warnings": warnings
	}

# Get full name for display
func get_full_name() -> String:
	return "%s %s" % [first_name, last_name]

# Get formatted treasury amount
func get_formatted_treasury() -> String:
	if starting_treasury >= 1000000:
		return "€%.1fM" % (starting_treasury / 1000000.0)
	elif starting_treasury >= 1000:
		return "€%.0fK" % (starting_treasury / 1000.0)
	else:
		return "€%d" % starting_treasury

# Apply attribute modifier from background or interview
func apply_attribute_modifier(modifiers: Dictionary):
	for attr_key in modifiers.keys():
		if attr_key in attributes:
			attributes[attr_key] = clamp(attributes[attr_key] + modifiers[attr_key], 0, 100)

# Get attribute description for UI display
func get_attribute_description(attribute_name: String) -> String:
	match attribute_name:
		"charisma":
			return "Media appeal and public speaking ability"
		"intelligence":
			return "Policy development and strategic thinking"
		"integrity":
			return "Resistance to scandals and public trust"
		"experience":
			return "Crisis management and negotiation skills"
		"energy":
			return "Campaign stamina and action capacity"
		"networking":
			return "Coalition building and fundraising ability"
		_:
			return "Unknown attribute"