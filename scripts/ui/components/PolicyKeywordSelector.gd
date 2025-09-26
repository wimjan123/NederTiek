extends VBoxContainer
class_name PolicyKeywordSelector

# PolicyKeywordSelector - Component for selecting policy keywords with category requirements
# Validates selection against minimum requirements and prevents conflicts

signal selection_changed(keywords: Array[String])
signal validation_changed(is_valid: bool)

@onready var progress_label = $Header/ProgressContainer/ProgressLabel
@onready var progress_bar = $Header/ProgressContainer/ProgressBar
@onready var categories_container = $ContentArea/CategoriesContainer
@onready var validation_label = $Footer/ValidationLabel

var selected_keywords: Array[String] = []
var keyword_checkboxes: Dictionary = {}
var min_keywords: int = 5
var max_keywords: int = 10

# Category requirements
var category_requirements = {
	"Economic": 2,
	"Social": 2,
	"Other": 1  # Any other category
}

# Available keywords by category
var keyword_categories = {
	"Economic": [
		{"id": "progressive_taxation", "name": "Progressive Taxation", "desc": "Higher tax rates for higher income brackets"},
		{"id": "tax_reduction", "name": "Tax Reduction", "desc": "Lower taxes to stimulate economic growth"},
		{"id": "free_market_economy", "name": "Free Market Economy", "desc": "Minimal government intervention in markets"},
		{"id": "wealth_redistribution", "name": "Wealth Redistribution", "desc": "Policies to reduce income inequality"},
		{"id": "universal_basic_income", "name": "Universal Basic Income", "desc": "Unconditional regular payments to all citizens"},
		{"id": "business_friendly_policy", "name": "Business-Friendly Policy", "desc": "Policies that support business growth"}
	],
	"Social": [
		{"id": "universal_healthcare", "name": "Universal Healthcare", "desc": "Free healthcare for all citizens"},
		{"id": "social_housing", "name": "Social Housing", "desc": "Government-provided affordable housing"},
		{"id": "traditional_values", "name": "Traditional Values", "desc": "Preserve established cultural and family norms"},
		{"id": "progressive_values", "name": "Progressive Values", "desc": "Support for social change and equality"},
		{"id": "welfare_expansion", "name": "Welfare Expansion", "desc": "Expanded social safety net programs"},
		{"id": "civil_rights", "name": "Civil Rights", "desc": "Protection of individual freedoms and equality"}
	],
	"Environmental": [
		{"id": "green_energy_transition", "name": "Green Energy Transition", "desc": "Rapid shift to renewable energy sources"},
		{"id": "climate_action", "name": "Strong Climate Action", "desc": "Aggressive policies to combat climate change"},
		{"id": "environmental_protection", "name": "Environmental Protection", "desc": "Strict environmental regulations and conservation"},
		{"id": "sustainable_development", "name": "Sustainable Development", "desc": "Development that meets present needs without compromising the future"}
	],
	"EU & International": [
		{"id": "eu_integration", "name": "Deeper EU Integration", "desc": "Support for closer European political and economic union"},
		{"id": "national_sovereignty", "name": "National Sovereignty", "desc": "Protect national autonomy from EU interference"},
		{"id": "international_solidarity", "name": "International Solidarity", "desc": "Support for global cooperation and aid"},
		{"id": "development_aid", "name": "Development Aid", "desc": "Increased foreign aid and development assistance"}
	],
	"Governance": [
		{"id": "direct_democracy", "name": "Direct Democracy", "desc": "More referendums and citizen participation"},
		{"id": "democratic_reform", "name": "Democratic Reform", "desc": "Improvements to democratic institutions and processes"},
		{"id": "decentralization", "name": "Decentralization", "desc": "Transfer power from central to local government"},
		{"id": "transparency", "name": "Government Transparency", "desc": "Open government and freedom of information"}
	]
}

# Conflicting keywords that cannot be selected together
var keyword_conflicts = {
	"progressive_taxation": ["tax_reduction"],
	"tax_reduction": ["progressive_taxation", "wealth_redistribution"],
	"free_market_economy": ["wealth_redistribution", "universal_basic_income"],
	"traditional_values": ["progressive_values"],
	"progressive_values": ["traditional_values"],
	"eu_integration": ["national_sovereignty"],
	"national_sovereignty": ["eu_integration"]
}

func _ready():
	_setup_categories()
	_update_display()

func _setup_categories():
	# Clear existing content
	for child in categories_container.get_children():
		child.queue_free()

	keyword_checkboxes.clear()

	# Create category sections
	for category_name in keyword_categories.keys():
		var category_section = _create_category_section(category_name)
		categories_container.add_child(category_section)

func _create_category_section(category_name: String) -> VBoxContainer:
	var section = VBoxContainer.new()

	# Category header
	var header = Label.new()
	var requirement = category_requirements.get(category_name, category_requirements.get("Other", 0))
	header.text = "%s (select %d+ from this category)" % [category_name, requirement]
	header.add_theme_stylebox_override("normal", StyleBoxFlat.new())
	section.add_child(header)

	# Create checkboxes for keywords in this category
	var keywords = keyword_categories[category_name]
	for keyword_data in keywords:
		var checkbox = _create_keyword_checkbox(keyword_data, category_name)
		section.add_child(checkbox)
		keyword_checkboxes[keyword_data["id"]] = {
			"checkbox": checkbox,
			"category": category_name,
			"data": keyword_data
		}

	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	section.add_child(spacer)

	return section

