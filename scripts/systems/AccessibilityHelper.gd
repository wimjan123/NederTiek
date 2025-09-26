extends RefCounted
class_name AccessibilityHelper

# AccessibilityHelper - UI scaling, keyboard navigation, and color-blind safe colors
# Ensures the game meets accessibility requirements

# Color-blind safe color palette
const COLORBLIND_SAFE_COLORS = {
	# Primary political colors - accessible to most color vision types
	"blue_safe": Color(0.0, 0.447, 0.741),      # Safe blue
	"red_safe": Color(0.835, 0.369, 0.0),       # Safe red/orange
	"green_safe": Color(0.0, 0.620, 0.451),     # Safe green
	"purple_safe": Color(0.494, 0.184, 0.556),  # Safe purple
	"yellow_safe": Color(1.0, 0.769, 0.0),      # Safe yellow
	"brown_safe": Color(0.647, 0.365, 0.157),   # Safe brown
	"pink_safe": Color(0.906, 0.471, 0.643),    # Safe pink
	"grey_safe": Color(0.4, 0.4, 0.4),          # Safe grey

	# UI element colors
	"text_primary": Color(0.9, 0.9, 0.9),       # High contrast text
	"text_secondary": Color(0.7, 0.7, 0.7),     # Medium contrast text
	"background_dark": Color(0.1, 0.1, 0.12),   # Dark background
	"background_light": Color(0.2, 0.2, 0.25),  # Light background
	"accent_safe": Color(0.0, 0.620, 0.451),    # Safe accent color
	"warning_safe": Color(1.0, 0.769, 0.0),     # Safe warning color
	"error_safe": Color(0.835, 0.369, 0.0),     # Safe error color
	"success_safe": Color(0.0, 0.620, 0.451)    # Safe success color
}

# UI scaling factors
const UI_SCALE_FACTORS = {
	"small": 0.75,
	"normal": 1.0,
	"large": 1.25,
	"extra_large": 1.5
}

# Font size adjustments for accessibility
const FONT_SIZE_ADJUSTMENTS = {
	"small": -2,
	"normal": 0,
	"large": 4,
	"extra_large": 8
}

static func apply_colorblind_safe_theme(theme: Theme):
	"""Apply color-blind safe colors to a theme resource."""
	if theme == null:
		return

	# Button colors
	theme.set_color("font_color", "Button", COLORBLIND_SAFE_COLORS.text_primary)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", COLORBLIND_SAFE_COLORS.text_secondary)

	# Label colors
	theme.set_color("font_color", "Label", COLORBLIND_SAFE_COLORS.text_primary)

	# Create accessible button styles
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = COLORBLIND_SAFE_COLORS.background_light
	normal_style.border_color = COLORBLIND_SAFE_COLORS.accent_safe
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_width_top = 2
	normal_style.border_width_bottom = 2

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = COLORBLIND_SAFE_COLORS.accent_safe
	hover_style.border_color = COLORBLIND_SAFE_COLORS.text_primary
	hover_style.border_width_left = 2
	hover_style.border_width_right = 2
	hover_style.border_width_top = 2
	hover_style.border_width_bottom = 2

	theme.set_stylebox("normal", "Button", normal_style)
	theme.set_stylebox("hover", "Button", hover_style)

	print("AccessibilityHelper: Applied colorblind-safe theme")

static func setup_keyboard_navigation(control: Control):
	"""Setup keyboard navigation for a control and its children."""
	_setup_keyboard_navigation_recursive(control)
	print("AccessibilityHelper: Keyboard navigation configured for " + control.name)

static func _setup_keyboard_navigation_recursive(control: Control):
	"""Recursively setup keyboard navigation."""
	# Enable focus for interactive controls
	if control is Button or control is CheckBox or control is LineEdit or control is TextEdit:
		control.focus_mode = Control.FOCUS_ALL

	# Setup navigation connections for immediate children
	var focusable_children = []
	for child in control.get_children():
		if child is Control:
			_setup_keyboard_navigation_recursive(child)
			if child.focus_mode == Control.FOCUS_ALL:
				focusable_children.append(child)

	# Link focusable children in sequence
	for i in range(focusable_children.size()):
		var current = focusable_children[i]
		var next = focusable_children[(i + 1) % focusable_children.size()]
		var prev = focusable_children[(i - 1 + focusable_children.size()) % focusable_children.size()]

		current.focus_next = next.get_path()
		current.focus_previous = prev.get_path()

static func apply_ui_scaling(control: Control, scale_factor: float):
	"""Apply UI scaling to a control and its children."""
	_apply_ui_scaling_recursive(control, scale_factor)
	print("AccessibilityHelper: Applied %.2fx UI scaling to %s" % [scale_factor, control.name])

static func _apply_ui_scaling_recursive(control: Control, scale_factor: float):
	"""Recursively apply UI scaling."""
	# Scale the control
	control.scale = Vector2(scale_factor, scale_factor)

	# Adjust font sizes for labels and buttons
	if control is Label or control is Button:
		var theme = control.theme
		if theme == null:
			theme = Theme.new()
			control.theme = theme

		var base_font_size = 16  # Default font size
		var new_font_size = int(base_font_size * scale_factor)
		theme.set_font_size("font_size", control.get_class(), new_font_size)

	# Apply to children
	for child in control.get_children():
		if child is Control:
			_apply_ui_scaling_recursive(child, scale_factor)

