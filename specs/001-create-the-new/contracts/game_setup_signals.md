# Game Setup Signal Contracts

Since Godot uses signals instead of traditional APIs, this document defines the signal contracts for the new game setup flow.

## Signal Definitions

### PartySelection Scene

```gdscript
# Emitted when player selects an existing party
signal party_selected(party: Party)

# Emitted when player wants to create custom party
signal create_custom_party_requested()

# Emitted when custom party creation is complete
signal custom_party_created(party: Party)

# Emitted when player navigates back
signal back_requested()

# Emitted to proceed to next phase
signal phase_complete(data: Dictionary)
```

### LeaderCreation Scene

```gdscript
# Emitted when background is selected
signal background_selected(background: LeaderBackground)

# Emitted when leader details are confirmed
signal leader_created(leader: Leader)

# Navigation signals
signal back_requested()
signal phase_complete(data: Dictionary)
```

### MediaInterview Scene

```gdscript
# Emitted when question is answered
signal question_answered(question_id: String, answer: MediaAnswer)

# Emitted when interview is complete
signal interview_complete(responses: Array[MediaAnswer])

# Navigation signals
signal back_requested()
signal phase_complete(data: Dictionary)
```

### GameSetupState (Global Autoload)

```gdscript
# Flow control signals
signal setup_phase_changed(phase: String)
signal setup_completed(game_data: Dictionary)
signal setup_cancelled()

# Data update signals
signal party_data_updated(party: Party)
signal leader_data_updated(leader: Leader)
signal treasury_calculated(amount: int)
signal popularity_calculated(percentage: float)
```

## Method Contracts

### PartyGenerator System

```gdscript
class_name PartyGenerator
extends Node

# Generate parties based on templates and variations
func generate_parties(count: int = 20) -> Array[Party]:
    # Returns: Array of generated Party resources
    # Ensures: No duplicate names or abbreviations
    # Ensures: Balanced ideology distribution
    pass

# Validate custom party data
func validate_custom_party(data: Dictionary) -> Dictionary:
    # Returns: {"valid": bool, "errors": Array[String]}
    # Validates: Name, abbreviation, keyword selection
    pass

# Create party from custom data
func create_custom_party(data: Dictionary) -> Party:
    # Returns: Validated Party resource
    # Throws: Exception if validation fails
    pass
```

### SetupDataManager

```gdscript
class_name SetupDataManager
extends Node

# Calculate starting treasury
func calculate_treasury(leader: Leader, party: Party, responses: Array) -> int:
    # Returns: Starting treasury in euros
    # Factors: Background, party type, interview responses
    pass

# Calculate starting popularity
func calculate_popularity(leader: Leader, party: Party, responses: Array) -> float:
    # Returns: Popularity percentage (0-100)
    # Factors: Background, party ideology, interview responses
    pass

# Calculate final leader attributes
func calculate_final_attributes(
    background: LeaderBackground,
    responses: Array[MediaAnswer]
) -> Dictionary:
    # Returns: Final attribute values dictionary
    # Ensures: All values within 0-100 range
    pass
```

### QuestionSelector

```gdscript
class_name QuestionSelector
extends Node

# Select contextual questions for interview
func select_questions(
    party: Party,
    leader: Leader,
    count: int = 5
) -> Array[MediaQuestion]:
    # Returns: Array of contextual questions
    # Ensures: Questions match party ideology and leader background
    # Ensures: No duplicate questions
    pass
```

## Data Transfer Objects

### SetupPhaseData
Data passed between setup phases:

```gdscript
{
    "phase": String,  # Current phase identifier
    "party": Party,  # Selected/created party
    "leader": Leader,  # Created leader (null initially)
    "background": LeaderBackground,  # Selected background
    "interview_responses": Array[MediaAnswer],  # Interview answers
    "calculated_treasury": int,  # Final treasury
    "calculated_popularity": float,  # Final popularity
    "timestamp": String  # ISO timestamp
}
```

### ValidationResult
Standard validation response:

```gdscript
{
    "valid": bool,
    "errors": Array[String],  # Empty if valid
    "warnings": Array[String],  # Non-blocking issues
    "data": Dictionary  # Sanitized/processed data
}
```

## Error Handling

### Error Signals
```gdscript
# Emitted on validation failures
signal validation_error(field: String, message: String)

# Emitted on system errors
signal system_error(error_code: String, message: String)

# Emitted on data loading failures
signal data_load_error(resource_path: String, error: String)
```

### Error Codes
- `ERR_INVALID_PARTY_NAME`: Party name validation failed
- `ERR_DUPLICATE_PARTY`: Party name already exists
- `ERR_INSUFFICIENT_KEYWORDS`: Less than 5 keywords selected
- `ERR_CONFLICTING_KEYWORDS`: Selected keywords conflict
- `ERR_INVALID_BACKGROUND`: Background ID not found
- `ERR_SAVE_FAILED`: Could not save game setup data
- `ERR_LOAD_FAILED`: Could not load required resources

## Testing Contracts

### Test Scenarios
Each signal and method must be tested with:
1. Valid input cases
2. Boundary conditions
3. Invalid input handling
4. Error propagation
5. State consistency after operations

### Mock Data Requirements
- Minimum 3 test parties with full data
- All 8 backgrounds with unique modifiers
- Pool of 20+ test questions
- Edge case leader names (unicode, long, short)
- Extreme ideology combinations