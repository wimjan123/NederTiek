extends Panel
class_name BackgroundCard

# BackgroundCard - Reusable UI component for displaying leader background information
# Used in leader creation screen for background selection

signal background_selected(background: LeaderBackground)

@onready var background_name = $CardContainer/Header/BackgroundName
@onready var impact_summary = $CardContainer/Header/ImpactSummary
@onready var description = $CardContainer/Description
@onready var attributes_list = $CardContainer/AttributesContainer/AttributesList
@onready var traits_label = $CardContainer/Footer/TraitsLabel
@onready var select_button = $CardContainer/Footer/SelectButton

var background_data: LeaderBackground = null
var is_selected: bool = false

func setup_background(background: LeaderBackground):
	background_data = background
	_update_display()

func _update_display():
	if background_data == null:
		return

	# Update header
	background_name.text = background_data.name
	impact_summary.text = background_data.get_impact_summary()

	# Update description
	description.text = background_data.description
	description.tooltip_text = _get_detailed_tooltip()

	# Update attributes list
	var attribute_changes: Array = []
	for attr_key in background_data.attribute_modifiers.keys():
		var modifier = background_data.attribute_modifiers[attr_key]
		if modifier != 0:
			var sign = "+" if modifier > 0 else ""
			attribute_changes.append("%s %s%d" % [attr_key.capitalize(), sign, modifier])

	if attribute_changes.size() > 0:
		attributes_list.text = ", ".join(attribute_changes)
	else:
		attributes_list.text = "No attribute changes"

	# Update traits
	if background_data.special_traits.size() > 0:
		traits_label.text = ", ".join(background_data.special_traits)
	else:
		traits_label.text = "No special traits"

func set_selected(selected: bool):
	is_selected = selected
	_update_visual_state()

func _update_visual_state():
	if is_selected:
		modulate = Color(0.9, 1.0, 0.9, 1)
		select_button.text = "Selected"
		select_button.disabled = true
	else:
		modulate = Color(1, 1, 1, 1)
		select_button.text = "Select"
		select_button.disabled = false

func _on_select_button_pressed():
	if background_data != null:
		background_selected.emit(background_data)

# Public interface
func get_background() -> LeaderBackground:
	return background_data

func set_button_text(text: String):
	select_button.text = text

func set_button_enabled(enabled: bool):
	select_button.disabled = not enabled

# Helper methods for detailed information display
func get_detailed_description() -> String:
	if background_data == null:
		return ""

	var details = background_data.description + "\n\n"

	# Add attribute details
	details += "Attribute Modifiers:\n"
	for attr_key in background_data.attribute_modifiers.keys():
		var modifier = background_data.attribute_modifiers[attr_key]
		if modifier != 0:
			var sign = "+" if modifier > 0 else ""
			details += "• %s: %s%d\n" % [attr_key.capitalize(), sign, modifier]

	# Add economic impacts
	if background_data.treasury_modifier != 1.0:
		var percentage = (background_data.treasury_modifier - 1.0) * 100
		var sign = "+" if percentage > 0 else ""
		details += "\nTreasury Modifier: %s%.0f%%\n" % [sign, percentage]

	if background_data.popularity_modifier != 0.0:
		var sign = "+" if background_data.popularity_modifier > 0 else ""
		details += "Popularity Modifier: %s%.1f%%\n" % [sign, background_data.popularity_modifier]

	# Add special traits
	if background_data.special_traits.size() > 0:
		details += "\nSpecial Traits:\n"
		for trait in background_data.special_traits:
			details += "• " + trait + "\n"

	return details

func _get_detailed_tooltip() -> String:
	if background_data == null:
		return ""

	var tooltip = background_data.description + "\n\n"

	# Add political context explanations
	tooltip += "Political Impact:\n"

	# Explain attribute effects in political context
	for attr_key in background_data.attribute_modifiers.keys():
		var modifier = background_data.attribute_modifiers[attr_key]
		if modifier != 0:
			var sign = "+" if modifier > 0 else ""
			var explanation = _get_attribute_explanation(attr_key, modifier)
			tooltip += "• %s %s%d: %s\n" % [attr_key.capitalize(), sign, modifier, explanation]

	# Explain economic effects
	if background_data.treasury_modifier != 1.0:
		var percentage = (background_data.treasury_modifier - 1.0) * 100
		var explanation = _get_treasury_explanation(percentage)
		tooltip += "\n" + explanation

	if background_data.popularity_modifier != 0.0:
		var explanation = _get_popularity_explanation(background_data.popularity_modifier)
		tooltip += "\n" + explanation

	return tooltip

func _get_attribute_explanation(attribute: String, modifier: int) -> String:
	match attribute.to_lower():
		"charisma":
			if modifier > 0:
				return "Better at public speaking and media appearances"
			else:
				return "May struggle with public perception and media relations"
		"intelligence":
			if modifier > 0:
				return "More effective at policy development and complex decisions"
			else:
				return "May face challenges with detailed policy work"
		"experience":
			if modifier > 0:
				return "Better understanding of political processes and networks"
			else:
				return "Less familiar with political establishment and procedures"
		"integrity":
			if modifier > 0:
				return "Higher public trust and resistance to corruption scandals"
			else:
				return "More susceptible to ethical controversies"
		"networking":
			if modifier > 0:
				return "Better connections with other politicians and stakeholders"
			else:
				return "Fewer established political relationships"
		_:
			return "Affects leadership effectiveness"

func _get_treasury_explanation(percentage: float) -> String:
	if percentage > 0:
		return "Starting Treasury Bonus: +%.0f%% (Better fundraising connections)" % percentage
	else:
		return "Starting Treasury Penalty: %.0f%% (Limited initial funding)" % percentage

func _get_popularity_explanation(modifier: float) -> String:
	if modifier > 0:
		return "Starting Popularity Bonus: +%.1f%% (Public recognizes this background)" % modifier
	else:
		return "Starting Popularity Challenge: %.1f%% (Public may be skeptical)" % modifier