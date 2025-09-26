class_name PartyGenerator
extends Node

# PartyGenerator - System for creating realistic Dutch political parties
# Combines historical patterns with procedural variation for replayability

# Dutch political party templates and archetypes
var party_templates: Array = []
var used_names: Array = []
var used_abbreviations: Array = []

# Random generation settings
var random_generator: RandomNumberGenerator
var generation_seed: int = 0

func _init():
	random_generator = RandomNumberGenerator.new()
	_load_party_templates()

# Generate predefined Dutch political parties
func generate_parties(count: int = 20) -> Array:
	var parties = _create_hardcoded_dutch_parties()
	print("PartyGenerator: Created %d hardcoded Dutch parties" % parties.size())


	return parties

# Validate custom party data before creation
func validate_custom_party(data: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	# Check required fields
	if not data.has("name") or data["name"] == "":
		errors.append("Party name is required")
	elif data["name"].length() < 3:
		errors.append("Party name must be at least 3 characters")
	elif data["name"].length() > 50:
		errors.append("Party name must be 50 characters or less")

	# Check abbreviation
	if not data.has("abbreviation") or data["abbreviation"] == "":
		errors.append("Party abbreviation is required")
	elif data["abbreviation"].length() < 2:
		errors.append("Abbreviation must be at least 2 characters")
	elif data["abbreviation"].length() > 6:
		errors.append("Abbreviation must be 6 characters or less")

	# Check policy keywords
	if not data.has("policy_keywords") or data["policy_keywords"].size() < 5:
		errors.append("Party must have at least 5 policy keywords")
	elif data["policy_keywords"].size() > 10:
		errors.append("Party cannot have more than 10 policy keywords")

	# Check for duplicate names with existing parties
	var name_lower = data.get("name", "").to_lower()
	var abbrev_upper = data.get("abbreviation", "").to_upper()

	for existing_name in used_names:
		if name_lower == existing_name.to_lower():
			errors.append("Party name already exists")
			break

	for existing_abbrev in used_abbreviations:
		if abbrev_upper == existing_abbrev.to_upper():
			errors.append("Party abbreviation already exists")
			break

	# Check policy keyword mix requirements
	if data.has("policy_keywords"):
		var categories = {}
		for keyword in data["policy_keywords"]:
			# This would be expanded with actual keyword categorization
			# For now, just ensure variety
			pass

		# Placeholder for category validation
		if data["policy_keywords"].size() < 7:
			warnings.append("Consider adding more policy keywords for a well-rounded platform")

	return {
		"valid": errors.size() == 0,
		"errors": errors,
		"warnings": warnings,
		"data": data
	}

# Create a party from validated custom data
func create_custom_party(data: Dictionary) -> Party:
	var validation = validate_custom_party(data)
	if not validation["valid"]:
		push_error("PartyGenerator: Invalid custom party data: " + str(validation["errors"]))
		return null

	var party = Party.new()
	party.id = "custom_" + str(Time.get_unix_time_from_system())
	party.name = data["name"]
	party.abbreviation = data["abbreviation"]
	party.description = data.get("description", "A custom political party created by the player")
	party.policy_keywords = data["policy_keywords"]
	party.color_primary = data.get("color_primary", Color.BLUE)
	party.color_secondary = data.get("color_secondary", Color.LIGHT_BLUE)
	party.is_custom = true
	party.generation_seed = 0  # Custom parties don't use generation seeds

	# Calculate ideology scores based on policy keywords
	_calculate_ideology_from_keywords(party)

	# Add to used names to prevent duplicates
	used_names.append(party.name)
	used_abbreviations.append(party.abbreviation)

	print("PartyGenerator: Created custom party: " + party.get_display_name())
	return party

# Load party templates from data files or create defaults
func _load_party_templates():
	party_templates.clear()

	# Load templates from JSON file
	var file = FileAccess.open("res://data/parties/templates.json", FileAccess.READ)
	if file == null:
		push_error("PartyGenerator: Could not load templates.json")
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("PartyGenerator: Failed to parse templates.json")
		return

	var data = json.data
	if not data.has("templates"):
		push_error("PartyGenerator: templates.json missing 'templates' key")
		return

	party_templates = data["templates"]

	print("PartyGenerator: Loaded %d party templates" % party_templates.size())

# Select a template ensuring variety
func _select_template(template_uses: Dictionary) -> Dictionary:
	# Find the least used template
	var min_uses = 999
	var available_templates: Array[Dictionary] = []

	for template in party_templates:
		var archetype = template["archetype"]
		var uses = template_uses.get(archetype, 0)

		if uses < min_uses:
			min_uses = uses
			available_templates.clear()
			available_templates.append(template)
		elif uses == min_uses:
			available_templates.append(template)

	# Select randomly from available templates
	var selected = available_templates[random_generator.randi() % available_templates.size()]
	var archetype = selected["archetype"]
	template_uses[archetype] = template_uses.get(archetype, 0) + 1

	return selected

# Generate a party from a template with variation
func _generate_party_from_template(template: Dictionary, index: int) -> Party:
	var party = Party.new()
	party.id = "generated_" + str(index)
	party.generation_seed = generation_seed + index

	# Generate name
	var name_result = _generate_party_name(template)
	party.name = name_result["name"]
	party.abbreviation = name_result["abbreviation"]

	# Generate description
	party.description = _generate_party_description(template, party.name)

	# Set ideology scores with variation
	party.ideology_scores = template["ideology_base"].duplicate()
	_add_ideology_variation(party.ideology_scores)

	# Select policy keywords
	party.policy_keywords = _select_policy_keywords(template)

	# Generate colors
	var colors = _generate_party_colors(template)
	party.color_primary = colors["primary"]
	party.color_secondary = colors["secondary"]

	party.is_custom = false

	# Validate the generated party
	var validation = party.validate()
	if not validation["valid"]:
		print("Warning: Generated invalid party: " + str(validation["errors"]))
		return null

	return party

# Generate party name and abbreviation
func _generate_party_name(template: Dictionary) -> Dictionary:
	var attempts = 0
	var max_attempts = 20

	while attempts < max_attempts:
		# Select random name pattern and word
		var name_patterns = template["name_patterns"]
		var name_words = template["name_words"]
		var abbrev_patterns = template["abbreviation_patterns"]

		var pattern = name_patterns[random_generator.randi() % name_patterns.size()]
		var word = name_words[random_generator.randi() % name_words.size()]
		var name = pattern % word

		# Generate abbreviation
		var abbrev_pattern = abbrev_patterns[random_generator.randi() % abbrev_patterns.size()]
		var abbreviation = ""

		if abbrev_pattern.contains("%s"):
			var abbrev_word = word.substr(0, min(3, word.length())).to_upper()
			abbreviation = abbrev_pattern % abbrev_word
		else:
			abbreviation = abbrev_pattern

		# Check for uniqueness
		if name not in used_names and abbreviation not in used_abbreviations:
			used_names.append(name)
			used_abbreviations.append(abbreviation)
			return {"name": name, "abbreviation": abbreviation}
		attempts += 1

	# Fallback with attempt number
	var fallback_name = "Nieuwe Partij " + str(attempts)
	var fallback_abbrev = "NP" + str(attempts)
	used_names.append(fallback_name)
	used_abbreviations.append(fallback_abbrev)
	return {"name": fallback_name, "abbreviation": fallback_abbrev}

# Generate party description
func _generate_party_description(template: Dictionary, party_name: String) -> String:
	var archetype = template["archetype"]

	var descriptions = {
		"liberal_conservative": "%s focuses on free market economics and individual responsibility while maintaining moderate social positions.",
		"social_democratic": "%s champions worker rights and social justice through progressive taxation and expanded public services.",
		"green_progressive": "%s prioritizes environmental protection and sustainability alongside progressive social values.",
		"populist_right": "%s advocates for national sovereignty and traditional values while opposing excessive EU integration.",
		"christian_democratic": "%s promotes family values and community care rooted in Christian democratic principles.",
		"centrist": "%s seeks pragmatic solutions and democratic reform through evidence-based policymaking."
	}

	var base_description = descriptions.get(archetype, "%s represents a new political movement in Dutch politics.")
	return base_description % party_name

# Add variation to ideology scores
func _add_ideology_variation(ideology_scores: Dictionary):
	for key in ideology_scores.keys():
		var base_value = ideology_scores[key]
		var variation = random_generator.randf_range(-0.2, 0.2)
		ideology_scores[key] = clamp(base_value + variation, -1.0, 1.0)

# Select appropriate policy keywords for the template
func _select_policy_keywords(template: Dictionary) -> Array[String]:
	var keywords: Array[String] = []
	var typical_keywords = template["typical_keywords"]

	# Always include 3-4 typical keywords
	var num_typical = random_generator.randi_range(3, 4)
	var shuffled_typical = typical_keywords.duplicate()
	shuffled_typical.shuffle()

	for i in range(min(num_typical, shuffled_typical.size())):
		keywords.append(shuffled_typical[i])

	# Add 3-6 additional keywords from general pool
	var additional_keywords = [
		"education_investment", "healthcare_reform", "infrastructure_development",
		"innovation_support", "rural_development", "urban_planning",
		"digital_transformation", "security_policy", "cultural_preservation"
	]

	var num_additional = random_generator.randi_range(2, 4)
	additional_keywords.shuffle()

	for i in range(min(num_additional, additional_keywords.size())):
		if additional_keywords[i] not in keywords:
			keywords.append(additional_keywords[i])

	return keywords

# Generate party colors based on archetype
func _generate_party_colors(template: Dictionary) -> Dictionary:
	var archetype = template["archetype"]

	var color_schemes = {
		"liberal_conservative": {"primary": Color.BLUE, "secondary": Color.LIGHT_BLUE},
		"social_democratic": {"primary": Color.RED, "secondary": Color.LIGHT_PINK},
		"green_progressive": {"primary": Color.GREEN, "secondary": Color.LIGHT_GREEN},
		"populist_right": {"primary": Color.ORANGE, "secondary": Color.YELLOW},
		"christian_democratic": {"primary": Color.PURPLE, "secondary": Color.VIOLET},
		"centrist": {"primary": Color.GRAY, "secondary": Color.WHITE}
	}

	var base_colors = color_schemes.get(archetype, {"primary": Color.BLUE, "secondary": Color.LIGHT_BLUE})

	# Add slight color variation
	var primary = base_colors["primary"]
	var secondary = base_colors["secondary"]

	# Slightly randomize hue while keeping the base color recognizable
	var hue_variation = random_generator.randf_range(-0.1, 0.1)
	primary.h = fmod(primary.h + hue_variation, 1.0)
	secondary.h = fmod(secondary.h + hue_variation, 1.0)

	return {"primary": primary, "secondary": secondary}

# Calculate ideology scores from policy keywords
func _calculate_ideology_from_keywords(party: Party):
	# This would be expanded with a full keyword-to-ideology mapping
	# For now, just ensure reasonable defaults
	for ideology_key in party.ideology_scores.keys():
		party.ideology_scores[ideology_key] = 0.0

	# Simple keyword-based calculation
	for keyword in party.policy_keywords:
		match keyword.to_lower():
			"progressive_taxation", "universal_healthcare", "welfare_expansion":
				party.ideology_scores["economic_left_right"] += -0.15
			"free_market", "tax_cuts", "deregulation":
				party.ideology_scores["economic_left_right"] += 0.15
			"traditional_values", "law_and_order":
				party.ideology_scores["social_liberal_conservative"] += 0.15
			"progressive_values", "civil_rights":
				party.ideology_scores["social_liberal_conservative"] += -0.15

	# Normalize scores
	for ideology_key in party.ideology_scores.keys():
		party.ideology_scores[ideology_key] = clamp(party.ideology_scores[ideology_key], -1.0, 1.0)

# Balance ideology distribution across all generated parties
func _balance_ideology_distribution(parties: Array[Party]):
	# Calculate average ideology scores
	var averages = {}
	var count = parties.size()

	if count == 0:
		return

	for party in parties:
		for ideology_key in party.ideology_scores.keys():
			if ideology_key not in averages:
				averages[ideology_key] = 0.0
			averages[ideology_key] += party.ideology_scores[ideology_key]

	for key in averages.keys():
		averages[key] /= count

	# Adjust extreme outliers to create better distribution
	for party in parties:
		for ideology_key in party.ideology_scores.keys():
			var score = party.ideology_scores[ideology_key]
			var average = averages[ideology_key]

			# If party is too extreme and pulling average too far, moderate it slightly
			if abs(score) > 0.8 and abs(average) > 0.3:
				var adjustment = (average - score) * 0.1
				party.ideology_scores[ideology_key] = clamp(score + adjustment, -1.0, 1.0)

	print("PartyGenerator: Balanced ideology distribution across %d parties" % count)

# Create 20 hardcoded Dutch political parties
func _create_hardcoded_dutch_parties() -> Array:
	var parties = []

	# VVD - People's Party for Freedom and Democracy
	var vvd = Party.new()
	vvd.id = "vvd"
	vvd.name = "Volkspartij voor Vrijheid en Democratie"
	vvd.abbreviation = "VVD"
	vvd.description = "Liberal conservative party focused on free market economics and individual responsibility."
	vvd.ideology_scores = {"economic_left_right": 0.4, "social_conservative_liberal": 0.2}
	vvd.policy_keywords = ["free_market_economy", "tax_reduction", "individual_responsibility", "eu_integration", "innovation_support"]
	vvd.color_primary = Color.BLUE
	vvd.color_secondary = Color.LIGHT_BLUE
	vvd.is_official = true
	parties.append(vvd)

	# PVV - Party for Freedom
	var pvv = Party.new()
	pvv.id = "pvv"
	pvv.name = "Partij voor de Vrijheid"
	pvv.abbreviation = "PVV"
	pvv.description = "Right-wing populist party advocating for national sovereignty and immigration restrictions."
	pvv.ideology_scores = {"economic_left_right": 0.2, "social_conservative_liberal": 0.7}
	pvv.policy_keywords = ["national_sovereignty", "immigration_control", "traditional_values", "eu_skepticism", "law_and_order"]
	pvv.color_primary = Color.ORANGE
	pvv.color_secondary = Color.YELLOW
	pvv.is_official = true
	parties.append(pvv)

	# CDA - Christian Democratic Appeal
	var cda = Party.new()
	cda.id = "cda"
	cda.name = "Christen-Democratisch Appèl"
	cda.abbreviation = "CDA"
	cda.description = "Christian democratic party promoting family values and community care."
	cda.ideology_scores = {"economic_left_right": 0.1, "social_conservative_liberal": 0.3}
	cda.policy_keywords = ["christian_values", "family_support", "community_care", "environmental_stewardship", "social_cohesion"]
	cda.color_primary = Color.GREEN
	cda.color_secondary = Color.LIGHT_GREEN
	cda.is_official = true
	parties.append(cda)

	# D66 - Democrats 66
	var d66 = Party.new()
	d66.id = "d66"
	d66.name = "Democraten 66"
	d66.abbreviation = "D66"
	d66.description = "Progressive liberal party focused on democratic reform and education."
	d66.ideology_scores = {"economic_left_right": 0.0, "social_conservative_liberal": -0.4}
	d66.policy_keywords = ["democratic_reform", "education_investment", "progressive_values", "eu_integration", "innovation_support"]
	d66.color_primary = Color.PURPLE
	d66.color_secondary = Color.VIOLET
	d66.is_official = true
	parties.append(d66)

	# GroenLinks - GreenLeft
	var gl = Party.new()
	gl.id = "groenlinks"
	gl.name = "GroenLinks"
	gl.abbreviation = "GL"
	gl.description = "Green progressive party prioritizing environmental protection and social justice."
	gl.ideology_scores = {"economic_left_right": -0.5, "social_conservative_liberal": -0.6}
	gl.policy_keywords = ["climate_action", "environmental_protection", "social_justice", "progressive_taxation", "sustainable_development"]
	gl.color_primary = Color.GREEN
	gl.color_secondary = Color.LIGHT_GREEN
	gl.is_official = true
	parties.append(gl)

	# SP - Socialist Party
	var sp = Party.new()
	sp.id = "sp"
	sp.name = "Socialistische Partij"
	sp.abbreviation = "SP"
	sp.description = "Democratic socialist party championing worker rights and social equality."
	sp.ideology_scores = {"economic_left_right": -0.7, "social_conservative_liberal": -0.3}
	sp.policy_keywords = ["worker_rights", "wealth_redistribution", "universal_healthcare", "social_housing", "public_ownership"]
	sp.color_primary = Color.RED
	sp.color_secondary = Color.LIGHT_PINK
	sp.is_official = true
	parties.append(sp)

	# PvdA - Labour Party
	var pvda = Party.new()
	pvda.id = "pvda"
	pvda.name = "Partij van de Arbeid"
	pvda.abbreviation = "PvdA"
	pvda.description = "Social democratic party focused on social justice and equality."
	pvda.ideology_scores = {"economic_left_right": -0.4, "social_conservative_liberal": -0.2}
	pvda.policy_keywords = ["social_justice", "progressive_taxation", "welfare_expansion", "workers_rights", "education_investment"]
	pvda.color_primary = Color.RED
	pvda.color_secondary = Color.LIGHT_PINK
	pvda.is_official = true
	parties.append(pvda)

	# ChristenUnie - ChristianUnion
	var cu = Party.new()
	cu.id = "christenunie"
	cu.name = "ChristenUnie"
	cu.abbreviation = "CU"
	cu.description = "Christian social party combining faith-based values with environmental care."
	cu.ideology_scores = {"economic_left_right": -0.1, "social_conservative_liberal": 0.4}
	cu.policy_keywords = ["christian_values", "environmental_stewardship", "social_care", "family_support", "creation_care"]
	cu.color_primary = Color.BLUE
	cu.color_secondary = Color.CYAN
	cu.is_official = true
	parties.append(cu)

	# SGP - Reformed Political Party
	var sgp = Party.new()
	sgp.id = "sgp"
	sgp.name = "Staatkundig Gereformeerde Partij"
	sgp.abbreviation = "SGP"
	sgp.description = "Orthodox Protestant party based on Reformed principles."
	sgp.ideology_scores = {"economic_left_right": 0.1, "social_conservative_liberal": 0.8}
	sgp.policy_keywords = ["reformed_principles", "traditional_values", "christian_governance", "family_values", "biblical_foundation"]
	sgp.color_primary = Color.BLACK
	sgp.color_secondary = Color.GRAY
	sgp.is_official = true
	parties.append(sgp)

	# DENK - DENK
	var denk = Party.new()
	denk.id = "denk"
	denk.name = "DENK"
	denk.abbreviation = "DENK"
	denk.description = "Multicultural party advocating for minority rights and integration."
	denk.ideology_scores = {"economic_left_right": -0.2, "social_conservative_liberal": -0.3}
	denk.policy_keywords = ["minority_rights", "multiculturalism", "anti_discrimination", "social_integration", "equality"]
	denk.color_primary = Color.MAGENTA
	denk.color_secondary = Color.PINK
	denk.is_official = true
	parties.append(denk)

	# FvD - Forum for Democracy
	var fvd = Party.new()
	fvd.id = "fvd"
	fvd.name = "Forum voor Democratie"
	fvd.abbreviation = "FvD"
	fvd.description = "Conservative populist party focused on direct democracy and national identity."
	fvd.ideology_scores = {"economic_left_right": 0.3, "social_conservative_liberal": 0.6}
	fvd.policy_keywords = ["direct_democracy", "national_identity", "eu_skepticism", "cultural_preservation", "referendum_democracy"]
	fvd.color_primary = Color(0.5, 0.2, 0.8)  # Purple
	fvd.color_secondary = Color(0.7, 0.4, 0.9)
	fvd.is_official = true
	parties.append(fvd)

	# JA21 - JA21
	var ja21 = Party.new()
	ja21.id = "ja21"
	ja21.name = "JA21"
	ja21.abbreviation = "JA21"
	ja21.description = "Conservative liberal party emphasizing law and order with economic liberalism."
	ja21.ideology_scores = {"economic_left_right": 0.4, "social_conservative_liberal": 0.3}
	ja21.policy_keywords = ["law_and_order", "economic_liberalism", "controlled_immigration", "national_security", "traditional_values"]
	ja21.color_primary = Color(0.2, 0.4, 0.8)  # Blue
	ja21.color_secondary = Color(0.4, 0.6, 0.9)
	ja21.is_official = true
	parties.append(ja21)

	# Volt - Volt Netherlands
	var volt = Party.new()
	volt.id = "volt"
	volt.name = "Volt Nederland"
	volt.abbreviation = "Volt"
	volt.description = "Pro-European progressive party focused on EU integration and modernization."
	volt.ideology_scores = {"economic_left_right": -0.2, "social_conservative_liberal": -0.5}
	volt.policy_keywords = ["eu_integration", "digital_transformation", "climate_action", "progressive_values", "european_cooperation"]
	volt.color_primary = Color(0.5, 0.2, 0.8)  # Purple
	volt.color_secondary = Color(0.7, 0.4, 0.9)
	volt.is_official = true
	parties.append(volt)

	# BIJ1 - BIJ1
	var bij1 = Party.new()
	bij1.id = "bij1"
	bij1.name = "BIJ1"
	bij1.abbreviation = "BIJ1"
	bij1.description = "Radical left party fighting against all forms of discrimination and oppression."
	bij1.ideology_scores = {"economic_left_right": -0.8, "social_conservative_liberal": -0.7}
	bij1.policy_keywords = ["anti_racism", "social_justice", "radical_equality", "anti_discrimination", "progressive_values"]
	bij1.color_primary = Color(0.8, 0.2, 0.5)  # Pink
	bij1.color_secondary = Color(0.9, 0.4, 0.7)
	bij1.is_official = true
	parties.append(bij1)

	# 50PLUS - 50PLUS
	var plus50 = Party.new()
	plus50.id = "50plus"
	plus50.name = "50PLUS"
	plus50.abbreviation = "50+"
	plus50.description = "Party representing the interests of older citizens and pensioners."
	plus50.ideology_scores = {"economic_left_right": -0.1, "social_conservative_liberal": 0.2}
	plus50.policy_keywords = ["pension_protection", "healthcare_expansion", "senior_rights", "social_security", "age_discrimination"]
	plus50.color_primary = Color(0.6, 0.4, 0.2)  # Brown
	plus50.color_secondary = Color(0.8, 0.6, 0.4)
	plus50.is_official = true
	parties.append(plus50)

	# PvdD - Party for the Animals
	var pvdd = Party.new()
	pvdd.id = "pvdd"
	pvdd.name = "Partij voor de Dieren"
	pvdd.abbreviation = "PvdD"
	pvdd.description = "Animal rights and environmental party focused on sustainability and animal welfare."
	pvdd.ideology_scores = {"economic_left_right": -0.3, "social_conservative_liberal": -0.4}
	pvdd.policy_keywords = ["animal_rights", "environmental_protection", "sustainable_development", "climate_action", "biodiversity"]
	pvdd.color_primary = Color(0.2, 0.6, 0.2)  # Green
	pvdd.color_secondary = Color(0.4, 0.8, 0.4)
	pvdd.is_official = true
	parties.append(pvdd)

	# BVNL - Belang van Nederland
	var bvnl = Party.new()
	bvnl.id = "bvnl"
	bvnl.name = "Belang van Nederland"
	bvnl.abbreviation = "BVNL"
	bvnl.description = "Conservative party emphasizing Dutch interests and traditional values."
	bvnl.ideology_scores = {"economic_left_right": 0.2, "social_conservative_liberal": 0.5}
	bvnl.policy_keywords = ["dutch_interests", "traditional_values", "national_sovereignty", "conservative_governance", "cultural_preservation"]
	bvnl.color_primary = Color(0.8, 0.4, 0.2)  # Orange
	bvnl.color_secondary = Color(0.9, 0.6, 0.4)
	bvnl.is_official = true
	parties.append(bvnl)

	# Piratenpartij - Pirate Party
	var piraten = Party.new()
	piraten.id = "piraten"
	piraten.name = "Piratenpartij"
	piraten.abbreviation = "PP"
	piraten.description = "Digital rights party focused on privacy, transparency, and internet freedom."
	piraten.ideology_scores = {"economic_left_right": -0.2, "social_conservative_liberal": -0.6}
	piraten.policy_keywords = ["digital_rights", "privacy_protection", "government_transparency", "internet_freedom", "direct_democracy"]
	piraten.color_primary = Color.BLACK
	piraten.color_secondary = Color.GRAY
	piraten.is_official = true
	parties.append(piraten)

	# LP - Libertarian Party
	var lp = Party.new()
	lp.id = "lp"
	lp.name = "Libertarische Partij"
	lp.abbreviation = "LP"
	lp.description = "Libertarian party advocating for minimal government and maximum individual freedom."
	lp.ideology_scores = {"economic_left_right": 0.7, "social_conservative_liberal": -0.3}
	lp.policy_keywords = ["minimal_government", "individual_freedom", "free_market", "personal_responsibility", "deregulation"]
	lp.color_primary = Color.YELLOW
	lp.color_secondary = Color(1.0, 1.0, 0.7)
	lp.is_official = true
	parties.append(lp)

	# BBB - BoerBurgerBeweging
	var bbb = Party.new()
	bbb.id = "bbb"
	bbb.name = "BoerBurgerBeweging"
	bbb.abbreviation = "BBB"
	bbb.description = "Farmer-citizen movement representing rural interests and agricultural concerns."
	bbb.ideology_scores = {"economic_left_right": 0.1, "social_conservative_liberal": 0.2}
	bbb.policy_keywords = ["farmer_rights", "rural_development", "agricultural_support", "countryside_preservation", "practical_governance"]
	bbb.color_primary = Color(0.2, 0.8, 0.2)  # Green
	bbb.color_secondary = Color(0.4, 0.9, 0.4)
	bbb.is_official = true
	parties.append(bbb)

	return parties