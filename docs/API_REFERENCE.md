# NederTiek - API Reference

## Core Data Models

### Party (extends Resource)
**File**: `scripts/models/Party.gd`

Political party representation with comprehensive data model.

#### Properties
```gdscript
@export var id: String                    # Unique identifier
@export var name: String                  # Full party name (3-50 chars)
@export var abbreviation: String          # Short acronym (2-6 chars)
@export var description: String           # Party description (10-500 chars)
@export var policy_keywords: Array        # Political positions (5-10 keywords)
@export var ideology_scores: Dictionary   # Multi-dimensional positioning (-1.0 to 1.0)
@export var color_primary: Color          # Primary brand color
@export var color_secondary: Color        # Secondary brand color
@export var is_custom: bool              # Player-created party
@export var is_official: bool            # Real Dutch party
@export var generation_seed: int          # Random generation seed
```

#### Methods
```gdscript
func validate() -> Dictionary
# Returns: {"valid": bool, "errors": Array[String], "warnings": Array[String]}
# Validates party data including profanity filtering for custom parties

func get_display_name() -> String
# Returns: Formatted display name "ABBREV (Full Name)"

func has_policy_conflicts(other_party: Party) -> bool
# Returns: True if parties share policy keywords
```

#### Ideology Dimensions
- `economic_left_right`: Economic policy spectrum (-1.0 = left, 1.0 = right)
- `social_liberal_conservative`: Social policy spectrum (-1.0 = liberal, 1.0 = conservative)
- `eu_skeptic_federal`: EU integration stance (-1.0 = skeptic, 1.0 = federalist)
- `environment_economy`: Environmental vs Economic priorities
- `centralization`: Government centralization preference

---

### Leader (extends Resource)
**File**: `scripts/models/Leader.gd`

Party leader representation with attributes and background.

#### Properties
```gdscript
@export var id: String                    # Unique identifier
@export var first_name: String            # Leader's first name (2-30 chars)
@export var last_name: String             # Leader's last name (2-30 chars)
@export var background_id: String         # Associated background type
@export var party_id: String              # Associated party ID
@export var portrait_index: int           # Visual representation index
@export var attributes: Dictionary        # Leadership attributes (0-100 scale)
@export var starting_treasury: int        # Initial campaign funds (euros)
@export var starting_popularity: float    # Initial public support (0-100%)
@export var media_interview_responses: Array # Reference to interview answers
```

#### Methods
```gdscript
func validate() -> Dictionary
# Returns: {"valid": bool, "errors": Array[String], "warnings": Array[String]}
# Validates leader data and attribute ranges

func get_full_name() -> String
# Returns: "FirstName LastName"

func get_formatted_treasury() -> String
# Returns: Formatted currency display (€1.2M, €150K, €1500)

func apply_attribute_modifier(modifiers: Dictionary)
# Applies attribute bonuses/penalties, keeps values in 0-100 range

func get_attribute_description(attribute_name: String) -> String
# Returns: Human-readable description of attribute purpose
```

#### Leadership Attributes
- **Charisma** (0-100): Media appeal and rally effectiveness
- **Intelligence** (0-100): Policy development and debate performance
- **Integrity** (0-100): Scandal resistance and coalition trust
- **Experience** (0-100): Crisis management and negotiation skill
- **Energy** (0-100): Campaign stamina and action points
- **Networking** (0-100): Coalition building and fundraising ability

---

### LeaderBackground (extends Resource)
**File**: `scripts/models/LeaderBackground.gd`

Professional background that modifies leader attributes and starting conditions.

#### Properties
```gdscript
@export var id: String                    # Unique identifier
@export var name: String                  # Display name (3-50 chars)
@export var description: String           # Background description (10+ chars)
@export var attribute_modifiers: Dictionary # Attribute bonuses/penalties
@export var treasury_modifier: float      # Treasury multiplier (0.1-10.0)
@export var popularity_modifier: float    # Base popularity adjustment (-50 to +50)
@export var special_traits: Array         # Unique background advantages
```

#### Methods
```gdscript
func validate() -> Dictionary
# Returns: {"valid": bool, "errors": Array[String], "warnings": Array[String]}
# Validates background data and modifier ranges

func get_impact_summary() -> String
# Returns: Summary of background's mechanical effects for UI display
```

#### Static Background Creators
```gdscript
static func create_career_politician() -> LeaderBackground
static func create_business_executive() -> LeaderBackground
static func create_academic() -> LeaderBackground
static func create_activist() -> LeaderBackground
static func create_media_personality() -> LeaderBackground
static func create_local_administrator() -> LeaderBackground
static func create_union_leader() -> LeaderBackground
static func create_military_security() -> LeaderBackground
```

