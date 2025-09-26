class_name QuestionSelector
extends Node

# QuestionSelector - System for selecting appropriate interview questions
# Based on party ideology, leader background, and contextual requirements

# Question pools loaded from data
var all_questions: Array[MediaQuestion] = []
var questions_by_category: Dictionary = {}
var questions_by_difficulty: Dictionary = {}

# Selection settings
var random_generator: RandomNumberGenerator

func _init():
	random_generator = RandomNumberGenerator.new()
	random_generator.randomize()
	_load_question_pools()

# Select contextual questions for the media interview
func select_questions(party: Party, leader: Leader, count: int = 5) -> Array[MediaQuestion]:
	if party == null or leader == null:
		push_error("QuestionSelector: Cannot select questions without party and leader")
		return []

	if count < 1 or count > 10:
		push_error("QuestionSelector: Invalid question count: " + str(count))
		return []

	print("QuestionSelector: Selecting %d questions for %s (%s)" %
		  [count, leader.get_full_name(), party.get_display_name()])

	# Filter questions by appropriateness
	var appropriate_questions = _filter_appropriate_questions(party, leader)

	if appropriate_questions.size() < count:
		print("Warning: Only %d appropriate questions found, requested %d" %
			  [appropriate_questions.size(), count])

	# Select diverse questions ensuring variety
	var selected_questions = _select_diverse_questions(appropriate_questions, count, party, leader)

	# Ensure no duplicates
	var unique_questions: Array[MediaQuestion] = []
	var used_ids: Array[String] = []

	for question in selected_questions:
		if question.id not in used_ids:
			unique_questions.append(question)
			used_ids.append(question.id)

	print("QuestionSelector: Selected %d unique questions" % unique_questions.size())
	return unique_questions

# Filter questions that are appropriate for the given context
func _filter_appropriate_questions(party: Party, leader: Leader) -> Array[MediaQuestion]:
	var appropriate: Array[MediaQuestion] = []

	for question in all_questions:
		if question.is_appropriate_for_context(party, leader):
			appropriate.append(question)

	print("QuestionSelector: %d/%d questions are appropriate for this context" %
		  [appropriate.size(), all_questions.size()])

	return appropriate

# Select diverse questions ensuring variety across categories and difficulties
func _select_diverse_questions(available: Array[MediaQuestion], count: int, party: Party, leader: Leader) -> Array[MediaQuestion]:
	if available.size() == 0:
		return []

	var selected: Array[MediaQuestion] = []
	var remaining = available.duplicate()
	var used_categories: Array[String] = []

	# First pass: Select one question from each category
	var categories_covered = 0
	while selected.size() < count and categories_covered < 4 and remaining.size() > 0:
		var category_questions = _get_questions_by_category(remaining)

		# Find an unused category
		for category in category_questions.keys():
			if category not in used_categories and selected.size() < count:
				var category_list = category_questions[category]
				if category_list.size() > 0:
					var question = _select_best_question_from_list(category_list, party, leader)
					if question != null:
						selected.append(question)
						used_categories.append(category)
						remaining.erase(question)
						categories_covered += 1
						break

		# Prevent infinite loop
		if categories_covered == used_categories.size():
			break

	# Second pass: Fill remaining slots with best available questions
	while selected.size() < count and remaining.size() > 0:
		var best_question = _select_best_question_from_list(remaining, party, leader)
		if best_question != null:
			selected.append(best_question)
			remaining.erase(best_question)
		else:
			break

	# Third pass: If still need more questions, add any remaining
	while selected.size() < count and remaining.size() > 0:
		var random_question = remaining[random_generator.randi() % remaining.size()]
		selected.append(random_question)
		remaining.erase(random_question)

	return selected

# Group questions by category
func _get_questions_by_category(questions: Array[MediaQuestion]) -> Dictionary:
	var by_category: Dictionary = {}

	for question in questions:
		var category = question.category
		if category not in by_category:
			by_category[category] = []
		by_category[category].append(question)

	return by_category

# Select the best question from a list based on context
func _select_best_question_from_list(questions: Array[MediaQuestion], party: Party, leader: Leader) -> MediaQuestion:
	if questions.size() == 0:
		return null

	# Score each question based on relevance
	var scored_questions: Array[Dictionary] = []

	for question in questions:
		var score = _calculate_question_relevance_score(question, party, leader)
		scored_questions.append({"question": question, "score": score})

	# Sort by score (highest first)
	scored_questions.sort_custom(func(a, b): return a["score"] > b["score"])

	# Select from top 3 to add some randomness
	var top_count = min(3, scored_questions.size())
	var selected_index = random_generator.randi() % top_count

	return scored_questions[selected_index]["question"]

