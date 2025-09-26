extends Control

# MainMenu - Main menu scene for NederTiek
# Handles navigation to different game modes and settings

@onready var new_game_button = $CenterContainer/MainContainer/MenuButtons/NewGameButton
@onready var load_game_button = $CenterContainer/MainContainer/MenuButtons/LoadGameButton
@onready var settings_button = $CenterContainer/MainContainer/MenuButtons/SettingsButton
@onready var credits_button = $CenterContainer/MainContainer/MenuButtons/CreditsButton
@onready var quit_button = $CenterContainer/MainContainer/MenuButtons/QuitButton
@onready var version_label = $CenterContainer/MainContainer/FooterContainer/VersionLabel

func _ready():
	# Set up initial focus
	new_game_button.grab_focus()

	# Check for saved games to enable/disable load button
	_check_saved_games()

	# Set version from project settings
	var version = ProjectSettings.get_setting("application/config/version", "0.1.0")
	version_label.text = "Version %s - Alpha" % version

	print("MainMenu: Ready")

func _check_saved_games():
	"""Check if there are any saved games to enable the Load Game button."""
	var dir = DirAccess.open("user://")
	if dir == null:
		load_game_button.disabled = true
		return

	# Check for save files
	var has_saves = false
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.ends_with(".save") or file_name.ends_with(".cfg"):
			has_saves = true
			break
		file_name = dir.get_next()

	dir.list_dir_end()
	load_game_button.disabled = not has_saves

	if has_saves:
		print("MainMenu: Found saved games")
	else:
		print("MainMenu: No saved games found")

func _on_new_game_button_pressed():
	"""Start a new game - transition to new game setup flow."""
	print("MainMenu: Starting new game")

	# Clear any existing setup state
	GameSetupState.reset()

	# Transition to new game flow
	get_tree().change_scene_to_file("res://scenes/new_game/NewGameFlow.tscn")

func _on_load_game_button_pressed():
	"""Load an existing game - show load game interface."""
	print("MainMenu: Loading game")

	# For now, try to load the most recent save
	_try_load_recent_save()

func _try_load_recent_save():
	"""Attempt to load the most recent save file."""
	var config = ConfigFile.new()

	# Try to load new game setup save first
	var setup_error = config.load("user://new_game_setup.cfg")
	if setup_error == OK:
		print("MainMenu: Found new game setup save, resuming...")
		GameSetupState.load_setup_state({
			"party": config.get_value("setup", "party_data", {}),
			"leader": config.get_value("setup", "leader_data", {}),
			"background": config.get_value("setup", "background_data", {}),
			"interview_responses": config.get_value("setup", "interview_responses", [])
		})
		get_tree().change_scene_to_file("res://scenes/new_game/NewGameFlow.tscn")
		return

	# TODO: Try to load main game saves
	print("MainMenu: No compatible save files found")

func _on_settings_button_pressed():
	"""Open settings menu."""
	print("MainMenu: Opening settings")
	# TODO: Implement settings scene
	# get_tree().change_scene_to_file("res://scenes/settings/Settings.tscn")

func _on_credits_button_pressed():
	"""Show credits."""
	print("MainMenu: Showing credits")
	# TODO: Implement credits scene
	# get_tree().change_scene_to_file("res://scenes/credits/Credits.tscn")

func _on_quit_button_pressed():
	"""Quit the game."""
	print("MainMenu: Quitting game")
	get_tree().quit()

# Keyboard navigation
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# ESC key pressed - same as quit for main menu
		_on_quit_button_pressed()

# Public interface for returning to main menu
func return_to_main_menu():
	"""Public method for other scenes to return to main menu."""
	_check_saved_games()  # Refresh save game status
	new_game_button.grab_focus()  # Reset focus
	print("MainMenu: Returned to main menu")