---

### MediaQuestion (extends Resource)
**File**: `scripts/models/MediaQuestion.gd`

Interview question with contextual requirements and answer choices.

#### Properties
```gdscript
@export var id: String                    # Unique identifier
@export var category: String              # Question category
@export var question_text: String         # Question text (10-500 chars)
@export var context_requirements: Dictionary # When to ask this question
@export var answers: Array                # Array of MediaAnswer objects
```

#### Methods
```gdscript
func validate() -> Dictionary
# Returns: {"valid": bool, "errors": Array[String], "warnings": Array[String]}
# Validates question data and answer count (2-6 answers)

func is_appropriate_for_context(party: Party, leader: Leader) -> bool
# Returns: True if question matches party ideology and leader background

func get_formatted_question() -> String
# Returns: Question text with proper punctuation

func get_difficulty_description() -> String
# Returns: "Easy", "Standard", "Challenging", "Hard", or "Expert"
```

#### Static Question Creators
```gdscript
static func create_economic_questions() -> Array[MediaQuestion]
static func create_social_questions() -> Array[MediaQuestion]
static func create_environmental_questions() -> Array[MediaQuestion]
```

#### Context Requirements Structure
```gdscript
context_requirements = {
    "party_ideology": {"economic_left_right": [-0.5, 0.5]},  # Ideology ranges
    "leader_background": ["business_executive", "academic"],  # Allowed backgrounds
    "policy_keywords": ["free_market", "deregulation"],      # Required keywords
    "difficulty_level": 3                                    # 1-5 scale
}
```

---

### MediaAnswer (extends Resource)
**File**: `scripts/models/MediaAnswer.gd`

Interview answer choice with mechanical impacts.

#### Properties
```gdscript
@export var text: String                  # Answer text (5-200 chars)
@export var attribute_impacts: Dictionary # Attribute changes (-50 to +50)
@export var treasury_impact: int          # Treasury change in euros
@export var popularity_impact: float      # Popularity change in percentage points
@export var reputation_tags: Array        # Tags for future reference
```

#### Methods
```gdscript
func validate() -> Dictionary
# Returns: {"valid": bool, "errors": Array[String], "warnings": Array[String]}
# Validates answer data and impact ranges

func get_impact_summary() -> String
# Returns: Brief summary of mechanical effects for UI display

func get_detailed_impact_description() -> String
# Returns: Detailed description of all impacts for tooltips

func apply_to_leader(leader: Leader)
# Applies this answer's impacts to the leader's attributes and starting conditions

func has_significant_impact() -> bool
# Returns: True if answer has meaningful mechanical effects

func get_dominant_impact_type() -> String
# Returns: "positive", "negative", or "neutral" for UI theming
```

---

## Core Game Systems

### GameSetupState (Singleton)
**File**: `scripts/systems/GameSetupState.gd`
**Autoload**: Yes

Central coordinator for the new game creation process.

#### Properties
```gdscript
# Current setup data
var selected_party: Party
var custom_party_data: Dictionary
var selected_background: LeaderBackground
var leader: Leader
var interview_responses: Array
var setup_complete: bool

# Phase tracking
var current_phase: String              # "party_selection", "leader_creation", etc.
var previous_phase: String

# Generated data cache
var generated_parties: Array
var available_backgrounds: Array[LeaderBackground]
var question_pool: Array
```

#### Signals
```gdscript
# Flow control
signal setup_phase_changed(phase: String)
signal setup_completed(game_data: Dictionary)
signal setup_cancelled()

# Data updates
signal party_data_updated(party: Party)
signal leader_data_updated(leader: Leader)
signal treasury_calculated(amount: int)
signal popularity_calculated(percentage: float)

# Error handling
signal validation_error(field: String, message: String)
signal system_error(error_code: String, message: String)
signal data_load_error(resource_path: String, error: String)
```

#### Methods
```gdscript
func reset()
# Resets all setup data to initial state

func advance_phase()
# Progress to next setup phase with validation

func go_back()
# Return to previous phase

func set_party(party: Party)
# Set selected party with validation

func create_custom_party(party_data: Dictionary)
# Create and validate custom party

func set_background(background: LeaderBackground)
# Set leader background and update leader

func create_leader(first_name: String, last_name: String)
# Create leader with validation

func add_interview_response(answer: MediaAnswer)
# Add interview answer and apply to leader

func compile_game_start_data() -> Dictionary
# Generate final game configuration

func can_advance() -> bool
# Check if can advance to next phase

func get_setup_progress() -> float
# Get completion percentage (0-100)

func save_setup_state() -> Dictionary
# Save current state for persistence

func load_setup_state(state_data: Dictionary)
# Load previously saved state
```