# Calculate how relevant a question is to the party and leader
func _calculate_question_relevance_score(question: MediaQuestion, party: Party, leader: Leader) -> float:
	var score = 0.0

	# Base score
	score += 1.0

	# Bonus for matching policy keywords
	if "policy_keywords" in question.context_requirements:
		var required_keywords = question.context_requirements["policy_keywords"]
		for keyword in required_keywords:
			if keyword in party.policy_keywords:
				score += 2.0
				break  # Found at least one match

	# Bonus for matching leader background
	if "leader_background" in question.context_requirements:
		var allowed_backgrounds = question.context_requirements["leader_background"]
		if leader.background_id in allowed_backgrounds:
			score += 1.5

	# Bonus for appropriate difficulty
	if "difficulty_level" in question.context_requirements:
		var difficulty = question.context_requirements["difficulty_level"]
		# Prefer moderate difficulty (2-3)
		if difficulty >= 2 and difficulty <= 3:
			score += 1.0
		elif difficulty == 1 or difficulty == 4:
			score += 0.5

	# Bonus for ideology alignment
	if "party_ideology" in question.context_requirements:
		var ideology_requirements = question.context_requirements["party_ideology"]
		for ideology_key in ideology_requirements.keys():
			if ideology_key in party.ideology_scores:
				var party_score = party.ideology_scores[ideology_key]
				var requirement = ideology_requirements[ideology_key]

				if requirement.size() >= 2:  # [min, max] range
					var min_val = requirement[0]
					var max_val = requirement[1]
					if party_score >= min_val and party_score <= max_val:
						score += 1.0

	# Bonus for question quality (number of answer choices)
	if question.answers.size() >= 3:
		score += 0.5

	return score

# Load question pools from data files and create defaults
func _load_question_pools():
	all_questions.clear()
	questions_by_category.clear()
	questions_by_difficulty.clear()

	# Create default questions using static methods from MediaQuestion
	var economic_questions = MediaQuestion.create_economic_questions()
	var social_questions = MediaQuestion.create_social_questions()
	var environmental_questions = MediaQuestion.create_environmental_questions()

	all_questions.append_array(economic_questions)
	all_questions.append_array(social_questions)
	all_questions.append_array(environmental_questions)

	# Add additional hardcoded questions for variety
	_add_additional_questions()

	# Index questions by category and difficulty
	_index_questions()

	print("QuestionSelector: Loaded %d questions across %d categories" %
		  [all_questions.size(), questions_by_category.size()])

# Add additional hardcoded questions for more variety
func _add_additional_questions():
	# EU Policy Question
	var eu_question = MediaQuestion.new()
	eu_question.id = "eu_future_relationship"
	eu_question.category = "EU & International"
	eu_question.question_text = "What role should the Netherlands play in the future of European integration?"
	eu_question.context_requirements = {
		"party_ideology": {"eu_skeptic_federal": [-1.0, 1.0]},
		"difficulty_level": 3
	}

	var eu_answers: Array[MediaAnswer] = []

	var federalist_answer = MediaAnswer.new()
	federalist_answer.text = "We should lead efforts toward a federal European state"
	federalist_answer.attribute_impacts = {"intelligence": 5, "integrity": 3}
	federalist_answer.popularity_impact = -5.0
	federalist_answer.treasury_impact = 20000
	eu_answers.append(federalist_answer)

	var cooperation_answer = MediaAnswer.new()
	cooperation_answer.text = "Strengthen cooperation while maintaining national sovereignty"
	cooperation_answer.attribute_impacts = {"experience": 4, "networking": 3}
	cooperation_answer.popularity_impact = 3.0
	cooperation_answer.treasury_impact = 10000
	eu_answers.append(cooperation_answer)

	var skeptic_answer = MediaAnswer.new()
	skeptic_answer.text = "Reduce EU power and restore more national control"
	skeptic_answer.attribute_impacts = {"charisma": 8, "energy": 5}
	skeptic_answer.popularity_impact = 5.0
	skeptic_answer.treasury_impact = -15000
	eu_answers.append(skeptic_answer)

	eu_question.answers = eu_answers
	all_questions.append(eu_question)

	# Housing Crisis Question
	var housing_question = MediaQuestion.new()
	housing_question.id = "housing_crisis_solution"
	housing_question.category = "Social Policy"
	housing_question.question_text = "How should the Netherlands address the current housing crisis?"
	housing_question.context_requirements = {
		"difficulty_level": 2
	}

	var housing_answers: Array[MediaAnswer] = []

	var public_answer = MediaAnswer.new()
	public_answer.text = "Massive public housing construction program funded by government"
	public_answer.attribute_impacts = {"integrity": 6, "energy": 4}
	public_answer.popularity_impact = 12.0
	public_answer.treasury_impact = -120000
	housing_answers.append(public_answer)

	var market_answer = MediaAnswer.new()
	market_answer.text = "Remove regulations and let the market solve the shortage"
	market_answer.attribute_impacts = {"networking": 5, "intelligence": 3}
	market_answer.popularity_impact = -3.0
	market_answer.treasury_impact = 40000
	housing_answers.append(market_answer)

	var mixed_answer = MediaAnswer.new()
	mixed_answer.text = "Public-private partnership with targeted government intervention"
	mixed_answer.attribute_impacts = {"experience": 6, "intelligence": 4}
	mixed_answer.popularity_impact = 2.0
	mixed_answer.treasury_impact = -50000
	housing_answers.append(mixed_answer)

	housing_question.answers = housing_answers
	all_questions.append(housing_question)

	# Digital Privacy Question
	var privacy_question = MediaQuestion.new()
	privacy_question.id = "digital_privacy_security"
	privacy_question.category = "Technology & Privacy"
	privacy_question.question_text = "How should we balance digital privacy with national security needs?"
	privacy_question.context_requirements = {
		"leader_background": ["academic", "media_personality", "activist"],
		"difficulty_level": 4
	}

	var privacy_answers: Array[MediaAnswer] = []

	var privacy_first_answer = MediaAnswer.new()
	privacy_first_answer.text = "Privacy is fundamental - minimal surveillance with strong oversight"
	privacy_first_answer.attribute_impacts = {"integrity": 10, "intelligence": 3}
	privacy_first_answer.popularity_impact = 8.0
	privacy_first_answer.treasury_impact = -30000
	privacy_answers.append(privacy_first_answer)

	var balanced_answer = MediaAnswer.new()
	balanced_answer.text = "Targeted surveillance with judicial oversight and transparency"
	balanced_answer.attribute_impacts = {"experience": 5, "intelligence": 6}
	balanced_answer.popularity_impact = 1.0
	balanced_answer.treasury_impact = 10000
	privacy_answers.append(balanced_answer)

	var security_first_answer = MediaAnswer.new()
	security_first_answer.text = "Security takes priority - comprehensive monitoring with safeguards"
	security_first_answer.attribute_impacts = {"networking": -3, "energy": 4}
	security_first_answer.popularity_impact = -8.0
	security_first_answer.treasury_impact = 50000
	privacy_answers.append(security_first_answer)

	privacy_question.answers = privacy_answers
	all_questions.append(privacy_question)

