extends Resource
class_name PolicyKeyword

# Unique identifier
@export var id: String = ""

# Categorization
@export var category: String = ""

# Display information
@export var name: String = ""
@export var description: String = ""

# Visual representation
@export var icon: Texture2D

# Policy logic
@export var conflicting_keywords: Array = []
@export var ideology_impact: Dictionary = {}

func _init():
	# Initialize ideology impact with default values
	ideology_impact = {
		"economic_left_right": 0.0,
		"social_liberal_conservative": 0.0,
		"eu_skeptic_federal": 0.0,
		"environment_economy": 0.0,
		"centralization": 0.0
	}

# Validation function for policy keyword data
func validate() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	# Basic information validation
	if name.length() < 3:
		errors.append("Policy keyword name must be at least 3 characters")
	elif name.length() > 50:
		errors.append("Policy keyword name must be 50 characters or less")

	if description.length() < 5:
		errors.append("Policy keyword description must be at least 5 characters")

	if category.length() == 0:
		errors.append("Policy keyword must have a category")

	# Ideology impact validation
	for ideology_key in ideology_impact.keys():
		var impact = ideology_impact[ideology_key]
		if impact < -1.0 or impact > 1.0:
			errors.append("Ideology impact for '%s' must be between -1.0 and 1.0" % ideology_key)

	return {
		"valid": errors.size() == 0,
		"errors": errors,
		"warnings": warnings
	}

# Check if this keyword conflicts with another
func conflicts_with(other_keyword: PolicyKeyword) -> bool:
	return other_keyword.id in conflicting_keywords or id in other_keyword.conflicting_keywords

