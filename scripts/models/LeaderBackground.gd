extends Resource
class_name LeaderBackground

# Unique identifier
@export var id: String = ""

# Display information
@export var name: String = ""
@export var description: String = ""

# Attribute modifications (added to base values)
@export var attribute_modifiers: Dictionary = {}

# Economic impact modifiers
@export var treasury_modifier: float = 1.0  # Multiplier for starting funds
@export var popularity_modifier: float = 0.0  # Base popularity adjustment (-100 to +100)

# Special traits or advantages
@export var special_traits: Array[String] = []

func _init():
	# Initialize attribute modifiers with default values
	attribute_modifiers = {
		"charisma": 0,
		"intelligence": 0,
		"integrity": 0,
		"experience": 0,
		"energy": 0,
		"networking": 0
	}

# Validation function for background data
func validate() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	# Basic information validation
	if name.length() < 3:
		errors.append("Background name must be at least 3 characters")
	elif name.length() > 50:
		errors.append("Background name must be 50 characters or less")

	if description.length() < 10:
		errors.append("Background description must be at least 10 characters")

	# Modifier validation
	for attr_key in attribute_modifiers.keys():
		var modifier = attribute_modifiers[attr_key]
		if modifier < -50:
			warnings.append("Large negative modifier for '%s' may create unplayable characters" % attr_key)
		elif modifier > 50:
			warnings.append("Large positive modifier for '%s' may create overpowered characters" % attr_key)

	# Treasury modifier validation
	if treasury_modifier < 0.1:
		errors.append("Treasury modifier cannot be less than 0.1")
	elif treasury_modifier > 10.0:
		warnings.append("Very high treasury modifier may unbalance the game")

	# Popularity modifier validation
	if popularity_modifier < -50:
		warnings.append("Large negative popularity modifier may create unwinnable scenarios")
	elif popularity_modifier > 50:
		warnings.append("Large positive popularity modifier may unbalance the game")

	return {
		"valid": errors.size() == 0,
		"errors": errors,
		"warnings": warnings
	}

# Get a summary of the background's impact
func get_impact_summary() -> String:
	var summary_parts: Array[String] = []

	# Find most significant attribute modifiers
	var max_positive = 0
	var max_negative = 0
	var max_positive_attr = ""
	var max_negative_attr = ""

	for attr_key in attribute_modifiers.keys():
		var modifier = attribute_modifiers[attr_key]
		if modifier > max_positive:
			max_positive = modifier
			max_positive_attr = attr_key
		elif modifier < max_negative:
			max_negative = modifier
			max_negative_attr = attr_key

	if max_positive > 0:
		summary_parts.append("+%d %s" % [max_positive, max_positive_attr.capitalize()])
	if max_negative < 0:
		summary_parts.append("%d %s" % [max_negative, max_negative_attr.capitalize()])

	# Add treasury impact
	if treasury_modifier != 1.0:
		if treasury_modifier > 1.0:
			summary_parts.append("+%.0f%% funding" % ((treasury_modifier - 1.0) * 100))
		else:
			summary_parts.append("%.0f%% funding" % ((treasury_modifier - 1.0) * 100))

	# Add popularity impact
	if popularity_modifier != 0:
		if popularity_modifier > 0:
			summary_parts.append("+%.0f%% popularity" % popularity_modifier)
		else:
			summary_parts.append("%.0f%% popularity" % popularity_modifier)

	if summary_parts.size() > 0:
		return summary_parts.join(", ")
	else:
		return "Balanced background"

# Create the 8 standard backgrounds as static methods
static func create_career_politician() -> LeaderBackground:
	var bg = LeaderBackground.new()
	bg.id = "career_politician"
	bg.name = "Career Politician"
	bg.description = "A lifelong political insider with deep knowledge of the system and extensive contacts. Strong in networking and experience, but may struggle with authenticity."
	bg.attribute_modifiers = {
		"charisma": 5,
		"intelligence": 10,
		"integrity": -5,
		"experience": 20,
		"energy": 5,
		"networking": 15
	}
	bg.treasury_modifier = 1.3
	bg.popularity_modifier = -5
	bg.special_traits = ["Coalition Builder", "System Knowledge"]
	return bg