# Index questions for faster retrieval
func _index_questions():
	questions_by_category.clear()
	questions_by_difficulty.clear()

	for question in all_questions:
		# Index by category
		var category = question.category
		if category not in questions_by_category:
			questions_by_category[category] = []
		questions_by_category[category].append(question)

		# Index by difficulty
		var difficulty = question.context_requirements.get("difficulty_level", 2)
		if difficulty not in questions_by_difficulty:
			questions_by_difficulty[difficulty] = []
		questions_by_difficulty[difficulty].append(question)

# Get all available categories
func get_available_categories() -> Array[String]:
	return questions_by_category.keys()

# Get questions by specific category
func get_questions_by_category(category: String) -> Array[MediaQuestion]:
	return questions_by_category.get(category, [])

# Get questions by difficulty level
func get_questions_by_difficulty(difficulty: int) -> Array[MediaQuestion]:
	return questions_by_difficulty.get(difficulty, [])

# Preview questions for a specific party/leader combination
func preview_questions(party: Party, leader: Leader, count: int = 10) -> Array[MediaQuestion]:
	var appropriate = _filter_appropriate_questions(party, leader)
	var preview_count = min(count, appropriate.size())

	# Return top questions by relevance score
	var scored_questions: Array[Dictionary] = []
	for question in appropriate:
		var score = _calculate_question_relevance_score(question, party, leader)
		scored_questions.append({"question": question, "score": score})

	scored_questions.sort_custom(func(a, b): return a["score"] > b["score"])

	var preview: Array[MediaQuestion] = []
	for i in range(preview_count):
		preview.append(scored_questions[i]["question"])

	return preview

# Get statistics about question pool
func get_question_pool_stats() -> Dictionary:
	return {
		"total_questions": all_questions.size(),
		"categories": questions_by_category.keys(),
		"difficulties": questions_by_difficulty.keys(),
		"category_counts": _get_category_counts(),
		"difficulty_counts": _get_difficulty_counts()
	}

# Helper function to get question counts by category
func _get_category_counts() -> Dictionary:
	var counts = {}
	for category in questions_by_category.keys():
		counts[category] = questions_by_category[category].size()
	return counts

# Helper function to get question counts by difficulty
func _get_difficulty_counts() -> Dictionary:
	var counts = {}
	for difficulty in questions_by_difficulty.keys():
		counts[difficulty] = questions_by_difficulty[difficulty].size()
	return counts