static func get_safe_party_color(party_name: String, index: int = 0) -> Color:
	"""Get a color-blind safe color for a political party."""
	var safe_colors = [
		COLORBLIND_SAFE_COLORS.blue_safe,
		COLORBLIND_SAFE_COLORS.red_safe,
		COLORBLIND_SAFE_COLORS.green_safe,
		COLORBLIND_SAFE_COLORS.purple_safe,
		COLORBLIND_SAFE_COLORS.yellow_safe,
		COLORBLIND_SAFE_COLORS.brown_safe,
		COLORBLIND_SAFE_COLORS.pink_safe,
		COLORBLIND_SAFE_COLORS.grey_safe
	]

	# Use hash of party name for consistent color assignment
	var hash = party_name.hash()
	var color_index = abs(hash + index) % safe_colors.size()
	return safe_colors[color_index]

static func ensure_sufficient_contrast(foreground: Color, background: Color, min_ratio: float = 4.5) -> Color:
	"""Ensure sufficient contrast between foreground and background colors."""
	var contrast_ratio = _calculate_contrast_ratio(foreground, background)

	if contrast_ratio >= min_ratio:
		return foreground

	# Adjust foreground color for better contrast
	var adjusted_foreground = foreground
	if _get_relative_luminance(background) > 0.5:
		# Light background - darken foreground
		adjusted_foreground = Color(
			foreground.r * 0.7,
			foreground.g * 0.7,
			foreground.b * 0.7,
			foreground.a
		)
	else:
		# Dark background - lighten foreground
		adjusted_foreground = Color(
			min(foreground.r * 1.5, 1.0),
			min(foreground.g * 1.5, 1.0),
			min(foreground.b * 1.5, 1.0),
			foreground.a
		)

	return adjusted_foreground

static func _calculate_contrast_ratio(color1: Color, color2: Color) -> float:
	"""Calculate the contrast ratio between two colors."""
	var lum1 = _get_relative_luminance(color1)
	var lum2 = _get_relative_luminance(color2)

	var lighter = max(lum1, lum2)
	var darker = min(lum1, lum2)

	return (lighter + 0.05) / (darker + 0.05)

static func _get_relative_luminance(color: Color) -> float:
	"""Calculate the relative luminance of a color."""
	var r = _linearize_rgb_component(color.r)
	var g = _linearize_rgb_component(color.g)
	var b = _linearize_rgb_component(color.b)

	return 0.2126 * r + 0.7152 * g + 0.0722 * b

static func _linearize_rgb_component(component: float) -> float:
	"""Linearize an RGB component for luminance calculation."""
	if component <= 0.03928:
		return component / 12.92
	else:
		return pow((component + 0.055) / 1.055, 2.4)

static func add_screen_reader_support(control: Control, description: String):
	"""Add screen reader support to a control."""
	# Set accessible description
	if control.has_method("set_accessible_description"):
		control.set_accessible_description(description)

	# For buttons, ensure they have proper labels
	if control is Button:
		if control.text.strip_edges() == "":
			control.text = description

	print("AccessibilityHelper: Added screen reader support to " + control.name)

static func create_accessibility_settings() -> Dictionary:
	"""Create default accessibility settings."""
	return {
		"ui_scale": "normal",
		"colorblind_safe_mode": true,
		"high_contrast": false,
		"keyboard_navigation": true,
		"screen_reader_support": true,
		"font_size_adjustment": "normal"
	}

static func apply_accessibility_settings(settings: Dictionary, root_control: Control):
	"""Apply accessibility settings to the entire UI."""
	print("AccessibilityHelper: Applying accessibility settings")

	# Apply UI scaling
	var scale_name = settings.get("ui_scale", "normal")
	var scale_factor = UI_SCALE_FACTORS.get(scale_name, 1.0)
	if scale_factor != 1.0:
		apply_ui_scaling(root_control, scale_factor)

	# Apply colorblind safe mode
	if settings.get("colorblind_safe_mode", true):
		var theme = root_control.theme
		if theme != null:
			apply_colorblind_safe_theme(theme)

	# Setup keyboard navigation
	if settings.get("keyboard_navigation", true):
		setup_keyboard_navigation(root_control)

	print("AccessibilityHelper: Accessibility settings applied successfully")

# Test function for development
static func run_accessibility_tests():
	print("=== AccessibilityHelper Tests ===")

	# Test contrast ratios
	var white = Color.WHITE
	var black = Color.BLACK
	var contrast = _calculate_contrast_ratio(white, black)
	print("White/Black contrast ratio: %.2f (should be 21.0)" % contrast)

	# Test safe colors
	for i in range(8):
		var color = get_safe_party_color("Test Party %d" % i, i)
		print("Safe party color %d: %s" % [i, color])

	print("AccessibilityHelper tests completed")