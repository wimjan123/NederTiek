class_name SetupDataManager
extends Node

# SetupDataManager - Handles calculations for final leader attributes, treasury, and popularity
# Based on background selection, party type, and interview responses

# Base values for calculations
const BASE_TREASURY_MIN = 50000  # €50K minimum
const BASE_TREASURY_MAX = 200000  # €200K maximum
const BASE_POPULARITY_MIN = 8.0  # 8% minimum
const BASE_POPULARITY_MAX = 18.0  # 18% maximum

# Weight factors for different influences
const BACKGROUND_WEIGHT = 0.4
const PARTY_WEIGHT = 0.3
const INTERVIEW_WEIGHT = 0.3

func _init():
	print("SetupDataManager: Initialized calculation system")

# Calculate starting treasury based on all factors
func calculate_treasury(leader: Leader, party: Party, responses: Array) -> int:
	if leader == null or party == null:
		push_error("SetupDataManager: Cannot calculate treasury without leader and party")
		return BASE_TREASURY_MIN

	var base_treasury = _get_base_treasury(party)
	var background_modifier = _get_background_treasury_modifier(leader.background_id)
	var interview_modifier = _get_interview_treasury_modifier(responses)

	# Combine modifiers
	var total_modifier = (background_modifier * BACKGROUND_WEIGHT +
						 interview_modifier * INTERVIEW_WEIGHT +
						 1.0 * PARTY_WEIGHT)  # Party weight is built into base

	var final_treasury = int(base_treasury * total_modifier)

	# Ensure within bounds
	final_treasury = clamp(final_treasury, 10000, 1000000)

	print("SetupDataManager: Treasury calculated - Base: €%d, Modifier: %.2f, Final: €%d" %
		  [base_treasury, total_modifier, final_treasury])

	return final_treasury

# Calculate starting popularity based on all factors
func calculate_popularity(leader: Leader, party: Party, responses: Array) -> float:
	if leader == null or party == null:
		push_error("SetupDataManager: Cannot calculate popularity without leader and party")
		return BASE_POPULARITY_MIN

	var base_popularity = _get_base_popularity(party)
	var background_modifier = _get_background_popularity_modifier(leader.background_id)
	var interview_modifier = _get_interview_popularity_modifier(responses)
	var charisma_bonus = _get_charisma_popularity_bonus(leader)

	# Combine modifiers
	var final_popularity = (base_popularity +
						   background_modifier * BACKGROUND_WEIGHT +
						   interview_modifier * INTERVIEW_WEIGHT +
						   charisma_bonus)

	# Ensure within bounds
	final_popularity = clamp(final_popularity, 5.0, 25.0)

	print("SetupDataManager: Popularity calculated - Base: %.1f%%, Modifiers: %.1f%%, Final: %.1f%%" %
		  [base_popularity, background_modifier + interview_modifier + charisma_bonus, final_popularity])

	return final_popularity

# Calculate final leader attributes after interview
func calculate_final_attributes(background: LeaderBackground, responses: Array[MediaAnswer]) -> Dictionary:
	if background == null:
		push_error("SetupDataManager: Cannot calculate attributes without background")
		return {}

	# Start with base attributes (50 for all)
	var attributes = {
		"charisma": 50,
		"intelligence": 50,
		"integrity": 50,
		"experience": 50,
		"energy": 50,
		"networking": 50
	}

	# Apply background modifiers
	for attr_key in background.attribute_modifiers.keys():
		if attr_key in attributes:
			attributes[attr_key] += background.attribute_modifiers[attr_key]

	# Apply interview response modifiers
	for response in responses:
		if response != null and response.attribute_impacts != null:
			for attr_key in response.attribute_impacts.keys():
				if attr_key in attributes:
					attributes[attr_key] += response.attribute_impacts[attr_key]

	# Ensure all values are within bounds
	for attr_key in attributes.keys():
		attributes[attr_key] = clamp(attributes[attr_key], 0, 100)

	print("SetupDataManager: Final attributes calculated with %d interview responses" % responses.size())
	return attributes

