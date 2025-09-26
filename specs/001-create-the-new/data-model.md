# Data Model: New Game Setup

## Core Entities

### Party
Represents a political party (generated or custom).

```gdscript
extends Resource
class_name Party

@export var id: String = ""  # Unique identifier
@export var name: String = ""  # Party name (e.g., "Volkspartij voor Vooruitgang")
@export var abbreviation: String = ""  # Short form (e.g., "VVV")
@export var description: String = ""  # 2-3 sentence description
@export var color_primary: Color = Color.WHITE  # Party primary color
@export var color_secondary: Color = Color.GRAY  # Party secondary color
@export var policy_keywords: Array[String] = []  # 5-10 policy positions
@export var ideology_scores: Dictionary = {}  # Numerical ideology positions
@export var is_custom: bool = false  # Whether player-created
@export var generation_seed: int = 0  # For procedural variation tracking

# Ideology scores structure:
# {
#   "economic_left_right": float (-1.0 to 1.0),
#   "social_liberal_conservative": float (-1.0 to 1.0),
#   "eu_skeptic_federal": float (-1.0 to 1.0),
#   "environment_economy": float (-1.0 to 1.0),
#   "centralization": float (-1.0 to 1.0)
# }
```

### Leader
Represents the party leader (player character).

```gdscript
extends Resource
class_name Leader

@export var id: String = ""
@export var first_name: String = ""
@export var last_name: String = ""
@export var background_id: String = ""  # References LeaderBackground
@export var party_id: String = ""  # References Party
@export var portrait_index: int = 0  # Visual representation index

# Attributes affected by background + interview
@export var attributes: Dictionary = {
    "charisma": 0,        # Media appeal, rally effectiveness
    "intelligence": 0,    # Policy development, debate performance
    "integrity": 0,       # Scandal resistance, coalition trust
    "experience": 0,      # Crisis management, negotiation skill
    "energy": 0,          # Campaign stamina, action points
    "networking": 0       # Coalition building, fundraising
}

# Starting conditions (set after interview)
@export var starting_treasury: int = 0  # In thousands of euros
@export var starting_popularity: float = 0.0  # Percentage (0-100)
@export var media_interview_responses: Array[String] = []  # For replay/reference
```

### LeaderBackground
Defines the 8 possible leader backgrounds.

```gdscript
extends Resource
class_name LeaderBackground

@export var id: String = ""
@export var name: String = ""  # e.g., "Career Politician"
@export var description: String = ""  # Background story
@export var attribute_modifiers: Dictionary = {}  # Initial attribute bonuses
@export var treasury_modifier: float = 1.0  # Multiplier for starting funds
@export var popularity_modifier: float = 0.0  # Base popularity adjustment
@export var special_traits: Array[String] = []  # Unique starting advantages

# Attribute modifiers structure matches Leader.attributes keys
```

### PolicyKeyword
Represents policy positions/categories.

```gdscript
extends Resource
class_name PolicyKeyword

@export var id: String = ""
@export var category: String = ""  # Economic, Social, Environmental, etc.
@export var name: String = ""  # e.g., "Progressive Taxation"
@export var description: String = ""  # Brief explanation
@export var icon: Texture2D  # Visual representation
@export var conflicting_keywords: Array[String] = []  # Cannot be selected together
@export var ideology_impact: Dictionary = {}  # How it affects ideology scores
```

### MediaQuestion
Interview questions for the media phase.

```gdscript
extends Resource
class_name MediaQuestion

@export var id: String = ""
@export var category: String = ""  # Question theme
@export var question_text: String = ""
@export var context_requirements: Dictionary = {}  # When to ask this question
@export var answers: Array[MediaAnswer] = []  # Possible responses

# Context requirements:
# {
#   "party_ideology": {"economic_left_right": [min, max]},
#   "leader_background": ["allowed_background_ids"],
#   "policy_keywords": ["required_keyword_ids"]
# }
```

### MediaAnswer
Possible responses to interview questions.

```gdscript
extends Resource
class_name MediaAnswer

@export var text: String = ""  # Answer text
@export var attribute_impacts: Dictionary = {}  # Changes to leader attributes
@export var treasury_impact: int = 0  # Change to starting treasury
@export var popularity_impact: float = 0.0  # Change to starting popularity
@export var reputation_tags: Array[String] = []  # Tags for future reference
```

### GameSetupState
Singleton for managing setup flow state.

```gdscript
extends Node
# Autoloaded as GameSetupState

var selected_party: Party
var custom_party_data: Dictionary = {}
var selected_background: LeaderBackground
var leader: Leader
var interview_responses: Array[MediaAnswer] = []
var setup_complete: bool = false

signal party_selected(party: Party)
signal leader_created(leader: Leader)
signal setup_completed(game_data: Dictionary)

func reset():
    selected_party = null
    custom_party_data.clear()
    selected_background = null
    leader = null
    interview_responses.clear()
    setup_complete = false

func compile_game_start_data() -> Dictionary:
    return {
        "party": selected_party,
        "leader": leader,
        "starting_date": Time.get_datetime_dict_from_system(),
        "difficulty_modifiers": {}  # Placeholder for difficulty settings
    }
```

## Data Validation Rules

### Party Validation
- Name: 3-50 characters, no profanity filter
- Abbreviation: 2-6 uppercase letters
- Policy keywords: Minimum 5, maximum 10, at least 2 different categories
- Ideology scores: All values between -1.0 and 1.0
- Colors: Primary and secondary must have sufficient contrast

### Leader Validation
- Names: 2-30 characters each, alphabetic + spaces/hyphens
- Attributes: All values between 0-100
- Treasury: 10,000 - 1,000,000 (in euros)
- Popularity: 0.0 - 100.0 (percentage)

### Custom Party Validation
- No duplicate names with existing parties
- Must pass profanity filter
- Must select required keyword mix (economic + social minimum)

## State Transitions

### Setup Flow States
```
START → PARTY_SELECTION → LEADER_CREATION → MEDIA_INTERVIEW → REVIEW → COMPLETE
          ↑                    ↑                  ↑
          └────────────────────┴──────────────────┘
                    (Back navigation allowed)
```

### Party Generation States
```
IDLE → GENERATING → GENERATED → DISPLAYED
         ↓
      ERROR → RETRY
```

## Relationships
- Leader **belongs_to** Party (1:1)
- Leader **has_one** LeaderBackground (1:1)
- Party **has_many** PolicyKeywords (5-10)
- MediaQuestion **has_many** MediaAnswers (3-5)
- GameSetupState **orchestrates** all entities during setup

## Persistence
- Parties: Loaded from `data/parties/*.tres` (Godot resource files)
- Backgrounds: Loaded from `data/backgrounds/*.tres`
- Questions: Loaded from `data/questions/*.json` (for easy editing)
- Save Data: Stored in `user://save_games/` using ConfigFile format