---

### PartyGenerator
**File**: `scripts/systems/PartyGenerator.gd`

Party creation and validation system.

#### Methods
```gdscript
func generate_parties(count: int = 20) -> Array
# Generate array of Dutch political parties

func validate_custom_party(data: Dictionary) -> Dictionary
# Validate custom party creation data

func create_custom_party(data: Dictionary) -> Party
# Create validated custom party

func _create_hardcoded_dutch_parties() -> Array
# Generate 20 real Dutch political parties with accurate data
```

#### Real Dutch Parties
The system includes 20 authentic Dutch political parties:
- VVD (People's Party for Freedom and Democracy)
- PVV (Party for Freedom)
- CDA (Christian Democratic Appeal)
- D66 (Democrats 66)
- GroenLinks (GreenLeft)
- SP (Socialist Party)
- PvdA (Labour Party)
- ChristenUnie (ChristianUnion)
- SGP (Reformed Political Party)
- DENK, FvD, JA21, Volt, BIJ1, 50PLUS, PvdD, BVNL, Piratenpartij, LP, BBB

---

### SetupDataManager
**File**: `scripts/systems/SetupDataManager.gd`

Calculation system for final leader attributes and starting conditions.

#### Constants
```gdscript
const BASE_TREASURY_MIN = 50000      # €50K minimum
const BASE_TREASURY_MAX = 200000     # €200K maximum
const BASE_POPULARITY_MIN = 8.0      # 8% minimum
const BASE_POPULARITY_MAX = 18.0     # 18% maximum
const BACKGROUND_WEIGHT = 0.4        # Background influence factor
const PARTY_WEIGHT = 0.3             # Party influence factor
const INTERVIEW_WEIGHT = 0.3         # Interview influence factor
```

#### Methods
```gdscript
func calculate_treasury(leader: Leader, party: Party, responses: Array) -> int
# Calculate final starting treasury (€10K - €1M range)

func calculate_popularity(leader: Leader, party: Party, responses: Array) -> float
# Calculate final starting popularity (5% - 25% range)

func calculate_final_attributes(background: LeaderBackground, responses: Array[MediaAnswer]) -> Dictionary
# Calculate final leader attributes after all modifiers

func calculate_difficulty_modifiers(difficulty: String) -> Dictionary
# Get difficulty-based adjustments for easy/normal/hard/expert modes

func validate_calculated_values(treasury: int, popularity: float, attributes: Dictionary) -> Dictionary
# Validate final calculated values are within expected ranges

func get_calculation_summary(leader: Leader, party: Party, responses: Array) -> String
# Get detailed breakdown of calculation factors for debugging
```

---

### QuestionSelector
**File**: `scripts/systems/QuestionSelector.gd`

Intelligent question selection system for media interviews.

#### Properties
```gdscript
var all_questions: Array[MediaQuestion]     # Complete question pool
var questions_by_category: Dictionary       # Indexed by category
var questions_by_difficulty: Dictionary     # Indexed by difficulty level
var random_generator: RandomNumberGenerator # For selection randomization
```

#### Methods
```gdscript
func select_questions(party: Party, leader: Leader, count: int = 5) -> Array[MediaQuestion]
# Select appropriate questions for interview with diversity constraints

func preview_questions(party: Party, leader: Leader, count: int = 10) -> Array[MediaQuestion]
# Preview top questions by relevance score

func get_available_categories() -> Array[String]
# Get all question categories

func get_questions_by_category(category: String) -> Array[MediaQuestion]
# Get questions from specific category

func get_questions_by_difficulty(difficulty: int) -> Array[MediaQuestion]
# Get questions by difficulty level (1-5)

func get_question_pool_stats() -> Dictionary
# Get statistics about loaded question pool
```

#### Selection Algorithm
1. **Contextual Filtering**: Remove inappropriate questions based on party/leader
2. **Diversity Selection**: Ensure variety across categories and difficulties
3. **Relevance Scoring**: Rank questions by contextual relevance
4. **Random Selection**: Add controlled randomness within top choices

---

## UI Controllers

### NewGameFlow (extends Control)
**File**: `scripts/new_game/NewGameFlow.gd`

Main orchestrator for the new game setup UI flow.

#### Properties
```gdscript
var current_scene: Node                 # Currently loaded phase scene
var phase_scenes: Dictionary            # Cached phase scenes
var current_phase_index: int           # Current phase index (0-3)
var phases: Array                      # Phase configuration array
```

#### Phase Configuration
```gdscript
phases = [
    {
        "id": "party_selection",
        "title": "Choose Your Party",
        "scene_path": "res://scenes/new_game/PartySelection.tscn",
        "status_text": "Select or create your political party"
    },
    # ... other phases
]
```

#### Methods
```gdscript
func jump_to_phase(phase_id: String) -> bool
# Navigate directly to specific phase

func get_current_phase_id() -> String
# Get current phase identifier

func can_go_back() -> bool
# Check if can navigate to previous phase

func can_go_forward() -> bool
# Check if can advance to next phase

func save_setup_state()
# Save current progress to ConfigFile

func load_setup_state() -> bool
# Load previously saved progress

func clear_saved_state()
# Delete saved setup state

func skip_to_review()
# Development helper to jump to review with dummy data
```

#### Signal Handlers
```gdscript
func _on_setup_phase_changed(phase: String)
func _on_setup_completed(game_data: Dictionary)
func _on_party_selected(party: Party)
func _on_leader_created(leader: Leader)
func _on_background_selected(background: LeaderBackground)
func _on_interview_complete(responses: Array)
```

---

### LeaderCreation (extends Control)
**File**: `scripts/new_game/LeaderCreation.gd`

UI controller for leader creation and background selection.

#### Signals
```gdscript
signal leader_created(leader: Leader)
signal background_selected(background: LeaderBackground)
signal validation_changed()
```

#### Properties
```gdscript
var available_backgrounds: Array[LeaderBackground]
var selected_background: LeaderBackground
var current_leader: Leader
var current_portrait_index: int
var portrait_colors: Array              # Available portrait colors
```

#### Methods
```gdscript
func get_current_leader() -> Leader
# Get the currently created leader

func can_create_leader() -> bool
# Check if leader creation is valid

func create_leader_if_valid() -> Leader
# Create leader only if validation passes

func get_selected_background() -> LeaderBackground
# Get currently selected background

func _validate_leader_data() -> Dictionary
# Internal validation of form data

func _create_leader() -> Leader
# Internal leader creation logic

func _update_attribute_display()
# Update attribute bars with background modifiers

func _update_validation()
# Update validation status and UI feedback
```

---

## Utility Systems

### AccessibilityHelper
**File**: `scripts/systems/AccessibilityHelper.gd`

Accessibility support system for inclusive design.

#### Features
- Screen reader compatibility
- Keyboard navigation support
- High contrast mode
- Text scaling options
- Audio cues for important events

---

### PerformanceMonitor (Singleton)
**File**: `scripts/systems/PerformanceMonitor.gd`
**Autoload**: Yes

Real-time performance tracking and optimization.

#### Monitoring Features
- Frame rate tracking
- Memory usage monitoring
- Scene loading performance
- User experience metrics

---

### ProfanityFilter
**File**: `scripts/systems/ProfanityFilter.gd`

Content validation system for user-generated content.

#### Methods
```gdscript
static func is_appropriate(text: String) -> Dictionary
# Returns: {"valid": bool, "reason": String}
# Validates text for appropriate content
```

#### Features
- Custom party name validation
- Inappropriate content detection
- Configurable filtering levels
- Dutch language support

---

## Error Handling

### Validation Patterns
All validation methods return consistent Dictionary format:
```gdscript
{
    "valid": bool,              # True if validation passed
    "errors": Array[String],    # Critical errors preventing operation
    "warnings": Array[String]   # Non-critical issues for user awareness
}
```

### Signal-Based Error Handling
- `validation_error(field: String, message: String)`: Form validation errors
- `system_error(error_code: String, message: String)`: System-level errors
- `data_load_error(resource_path: String, error: String)`: Resource loading errors

### Error Recovery
- **Graceful Degradation**: System continues with reduced functionality
- **User Feedback**: Clear error messages with recovery suggestions
- **State Preservation**: Errors don't corrupt saved progress
- **Debug Information**: Comprehensive logging for development

---

## Constants and Enums

### Attribute Ranges
- All leader attributes: 0-100 scale
- Treasury range: €10,000 - €1,000,000
- Popularity range: 5% - 25%
- Ideology scores: -1.0 to 1.0 scale

### Setup Phases
1. `"party_selection"`: Choose or create party
2. `"leader_creation"`: Create leader with background
3. `"media_interview"`: Answer interview questions
4. `"review"`: Final confirmation and game start

### Question Categories
- "Economic Policy"
- "Social Policy"
- "Environmental Policy"
- "EU & International"
- "Technology & Privacy"

### Background Types
- `"career_politician"`
- `"business_executive"`
- `"academic"`
- `"activist"`
- `"media_personality"`
- `"local_administrator"`
- `"union_leader"`
- `"military_security"`

This API reference provides comprehensive documentation for all major systems, enabling developers to understand and extend the NederTiek political simulation framework.