# Get base treasury based on party characteristics
func _get_base_treasury(party: Party) -> int:
	var base = BASE_TREASURY_MIN + (BASE_TREASURY_MAX - BASE_TREASURY_MIN) / 2

	# Adjust based on party ideology
	if party.ideology_scores.has("economic_left_right"):
		var economic_score = party.ideology_scores["economic_left_right"]
		# Right-leaning parties tend to have more business connections
		if economic_score > 0.3:
			base += 30000
		elif economic_score < -0.3:
			base -= 20000

	# Custom parties start with less funding
	if party.is_custom:
		base = int(base * 0.8)

	return base

# Get base popularity based on party characteristics
func _get_base_popularity(party: Party) -> float:
	var base = BASE_POPULARITY_MIN + (BASE_POPULARITY_MAX - BASE_POPULARITY_MIN) / 2

	# Adjust based on party type and ideology
	if party.is_custom:
		# Custom parties start with lower recognition
		base -= 2.0
	else:
		# Generated parties have some existing recognition
		base += 1.0

	# Moderate parties tend to have broader appeal initially
	var total_extremism = 0.0
	for ideology_score in party.ideology_scores.values():
		total_extremism += abs(ideology_score)

	if total_extremism < 1.5:  # More moderate
		base += 2.0
	elif total_extremism > 3.0:  # More extreme
		base -= 1.0

	return base

# Get treasury modifier from background
func _get_background_treasury_modifier(background_id: String) -> float:
	match background_id:
		"business_executive":
			return 1.8  # Strong business connections
		"career_politician":
			return 1.4  # Established political network
		"media_personality":
			return 1.2  # Name recognition attracts donors
		"local_administrator":
			return 1.0  # Average funding
		"academic":
			return 0.9  # Limited private sector connections
		"union_leader":
			return 0.9  # Primarily grassroots funding
		"activist":
			return 0.7  # Minimal wealthy donor access
		"military_security":
			return 1.0  # Average funding
		_:
			return 1.0

# Get popularity modifier from background
func _get_background_popularity_modifier(background_id: String) -> float:
	match background_id:
		"media_personality":
			return 8.0  # High name recognition
		"activist":
			return 4.0  # Grassroots appeal
		"local_administrator":
			return 2.0  # Some recognition
		"business_executive":
			return 1.0  # Mixed reception
		"career_politician":
			return -2.0  # Anti-establishment sentiment
		"academic":
			return 0.0  # Neutral
		"union_leader":
			return 2.0  # Worker appeal
		"military_security":
			return -1.0  # Mixed reception
		_:
			return 0.0

# Get treasury modifier from interview responses
func _get_interview_treasury_modifier(responses: Array) -> float:
	var total_treasury_impact = 0

	for response in responses:
		if response != null:
			total_treasury_impact += response.treasury_impact

	# Convert treasury impact to modifier
	# €100K impact = roughly 1.5x modifier
	var modifier = 1.0 + (total_treasury_impact / 100000.0) * 0.5

	return clamp(modifier, 0.5, 2.0)

# Get popularity modifier from interview responses
func _get_interview_popularity_modifier(responses: Array) -> float:
	var total_popularity_impact = 0.0

	for response in responses:
		if response != null:
			total_popularity_impact += response.popularity_impact

	return clamp(total_popularity_impact, -10.0, 15.0)

# Get popularity bonus from charisma attribute
func _get_charisma_popularity_bonus(leader: Leader) -> float:
	if leader.attributes.has("charisma"):
		var charisma = leader.attributes["charisma"]
		# High charisma provides popularity bonus (max +3% at 100 charisma)
		return (charisma - 50) * 0.06
	return 0.0