func _create_keyword_checkbox(keyword_data: Dictionary, category: String) -> CheckBox:
	var checkbox = CheckBox.new()
	checkbox.text = keyword_data["name"]
	checkbox.tooltip_text = keyword_data["desc"]
	checkbox.toggled.connect(_on_keyword_toggled.bind(keyword_data["id"]))

	return checkbox

func _on_keyword_toggled(keyword_id: String, pressed: bool):
	if pressed:
		# Check for conflicts before adding
		if _has_conflicts(keyword_id):
			var checkbox = keyword_checkboxes[keyword_id]["checkbox"]
			checkbox.set_pressed_no_signal(false)
			_show_conflict_warning(keyword_id)
			return

		# Check if we're at the maximum
		if selected_keywords.size() >= max_keywords:
			var checkbox = keyword_checkboxes[keyword_id]["checkbox"]
			checkbox.set_pressed_no_signal(false)
			_show_max_warning()
			return

		# Add keyword
		selected_keywords.append(keyword_id)
	else:
		# Remove keyword
		selected_keywords.erase(keyword_id)

	_update_display()
	selection_changed.emit(selected_keywords)

func _has_conflicts(keyword_id: String) -> bool:
	if keyword_id not in keyword_conflicts:
		return false

	var conflicts = keyword_conflicts[keyword_id]
	for selected_keyword in selected_keywords:
		if selected_keyword in conflicts:
			return true

	return false

func _show_conflict_warning(keyword_id: String):
	var conflicts = keyword_conflicts[keyword_id]
	var conflict_names: Array[String] = []

	for conflict_id in conflicts:
		if conflict_id in selected_keywords:
			var conflict_data = _get_keyword_data(conflict_id)
			if conflict_data != null:
				conflict_names.append(conflict_data["name"])

	validation_label.text = "Cannot select: conflicts with " + ", ".join(conflict_names)
	validation_label.modulate = Color(1, 0.5, 0.5, 1)

func _show_max_warning():
	validation_label.text = "Maximum %d keywords allowed" % max_keywords
	validation_label.modulate = Color(1, 0.8, 0.5, 1)

func _get_keyword_data(keyword_id: String) -> Dictionary:
	for category in keyword_categories.values():
		for keyword_data in category:
			if keyword_data["id"] == keyword_id:
				return keyword_data
	return {}

func _update_display():
	# Update progress
	progress_label.text = "Selected: %d/%d" % [selected_keywords.size(), max_keywords]
	progress_bar.value = selected_keywords.size()

	# Update validation
	var validation = _validate_selection()
	if validation["valid"]:
		validation_label.text = "✓ Selection meets requirements"
		validation_label.modulate = Color(0.5, 1, 0.5, 1)
	elif selected_keywords.size() == 0:
		validation_label.text = "Select keywords to get started"
		validation_label.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		validation_label.text = "Issues: " + ", ".join(validation["errors"])
		validation_label.modulate = Color(1, 0.5, 0.5, 1)

	validation_changed.emit(validation["valid"])

func _validate_selection() -> Dictionary:
	var errors: Array[String] = []

	# Check minimum/maximum count
	if selected_keywords.size() < min_keywords:
		errors.append("Need at least %d keywords" % min_keywords)
	elif selected_keywords.size() > max_keywords:
		errors.append("Too many keywords (max %d)" % max_keywords)

	# Check category requirements
	var category_counts = _count_by_category()

	for category in ["Economic", "Social"]:
		var required = category_requirements.get(category, 0)
		var actual = category_counts.get(category, 0)
		if actual < required:
			errors.append("Need %d+ %s keywords" % [required, category])

	# Check "Other" category requirement
	var other_count = 0
	for category in category_counts.keys():
		if category not in ["Economic", "Social"]:
			other_count += category_counts[category]

	var other_required = category_requirements.get("Other", 0)
	if other_count < other_required:
		errors.append("Need %d+ keywords from other categories" % other_required)

	return {
		"valid": errors.size() == 0,
		"errors": errors
	}

func _count_by_category() -> Dictionary:
	var counts = {}

	for keyword_id in selected_keywords:
		if keyword_id in keyword_checkboxes:
			var category = keyword_checkboxes[keyword_id]["category"]
			counts[category] = counts.get(category, 0) + 1

	return counts

# Public interface
func get_selected_keywords() -> Array[String]:
	return selected_keywords.duplicate()

func set_selected_keywords(keywords: Array[String]):
	# Clear current selection
	for keyword_id in keyword_checkboxes.keys():
		var checkbox = keyword_checkboxes[keyword_id]["checkbox"]
		checkbox.set_pressed_no_signal(false)

	selected_keywords.clear()

	# Set new selection
	for keyword_id in keywords:
		if keyword_id in keyword_checkboxes:
			var checkbox = keyword_checkboxes[keyword_id]["checkbox"]
			checkbox.set_pressed_no_signal(true)
			selected_keywords.append(keyword_id)

	_update_display()

func is_valid() -> bool:
	return _validate_selection()["valid"]

func get_validation_errors() -> Array[String]:
	return _validate_selection()["errors"]

func set_requirements(min_count: int, max_count: int, category_reqs: Dictionary = {}):
	min_keywords = min_count
	max_keywords = max_count

	if category_reqs.size() > 0:
		category_requirements = category_reqs

	progress_bar.max_value = max_keywords
	_update_display()