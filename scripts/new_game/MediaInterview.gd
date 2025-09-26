extends Control

# MediaInterview - UI for conducting the leader's first media interview
# Presents contextual questions and handles answer selection with impact preview

signal interview_complete(responses: Array)
signal question_answered(answer: MediaAnswer)
signal progress_changed()

@onready var progress_label = $MainContainer/InterviewProgress/ProgressLabel
@onready var progress_bar = $MainContainer/InterviewProgress/ProgressBar
@onready var question_category = $MainContainer/ContentArea/QuestionPanel/QuestionContainer/QuestionCategory
@onready var question_text = $MainContainer/ContentArea/QuestionPanel/QuestionContainer/QuestionText
@onready var answers_container = $MainContainer/ContentArea/QuestionPanel/QuestionContainer/AnswersContainer
@onready var impact_title = $MainContainer/ContentArea/ImpactPreview/ImpactContainer/ImpactTitle
@onready var impact_details = $MainContainer/ContentArea/ImpactPreview/ImpactContainer/ImpactDetails
@onready var status_label = $MainContainer/Footer/StatusLabel
@onready var next_button = $MainContainer/Footer/NextButton
@onready var finish_button = $MainContainer/Footer/FinishButton

var interview_questions: Array[MediaQuestion] = []
var current_question_index: int = 0
var selected_answers: Array[MediaAnswer] = []
var current_selected_answer: MediaAnswer = null

var answer_buttons: Array[Button] = []

func _ready():
	_setup_interview()

func _setup_interview():
	# Get party and leader from GameSetupState
	var party = GameSetupState.selected_party
	var leader = GameSetupState.leader

	if party == null or leader == null:
		push_error("MediaInterview: Missing party or leader data")
		return

	# Generate questions using QuestionSelector
	var question_selector = QuestionSelector.new()
	interview_questions = question_selector.select_questions(party, leader, 5)

	if interview_questions.size() == 0:
		push_error("MediaInterview: No questions generated")
		return

	# Setup progress bar
	progress_bar.max_value = interview_questions.size()
	progress_bar.value = 0

	# Start with first question
	_display_question(0)

	print("MediaInterview: Started interview with %d questions" % interview_questions.size())

func _display_question(question_index: int):
	if question_index < 0 or question_index >= interview_questions.size():
		return

	current_question_index = question_index
	var question = interview_questions[question_index]

	# Update progress
	progress_label.text = "Question %d of %d" % [question_index + 1, interview_questions.size()]
	progress_bar.value = question_index + 1

	# Display question
	question_category.text = question.category
	question_text.text = question.get_formatted_question()

	# Clear previous answer buttons
	for button in answer_buttons:
		button.queue_free()
	answer_buttons.clear()
	current_selected_answer = null

	# Create answer buttons
	for answer in question.answers:
		var button = _create_answer_button(answer)
		answers_container.add_child(button)
		answer_buttons.append(button)

	# Update UI state
	_update_button_states()
	_update_impact_preview()

func _create_answer_button(answer: MediaAnswer) -> Button:
	var button = Button.new()
	button.text = answer.text
	button.autowrap_mode = TextServer.AUTOWRAP_WORD
	button.custom_minimum_size.y = 60
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Style button based on impact type
	var impact_type = answer.get_dominant_impact_type()
	match impact_type:
		"positive":
			button.modulate = Color(0.9, 1.0, 0.9, 1)
		"negative":
			button.modulate = Color(1.0, 0.9, 0.9, 1)
		_:
			button.modulate = Color(0.95, 0.95, 0.95, 1)

	button.pressed.connect(_on_answer_selected.bind(answer, button))
	return button

func _update_button_states():
	# Update button appearance based on selection
	for i in range(answer_buttons.size()):
		var button = answer_buttons[i]
		var question = interview_questions[current_question_index]
		var answer = question.answers[i]

		if answer == current_selected_answer:
			button.disabled = false
			button.modulate = Color(0.8, 1.0, 0.8, 1)  # Highlight selected
		else:
			button.disabled = false
			var impact_type = answer.get_dominant_impact_type()
			match impact_type:
				"positive":
					button.modulate = Color(0.9, 1.0, 0.9, 1)
				"negative":
					button.modulate = Color(1.0, 0.9, 0.9, 1)
				_:
					button.modulate = Color(0.95, 0.95, 0.95, 1)

	# Update footer buttons
	var has_selection = current_selected_answer != null
	var is_last_question = current_question_index >= interview_questions.size() - 1

	next_button.disabled = not has_selection or is_last_question
	next_button.visible = not is_last_question
	finish_button.disabled = not has_selection
	finish_button.visible = is_last_question

	if has_selection:
		status_label.text = "Answer selected - continue when ready"
	else:
		status_label.text = "Select an answer to continue"

func _update_impact_preview():
	if current_selected_answer == null:
		impact_title.text = "Impact Preview"
		impact_details.text = "Select an answer to see its effects"
	else:
		impact_title.text = "Impact of Your Answer"
		impact_details.text = current_selected_answer.get_detailed_impact_description()

func _finalize_interview():
	print("MediaInterview: Interview completed with %d responses" % selected_answers.size())

	# Add all responses to GameSetupState
	for answer in selected_answers:
		GameSetupState.add_interview_response(answer)

	interview_complete.emit(selected_answers)

# Signal handlers
func _on_answer_selected(answer: MediaAnswer, button: Button):
	current_selected_answer = answer
	_update_button_states()
	_update_impact_preview()

	print("Answer selected: " + answer.text[:50] + "...")

func _on_next_button_pressed():
	if current_selected_answer == null:
		return

	# Store the answer
	selected_answers.append(current_selected_answer)
	question_answered.emit(current_selected_answer)

	# Move to next question
	if current_question_index < interview_questions.size() - 1:
		_display_question(current_question_index + 1)
		progress_changed.emit()
	else:
		# This shouldn't happen since next button is hidden on last question
		_finalize_interview()

func _on_finish_button_pressed():
	if current_selected_answer == null:
		return

	# Store the final answer
	selected_answers.append(current_selected_answer)
	question_answered.emit(current_selected_answer)

	# Complete the interview
	_finalize_interview()

# Public interface
func get_selected_answers() -> Array[MediaAnswer]:
	return selected_answers

func get_current_progress() -> float:
	if interview_questions.size() == 0:
		return 0.0
	return float(selected_answers.size()) / float(interview_questions.size())

func is_interview_complete() -> bool:
	return selected_answers.size() >= interview_questions.size()

func can_continue() -> bool:
	return current_selected_answer != null

# Development helpers
func skip_to_end():
	# For testing - automatically answer remaining questions
	while current_question_index < interview_questions.size():
		var question = interview_questions[current_question_index]
		if question.answers.size() > 0:
			var answer = question.answers[0]  # Select first answer
			selected_answers.append(answer)
			question_answered.emit(answer)

		current_question_index += 1

	_finalize_interview()

func preview_all_questions():
	# For debugging - print all questions
	print("Interview Questions Preview:")
	for i in range(interview_questions.size()):
		var question = interview_questions[i]
		print("%d. [%s] %s" % [i + 1, question.category, question.question_text])
		for j in range(question.answers.size()):
			var answer = question.answers[j]
			print("   %s. %s" % [char(65 + j), answer.text])
		print()