# Calculate difficulty-adjusted modifiers for different game modes
func calculate_difficulty_modifiers(difficulty: String) -> Dictionary:
	match difficulty.to_lower():
		"easy":
			return {
				"treasury_multiplier": 1.3,
				"popularity_bonus": 3.0,
				"attribute_bonus": 5
			}
		"normal":
			return {
				"treasury_multiplier": 1.0,
				"popularity_bonus": 0.0,
				"attribute_bonus": 0
			}
		"hard":
			return {
				"treasury_multiplier": 0.8,
				"popularity_bonus": -2.0,
				"attribute_bonus": -3
			}
		"expert":
			return {
				"treasury_multiplier": 0.6,
				"popularity_bonus": -5.0,
				"attribute_bonus": -5
			}
		_:
			return calculate_difficulty_modifiers("normal")

# Validate calculated values are within expected ranges
func validate_calculated_values(treasury: int, popularity: float, attributes: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	# Treasury validation
	if treasury < 10000:
		errors.append("Treasury below minimum threshold (€10,000)")
	elif treasury > 1000000:
		errors.append("Treasury exceeds maximum threshold (€1,000,000)")
	elif treasury < 30000:
		warnings.append("Very low starting treasury may create difficult gameplay")

	# Popularity validation
	if popularity < 5.0:
		errors.append("Popularity below minimum threshold (5%)")
	elif popularity > 25.0:
		errors.append("Popularity exceeds maximum threshold (25%)")
	elif popularity < 8.0:
		warnings.append("Very low starting popularity may create difficult gameplay")

	# Attribute validation
	for attr_key in attributes.keys():
		var value = attributes[attr_key]
		if value < 0:
			errors.append("Attribute '%s' below minimum (0)" % attr_key)
		elif value > 100:
			errors.append("Attribute '%s' exceeds maximum (100)" % attr_key)
		elif value < 20:
			warnings.append("Very low '%s' attribute may create difficult gameplay" % attr_key)

	return {
		"valid": errors.size() == 0,
		"errors": errors,
		"warnings": warnings
	}

# Get a summary of calculation factors for debugging
func get_calculation_summary(leader: Leader, party: Party, responses: Array) -> String:
	if leader == null or party == null:
		return "Cannot generate summary: missing leader or party data"

	var summary_parts: Array[String] = []

	summary_parts.append("=== CALCULATION SUMMARY ===")
	summary_parts.append("Leader: " + leader.get_full_name())
	summary_parts.append("Background: " + leader.background_id)
	summary_parts.append("Party: " + party.get_display_name())
	summary_parts.append("Custom Party: " + str(party.is_custom))
	summary_parts.append("Interview Responses: " + str(responses.size()))

	# Treasury factors
	var base_treasury = _get_base_treasury(party)
	var treasury_bg_mod = _get_background_treasury_modifier(leader.background_id)
	var treasury_int_mod = _get_interview_treasury_modifier(responses)

	summary_parts.append("")
	summary_parts.append("TREASURY FACTORS:")
	summary_parts.append("  Base: €%d" % base_treasury)
	summary_parts.append("  Background modifier: %.2f" % treasury_bg_mod)
	summary_parts.append("  Interview modifier: %.2f" % treasury_int_mod)

	# Popularity factors
	var base_popularity = _get_base_popularity(party)
	var pop_bg_mod = _get_background_popularity_modifier(leader.background_id)
	var pop_int_mod = _get_interview_popularity_modifier(responses)
	var charisma_bonus = _get_charisma_popularity_bonus(leader)

	summary_parts.append("")
	summary_parts.append("POPULARITY FACTORS:")
	summary_parts.append("  Base: %.1f%%" % base_popularity)
	summary_parts.append("  Background modifier: %.1f%%" % pop_bg_mod)
	summary_parts.append("  Interview modifier: %.1f%%" % pop_int_mod)
	summary_parts.append("  Charisma bonus: %.1f%%" % charisma_bonus)

	return summary_parts"\n".join(