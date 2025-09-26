extends Resource
class_name MediaQuestion

# Unique identifier
@export var id: String = ""

# Question categorization
@export var category: String = ""

# The actual question text
@export var question_text: String = ""

# Context requirements for when to ask this question
@export var context_requirements: Dictionary = {}

# Possible answers to this question
@export var answers: Array[MediaAnswer] = []

func _init():
	# Initialize context requirements with default structure
	context_requirements = {
		"party_ideology": {},
		"leader_background": [],
		"policy_keywords": [],
		"difficulty_level": 1  # 1-5 scale, 1 = easy, 5 = hard
	}

# Validation function for media question data
func validate() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []

	# Basic information validation
	if question_text.length() < 10:
		errors.append("Question text must be at least 10 characters")
	elif question_text.length() > 500:
		errors.append("Question text must be 500 characters or less")

	if category.length() == 0:
		errors.append("Question must have a category")

	# Answers validation
	if answers.size() < 2:
		errors.append("Question must have at least 2 possible answers")
	elif answers.size() > 6:
		warnings.append("Questions with more than 6 answers may be confusing")

	# Context requirements validation
	if "difficulty_level" in context_requirements:
		var difficulty = context_requirements["difficulty_level"]
		if difficulty < 1 or difficulty > 5:
			errors.append("Difficulty level must be between 1 and 5")

	return {
		"valid": errors.size() == 0,
		"errors": errors,
		"warnings": warnings
	}

# Check if this question is appropriate for the given party and leader
func is_appropriate_for_context(party: Party, leader: Leader) -> bool:
	# Check party ideology requirements
	if "party_ideology" in context_requirements and context_requirements["party_ideology"].size() > 0:
		for ideology_key in context_requirements["party_ideology"].keys():
			var requirement = context_requirements["party_ideology"][ideology_key]
			if ideology_key in party.ideology_scores:
				var party_score = party.ideology_scores[ideology_key]
				if requirement.size() >= 2:  # [min, max] range
					if party_score < requirement[0] or party_score > requirement[1]:
						return false

	# Check leader background requirements
	if "leader_background" in context_requirements and context_requirements["leader_background"].size() > 0:
		if leader.background_id not in context_requirements["leader_background"]:
			return false

	# Check policy keyword requirements
	if "policy_keywords" in context_requirements and context_requirements["policy_keywords"].size() > 0:
		var has_required_keyword = false
		for required_keyword in context_requirements["policy_keywords"]:
			if required_keyword in party.policy_keywords:
				has_required_keyword = true
				break
		if not has_required_keyword:
			return false

	return true

# Get a formatted version of the question for display
func get_formatted_question() -> String:
	var formatted = question_text

	# Add question mark if not present
	if not formatted.ends_with("?"):
		formatted += "?"

	return formatted

# Get the difficulty description
func get_difficulty_description() -> String:
	if "difficulty_level" not in context_requirements:
		return "Standard"

	var difficulty = context_requirements["difficulty_level"]
	match difficulty:
		1:
			return "Easy"
		2:
			return "Standard"
		3:
			return "Challenging"
		4:
			return "Hard"
		5:
			return "Expert"
		_:
			return "Unknown"

# Static method to create common interview questions
static func create_economic_questions() -> Array[MediaQuestion]:
	var questions: Array[MediaQuestion] = []

	# Taxation question
	var tax_question = MediaQuestion.new()
	tax_question.id = "tax_policy_stance"
	tax_question.category = "Economic Policy"
	tax_question.question_text = "What is your party's position on taxation for the wealthy?"
	tax_question.context_requirements = {
		"party_ideology": {"economic_left_right": [-1.0, 1.0]},
		"difficulty_level": 2
	}

	var tax_answers: Array[MediaAnswer] = []

	var progressive_answer = MediaAnswer.new()
	progressive_answer.text = "The wealthy should pay their fair share through progressive taxation"
	progressive_answer.attribute_impacts = {"charisma": 5, "integrity": 5}
	progressive_answer.popularity_impact = 8.0
	progressive_answer.treasury_impact = 50000
	tax_answers.append(progressive_answer)

	var moderate_answer = MediaAnswer.new()
	moderate_answer.text = "We need balanced taxation that supports both growth and fairness"
	moderate_answer.attribute_impacts = {"intelligence": 3, "experience": 2}
	moderate_answer.popularity_impact = 2.0
	moderate_answer.treasury_impact = 20000
	tax_answers.append(moderate_answer)

	var conservative_answer = MediaAnswer.new()
	conservative_answer.text = "Lower taxes stimulate economic growth and benefit everyone"
	conservative_answer.attribute_impacts = {"networking": 8, "energy": 3}
	conservative_answer.popularity_impact = -3.0
	conservative_answer.treasury_impact = -30000
	tax_answers.append(conservative_answer)

	tax_question.answers = tax_answers
	questions.append(tax_question)

	# Healthcare question
	var health_question = MediaQuestion.new()
	health_question.id = "healthcare_funding"
	health_question.category = "Social Policy"
	health_question.question_text = "How should the Netherlands fund its healthcare system?"
	health_question.context_requirements = {
		"policy_keywords": ["universal_healthcare", "healthcare_reform"],
		"difficulty_level": 3
	}

	var health_answers: Array[MediaAnswer] = []

	var public_answer = MediaAnswer.new()
	public_answer.text = "Fully public funding ensures healthcare is a right, not a privilege"
	public_answer.attribute_impacts = {"integrity": 8, "charisma": 3}
	public_answer.popularity_impact = 12.0
	public_answer.treasury_impact = -80000
	health_answers.append(public_answer)

	var mixed_answer = MediaAnswer.new()
	mixed_answer.text = "A public-private mix provides both access and efficiency"
	mixed_answer.attribute_impacts = {"intelligence": 5, "experience": 5}
	mixed_answer.popularity_impact = 1.0
	mixed_answer.treasury_impact = -20000
	health_answers.append(mixed_answer)

	var market_answer = MediaAnswer.new()
	market_answer.text = "Market-based solutions drive innovation and cost control"
	market_answer.attribute_impacts = {"networking": 6, "intelligence": 2}
	market_answer.popularity_impact = -8.0
	market_answer.treasury_impact = 40000
	health_answers.append(market_answer)

	health_question.answers = health_answers
	questions.append(health_question)

	return questions