# Get a description of the keyword's ideological impact
func get_ideology_description() -> String:
	var impacts: Array[String] = []

	for ideology_key in ideology_impact.keys():
		var impact = ideology_impact[ideology_key]
		if abs(impact) > 0.2:  # Only show significant impacts
			var direction = "more" if impact > 0 else "less"
			var ideology_name = _get_ideology_display_name(ideology_key)
			impacts.append("%s %s" % [direction, ideology_name])

	if impacts.size() > 0:
		return "Tends toward: " + impacts", ".join(
	else:
		return "Neutral ideological impact"

# Helper function to get readable ideology names
func _get_ideology_display_name(ideology_key: String) -> String:
	match ideology_key:
		"economic_left_right":
			return "economic right" if ideology_impact[ideology_key] > 0 else "economic left"
		"social_liberal_conservative":
			return "socially conservative" if ideology_impact[ideology_key] > 0 else "socially liberal"
		"eu_skeptic_federal":
			return "EU federal" if ideology_impact[ideology_key] > 0 else "EU skeptic"
		"environment_economy":
			return "economic priority" if ideology_impact[ideology_key] > 0 else "environmental priority"
		"centralization":
			return "centralized" if ideology_impact[ideology_key] > 0 else "decentralized"
		_:
			return ideology_key

# Static method to create common policy keywords
static func create_economic_keywords() -> Array[PolicyKeyword]:
	var keywords: Array[PolicyKeyword] = []

	# Progressive Taxation
	var progressive_tax = PolicyKeyword.new()
	progressive_tax.id = "progressive_taxation"
	progressive_tax.category = "Economic"
	progressive_tax.name = "Progressive Taxation"
	progressive_tax.description = "Higher tax rates for higher income brackets to reduce inequality"
	progressive_tax.ideology_impact["economic_left_right"] = -0.6
	progressive_tax.conflicting_keywords = ["flat_tax", "tax_cuts"]
	keywords.append(progressive_tax)

	# Free Market Economy
	var free_market = PolicyKeyword.new()
	free_market.id = "free_market"
	free_market.category = "Economic"
	free_market.name = "Free Market Economy"
	free_market.description = "Minimal government intervention in economic affairs"
	free_market.ideology_impact["economic_left_right"] = 0.8
	free_market.conflicting_keywords = ["planned_economy", "state_intervention"]
	keywords.append(free_market)

	# Universal Basic Income
	var ubi = PolicyKeyword.new()
	ubi.id = "universal_basic_income"
	ubi.category = "Economic"
	ubi.name = "Universal Basic Income"
	ubi.description = "Unconditional regular payments to all citizens"
	ubi.ideology_impact["economic_left_right"] = -0.5
	ubi.conflicting_keywords = ["workfare", "means_testing"]
	keywords.append(ubi)

	return keywords

static func create_social_keywords() -> Array[PolicyKeyword]:
	var keywords: Array[PolicyKeyword] = []

	# Healthcare Reform
	var healthcare = PolicyKeyword.new()
	healthcare.id = "universal_healthcare"
	healthcare.category = "Social"
	healthcare.name = "Universal Healthcare"
	healthcare.description = "Free healthcare for all citizens funded by taxes"
	healthcare.ideology_impact["economic_left_right"] = -0.4
	healthcare.ideology_impact["social_liberal_conservative"] = -0.3
	keywords.append(healthcare)

	# Education Investment
	var education = PolicyKeyword.new()
	education.id = "education_investment"
	education.category = "Social"
	education.name = "Education Investment"
	education.description = "Increased funding for public education and universities"
	education.ideology_impact["economic_left_right"] = -0.3
	keywords.append(education)

	# Traditional Values
	var traditional = PolicyKeyword.new()
	traditional.id = "traditional_values"
	traditional.category = "Social"
	traditional.name = "Traditional Values"
	traditional.description = "Preserve traditional family structures and cultural norms"
	traditional.ideology_impact["social_liberal_conservative"] = 0.7
	traditional.conflicting_keywords = ["progressive_values", "multicultural_society"]
	keywords.append(traditional)

	return keywords

static func create_environmental_keywords() -> Array[PolicyKeyword]:
	var keywords: Array[PolicyKeyword] = []

	# Green Transition
	var green_transition = PolicyKeyword.new()
	green_transition.id = "green_transition"
	green_transition.category = "Environmental"
	green_transition.name = "Green Energy Transition"
	green_transition.description = "Rapid shift to renewable energy sources"
	green_transition.ideology_impact["environment_economy"] = -0.8
	green_transition.conflicting_keywords = ["fossil_fuel_support"]
	keywords.append(green_transition)

	# Climate Action
	var climate_action = PolicyKeyword.new()
	climate_action.id = "climate_action"
	climate_action.category = "Environmental"
	climate_action.name = "Strong Climate Action"
	climate_action.description = "Aggressive policies to combat climate change"
	climate_action.ideology_impact["environment_economy"] = -0.6
	climate_action.ideology_impact["economic_left_right"] = -0.2
	keywords.append(climate_action)

	return keywords

static func create_eu_keywords() -> Array[PolicyKeyword]:
	var keywords: Array[PolicyKeyword] = []

	# EU Integration
	var eu_integration = PolicyKeyword.new()
	eu_integration.id = "eu_integration"
	eu_integration.category = "EU & International"
	eu_integration.name = "Deeper EU Integration"
	eu_integration.description = "Support for closer European political and economic union"
	eu_integration.ideology_impact["eu_skeptic_federal"] = 0.7
	eu_integration.conflicting_keywords = ["eu_skepticism", "national_sovereignty"]
	keywords.append(eu_integration)

	# National Sovereignty
	var sovereignty = PolicyKeyword.new()
	sovereignty.id = "national_sovereignty"
	sovereignty.category = "EU & International"
	sovereignty.name = "National Sovereignty"
	sovereignty.description = "Protect Dutch autonomy from EU interference"
	sovereignty.ideology_impact["eu_skeptic_federal"] = -0.8
	sovereignty.conflicting_keywords = ["eu_integration", "eu_federalism"]
	keywords.append(sovereignty)

	return keywords