static func create_business_executive() -> LeaderBackground:
	var bg = LeaderBackground.new()
	bg.id = "business_executive"
	bg.name = "Business Executive"
	bg.description = "A successful entrepreneur or corporate leader bringing private sector experience. Strong in fundraising and energy, but may lack political experience."
	bg.attribute_modifiers = {
		"charisma": 10,
		"intelligence": 15,
		"integrity": 5,
		"experience": -10,
		"energy": 15,
		"networking": 10
	}
	bg.treasury_modifier = 2.0
	bg.popularity_modifier = 5
	bg.special_traits = ["Business Connections", "Economic Focus"]
	return bg

static func create_academic() -> LeaderBackground:
	var bg = LeaderBackground.new()
	bg.id = "academic"
	bg.name = "Academic/Professor"
	bg.description = "A university professor or researcher with deep expertise in policy areas. Excellent intelligence and integrity, but limited practical political experience."
	bg.attribute_modifiers = {
		"charisma": 0,
		"intelligence": 25,
		"integrity": 15,
		"experience": -5,
		"energy": -5,
		"networking": 0
	}
	bg.treasury_modifier = 0.8
	bg.popularity_modifier = 0
	bg.special_traits = ["Policy Expert", "Research Skills"]
	return bg

static func create_activist() -> LeaderBackground:
	var bg = LeaderBackground.new()
	bg.id = "activist"
	bg.name = "Activist/NGO Leader"
	bg.description = "A grassroots organizer or NGO leader with passion for social change. Strong in integrity and energy, but limited in networking and experience."
	bg.attribute_modifiers = {
		"charisma": 15,
		"intelligence": 5,
		"integrity": 20,
		"experience": -5,
		"energy": 20,
		"networking": -10
	}
	bg.treasury_modifier = 0.6
	bg.popularity_modifier = 10
	bg.special_traits = ["Grassroots Support", "Social Movement Ties"]
	return bg

static func create_media_personality() -> LeaderBackground:
	var bg = LeaderBackground.new()
	bg.id = "media_personality"
	bg.name = "Media Personality"
	bg.description = "A television host, journalist, or public figure with high name recognition. Exceptional charisma, but questions about depth and experience."
	bg.attribute_modifiers = {
		"charisma": 25,
		"intelligence": 0,
		"integrity": -5,
		"experience": -15,
		"energy": 10,
		"networking": 5
	}
	bg.treasury_modifier = 1.2
	bg.popularity_modifier = 20
	bg.special_traits = ["Media Savvy", "Name Recognition"]
	return bg

static func create_local_administrator() -> LeaderBackground:
	var bg = LeaderBackground.new()
	bg.id = "local_administrator"
	bg.name = "Local Administrator"
	bg.description = "A mayor, alderman, or local government official with practical governance experience. Well-rounded but may lack national visibility."
	bg.attribute_modifiers = {
		"charisma": 5,
		"intelligence": 10,
		"integrity": 10,
		"experience": 15,
		"energy": 5,
		"networking": 5
	}
	bg.treasury_modifier = 1.0
	bg.popularity_modifier = 0
	bg.special_traits = ["Practical Experience", "Local Network"]
	return bg

static func create_union_leader() -> LeaderBackground:
	var bg = LeaderBackground.new()
	bg.id = "union_leader"
	bg.name = "Union Leader"
	bg.description = "A trade union leader with strong worker connections and negotiation skills. Excellent at networking and coalition building."
	bg.attribute_modifiers = {
		"charisma": 10,
		"intelligence": 5,
		"integrity": 10,
		"experience": 10,
		"energy": 15,
		"networking": 20
	}
	bg.treasury_modifier = 0.9
	bg.popularity_modifier = 5
	bg.special_traits = ["Labor Support", "Negotiation Skills"]
	return bg

static func create_military_security() -> LeaderBackground:
	var bg = LeaderBackground.new()
	bg.id = "military_security"
	bg.name = "Military/Security Background"
	bg.description = "A former military officer or security professional with leadership experience and disciplined approach. Strong in integrity and experience."
	bg.attribute_modifiers = {
		"charisma": 0,
		"intelligence": 10,
		"integrity": 20,
		"experience": 15,
		"energy": 10,
		"networking": -5
	}
	bg.treasury_modifier = 1.0
	bg.popularity_modifier = -5
	bg.special_traits = ["Security Expertise", "Disciplined Leadership"]
	return bg