static func create_social_questions() -> Array[MediaQuestion]:
	var questions: Array[MediaQuestion] = []

	# Immigration question
	var immigration_question = MediaQuestion.new()
	immigration_question.id = "immigration_policy"
	immigration_question.category = "Social Policy"
	immigration_question.question_text = "What is your stance on immigration to the Netherlands?"
	immigration_question.context_requirements = {
		"party_ideology": {"social_liberal_conservative": [-1.0, 1.0]},
		"difficulty_level": 4
	}

	var immigration_answers: Array[MediaAnswer] = []

	var welcoming_answer = MediaAnswer.new()
	welcoming_answer.text = "Immigration enriches our society and we should welcome those in need"
	welcoming_answer.attribute_impacts = {"integrity": 10, "charisma": 5}
	welcoming_answer.popularity_impact = 15.0
	welcoming_answer.treasury_impact = -60000
	immigration_answers.append(welcoming_answer)

	var controlled_answer = MediaAnswer.new()
	controlled_answer.text = "We need controlled immigration with proper integration support"
	controlled_answer.attribute_impacts = {"intelligence": 6, "experience": 4}
	controlled_answer.popularity_impact = 3.0
	controlled_answer.treasury_impact = -10000
	immigration_answers.append(controlled_answer)

	var restrictive_answer = MediaAnswer.new()
	restrictive_answer.text = "Immigration should be limited to protect our national identity"
	restrictive_answer.attribute_impacts = {"networking": -3, "energy": 5}
	restrictive_answer.popularity_impact = -12.0
	restrictive_answer.treasury_impact = 30000
	immigration_answers.append(restrictive_answer)

	immigration_question.answers = immigration_answers
	questions.append(immigration_question)

	return questions

static func create_environmental_questions() -> Array[MediaQuestion]:
	var questions: Array[MediaQuestion] = []

	# Climate action question
	var climate_question = MediaQuestion.new()
	climate_question.id = "climate_action_priority"
	climate_question.category = "Environmental Policy"
	climate_question.question_text = "How urgent is climate action compared to economic concerns?"
	climate_question.context_requirements = {
		"policy_keywords": ["green_transition", "climate_action"],
		"difficulty_level": 3
	}

	var climate_answers: Array[MediaAnswer] = []

	var urgent_answer = MediaAnswer.new()
	urgent_answer.text = "Climate action is the top priority - we must act now regardless of cost"
	urgent_answer.attribute_impacts = {"integrity": 12, "energy": 8}
	urgent_answer.popularity_impact = 10.0
	urgent_answer.treasury_impact = -100000
	climate_answers.append(urgent_answer)

	var balanced_answer = MediaAnswer.new()
	balanced_answer.text = "We need green policies that also protect jobs and economic growth"
	balanced_answer.attribute_impacts = {"intelligence": 8, "experience": 6}
	balanced_answer.popularity_impact = 5.0
	balanced_answer.treasury_impact = -30000
	climate_answers.append(balanced_answer)

	var economic_answer = MediaAnswer.new()
	economic_answer.text = "Economic stability must come first - green policies should be gradual"
	economic_answer.attribute_impacts = {"networking": 8, "intelligence": 3}
	economic_answer.popularity_impact = -7.0
	economic_answer.treasury_impact = 50000
	climate_answers.append(economic_answer)

	climate_question.answers = climate_answers
	questions.append(climate_question)

	return questions