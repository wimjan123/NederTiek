extends Resource
class_name MediaAnswer

# The answer text displayed to the player
@export var text: String = ""

# Impact on leader attributes (can be positive or negative)
@export var attribute_impacts: Dictionary = {}

# Impact on starting treasury (in euros, can be negative)
@export var treasury_impact: int = 0

# Impact on starting popularity (percentage points, can be negative)
@export var popularity_impact: float = 0.0

# Tags for future reference or special game mechanics
@export var reputation_tags: Array = []

func _init():
	# Initialize attribute impacts with default values
	attribute_impacts = {
		"charisma": 0,
		"intelligence": 0,
		"integrity": 0,
		"experience": 0,
		"energy": 0,
		"networking": 0
	}

# Validation function for media answer data
func validate() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	# Basic text validation
	if text.length() < 5:
		errors.append("Answer text must be at least 5 characters")
	elif text.length() > 200:
		warnings.append("Very long answers may not display well in UI")

	# Attribute impact validation
	for attr_key in attribute_impacts.keys():
		var impact = attribute_impacts[attr_key]
		if impact < -50:
			warnings.append("Large negative impact on '%s' may make character unplayable" % attr_key)
		elif impact > 50:
			warnings.append("Large positive impact on '%s' may unbalance the game" % attr_key)

	# Treasury impact validation
	if treasury_impact < -500000:
		warnings.append("Very large negative treasury impact may create unwinnable scenarios")
	elif treasury_impact > 500000:
		warnings.append("Very large positive treasury impact may unbalance the game")

	# Popularity impact validation
	if popularity_impact < -50:
		warnings.append("Large negative popularity impact may create unwinnable scenarios")
	elif popularity_impact > 50:
		warnings.append("Large positive popularity impact may unbalance the game")

	return {
		"valid": errors.size() == 0,
		"errors": errors,
		"warnings": warnings
	}

# Get a summary of this answer's impacts for display
func get_impact_summary() -> String:
	var impacts: Array[String] = []

	# Find significant attribute impacts
	for attr_key in attribute_impacts.keys():
		var impact = attribute_impacts[attr_key]
		if abs(impact) >= 3:  # Only show significant impacts
			var sign = "+" if impact > 0 else ""
			impacts.append("%s%d %s" % [sign, impact, attr_key.capitalize()])

	# Add treasury impact
	if abs(treasury_impact) >= 10000:
		var sign = "+" if treasury_impact > 0 else ""
		if abs(treasury_impact) >= 1000000:
			impacts.append("%s€%.1fM funding" % [sign, treasury_impact / 1000000.0])
		else:
			impacts.append("%s€%dK funding" % [sign, treasury_impact / 1000])

	# Add popularity impact
	if abs(popularity_impact) >= 2:
		var sign = "+" if popularity_impact > 0 else ""
		impacts.append("%s%.1f%% popularity" % [sign, popularity_impact])

	if impacts.size() > 0:
		return ", ".join(impacts)
	else:
		return "Neutral impact"

# Get impact description with context for tooltips
func get_detailed_impact_description() -> String:
	var description_parts: Array[String] = []

	# Describe attribute impacts
	var positive_attributes: Array[String] = []
	var negative_attributes: Array[String] = []

	for attr_key in attribute_impacts.keys():
		var impact = attribute_impacts[attr_key]
		if impact > 0:
			positive_attributes.append("%s (+%d)" % [_get_attribute_display_name(attr_key), impact])
		elif impact < 0:
			negative_attributes.append("%s (%d)" % [_get_attribute_display_name(attr_key), impact])

	if positive_attributes.size() > 0:
		description_parts.append("Improves: " + ", ".join(positive_attributes))
	if negative_attributes.size() > 0:
		description_parts.append("Reduces: " + ", ".join(negative_attributes))

	# Describe economic impacts
	if treasury_impact != 0:
		if treasury_impact > 0:
			description_parts.append("Increases starting funds by €%s" % _format_currency(treasury_impact))
		else:
			description_parts.append("Reduces starting funds by €%s" % _format_currency(-treasury_impact))

	# Describe popularity impacts
	if popularity_impact != 0:
		if popularity_impact > 0:
			description_parts.append("Boosts initial popularity by %.1f%%" % popularity_impact)
		else:
			description_parts.append("Reduces initial popularity by %.1f%%" % -popularity_impact)

	# Mention reputation tags if any
	if reputation_tags.size() > 0:
		description_parts.append("Reputation: " + ", ".join(reputation_tags))

	if description_parts.size() > 0:
		return "\n".join(description_parts)
	else:
		return "This choice has no immediate mechanical effects."

# Helper function to get readable attribute names
func _get_attribute_display_name(attr_key: String) -> String:
	match attr_key:
		"charisma":
			return "Charisma"
		"intelligence":
			return "Intelligence"
		"integrity":
			return "Integrity"
		"experience":
			return "Experience"
		"energy":
			return "Energy"
		"networking":
			return "Networking"
		_:
			return attr_key.capitalize()

# Helper function to format currency amounts
func _format_currency(amount: int) -> String:
	if amount >= 1000000:
		return "%.1fM" % (amount / 1000000.0)
	elif amount >= 1000:
		return "%dK" % (amount / 1000)
	else:
		return str(amount)

# Apply this answer's impacts to a leader
func apply_to_leader(leader: Leader):
	# Apply attribute impacts
	for attr_key in attribute_impacts.keys():
		if attr_key in leader.attributes:
			leader.attributes[attr_key] = clamp(
				leader.attributes[attr_key] + attribute_impacts[attr_key],
				0, 100
			)

	# Apply treasury impact
	leader.starting_treasury = max(0, leader.starting_treasury + treasury_impact)

	# Apply popularity impact
	leader.starting_popularity = clamp(
		leader.starting_popularity + popularity_impact,
		0.0, 100.0
	)

	# Store answer reference
	if text not in leader.media_interview_responses:
		leader.media_interview_responses.append(text)

# Check if this answer has any significant impact
func has_significant_impact() -> bool:
	# Check attribute impacts
	for impact in attribute_impacts.values():
		if abs(impact) >= 3:
			return true

	# Check treasury impact
	if abs(treasury_impact) >= 10000:
		return true

	# Check popularity impact
	if abs(popularity_impact) >= 2:
		return true

	# Check reputation tags
	if reputation_tags.size() > 0:
		return true

	return false

# Get the dominant impact type for UI theming
func get_dominant_impact_type() -> String:
	var total_positive = 0
	var total_negative = 0

	# Sum attribute impacts
	for impact in attribute_impacts.values():
		if impact > 0:
			total_positive += impact
		else:
			total_negative += abs(impact)

	# Add treasury impact (scaled)
	if treasury_impact > 0:
		total_positive += treasury_impact / 10000
	else:
		total_negative += abs(treasury_impact) / 10000

	# Add popularity impact (scaled)
	if popularity_impact > 0:
		total_positive += popularity_impact * 2
	else:
		total_negative += abs(popularity_impact) * 2

	if total_positive > total_negative * 1.2:
		return "positive"
	elif total_negative > total_positive * 1.2:
		return "negative"
	else:
		return "neutral"