# GDScript Documentation Standards

This document defines the documentation standards for the NederTiek project.

## Function Documentation Template

All non-trivial functions (more than 3 lines or performing complex operations) must include documentation comments following this template:

```gdscript
## Brief description of what the function does
##
## Detailed description if necessary, explaining the purpose,
## algorithm, or important implementation details.
##
## @param parameter_name: Type - Description of the parameter
## @param another_param: Type - Description with constraints or special values
## @return Type - Description of what is returned, including possible values
## @throws ErrorType - When this error might occur (if applicable)
##
## @example
## var result = example_function("input", 42)
## print(result)  # Output: "processed: input with 42"
func example_function(input: String, count: int) -> String:
```

## Class Documentation Template

All custom classes should include a header comment:

```gdscript
## Class Name - Brief description
##
## Longer description explaining the purpose of the class,
## its role in the system, and any important usage notes.
##
## Key responsibilities:
## - Responsibility 1
## - Responsibility 2
## - Responsibility 3
##
## Usage patterns:
## - How to instantiate and configure
## - Common workflows
## - Important lifecycle considerations
##
## @author: Your Name
## @version: 1.0
## @since: Version when first introduced
extends BaseClass
class_name MyClass
```

## Signal Documentation Template

```gdscript
## Signal emitted when [event occurs]
##
## @param param_name: Type - Description of signal parameter
## @param another_param: Type - Additional parameter description
##
## Emitted in the following scenarios:
## - Scenario 1: When X happens
## - Scenario 2: When Y condition is met
##
## @example
## my_object.signal_name.connect(_on_signal_received)
signal signal_name(param_name: Type, another_param: Type)
```

## Variable Documentation Template

```gdscript
## Brief description of the variable's purpose
##
## Additional context about valid values, constraints,
## or important behavioral notes.
##
## Valid values: [description of valid range/values]
## Default: [default value and why]
## @invariant: [any invariants that must be maintained]
var documented_variable: Type = default_value
```

## Complex Algorithm Documentation

For functions implementing complex algorithms or business logic:

```gdscript
## Calculate election results using D'Hondt method
##
## Implements the D'Hondt proportional representation system
## used in Dutch elections to allocate parliamentary seats.
##
## Algorithm steps:
## 1. Calculate quotients for each party (votes / divisor)
## 2. Award seat to party with highest quotient
## 3. Increment that party's divisor
## 4. Repeat until all seats allocated
##
## @param vote_counts: Dictionary[String, int] - Party name -> vote count
## @param total_seats: int - Number of seats to allocate (must be > 0)
## @return Dictionary[String, int] - Party name -> seats won
## @throws ArgumentError - If total_seats <= 0 or vote_counts empty
##
## References:
## - https://en.wikipedia.org/wiki/D%27Hondt_method
## - Dutch Electoral Law, Article 12.3
##
## Time Complexity: O(n * s) where n = parties, s = seats
## Space Complexity: O(n)
func calculate_dhondt_allocation(vote_counts: Dictionary, total_seats: int) -> Dictionary:
```

## API Documentation Template

For public API functions that other systems use:

```gdscript
## [API] Create a new political party with validation
##
## Creates and validates a new Party instance according to
## Dutch political simulation rules and content policies.
##
## Validation includes:
## - Name length (3-50 characters)
## - Abbreviation format (2-6 characters)
## - Policy keyword requirements (5-10 keywords)
## - Content appropriateness (profanity filter)
## - Ideology score ranges (-1.0 to 1.0)
##
## @param name: String - Party name (required, 3-50 chars)
## @param abbreviation: String - Party abbreviation (required, 2-6 chars)
## @param description: String - Party description (required, 10-500 chars)
## @param keywords: Array[String] - Policy keywords (5-10 required)
## @param ideology: Dictionary - Ideology scores (-1.0 to 1.0 range)
## @return Result<Party, ValidationError> - Success with Party or validation errors
##
## @example
## var result = create_party(
##     "Progressive Alliance",
##     "PA",
##     "A forward-thinking progressive party",
##     ["universal_healthcare", "climate_action", "education_funding"],
##     {"economic_left_right": -0.3, "social_liberal_conservative": 0.2}
## )
## if result.is_success():
##     var party = result.get_value()
##     print("Created party: " + party.get_display_name())
## else:
##     print("Validation failed: " + str(result.get_errors()))
##
## @see Party.validate() for detailed validation rules
## @see ProfanityFilter for content filtering logic
## @since v0.1.0
func create_party(name: String, abbreviation: String, description: String,
				  keywords: Array[String], ideology: Dictionary) -> Result:
```

## Error Handling Documentation

```gdscript
## Handle setup state corruption with recovery
##
## Attempts to recover from corrupted game setup state by:
## 1. Validating current state integrity
## 2. Attempting repair of recoverable issues
## 3. Falling back to clean state if necessary
##
## Recovery strategies:
## - Missing party: Generate default party
## - Invalid leader: Reset to template leader
## - Corrupted saves: Clear and restart setup
##
## @param corruption_type: CorruptionType - Type of detected corruption
## @return RecoveryResult - Success/failure with recovery actions taken
## @throws CriticalStateError - If state is unrecoverable
##
## @warning This function modifies global game state
## @side_effects Clears GameSetupState if recovery fails
func handle_state_corruption(corruption_type: CorruptionType) -> RecoveryResult:
```

## Documentation Quality Requirements

### Required for All Functions

1. **Brief description** - One line explaining what the function does
2. **Parameter documentation** - Type and purpose of each parameter
3. **Return documentation** - What the function returns
4. **Error conditions** - When and why the function might fail

### Required for Complex Functions

1. **Algorithm explanation** - How the function works internally
2. **Performance characteristics** - Time/space complexity if relevant
3. **Usage examples** - Concrete examples showing how to use
4. **Side effects** - Any state changes or external effects
5. **References** - Links to specifications, algorithms, or domain knowledge

### Optional but Recommended

1. **Version information** - When introduced, last modified
2. **Author information** - Who wrote/maintains the code
3. **Related functions** - Cross-references to related functionality
4. **Invariants** - Conditions that must always be true
5. **Performance notes** - Optimization considerations

## Documentation Validation

Use these checks to ensure documentation quality:

### Completeness Checklist
- [ ] All public functions documented
- [ ] All parameters described with types
- [ ] Return values documented
- [ ] Error conditions explained
- [ ] Examples provided for complex functions

### Quality Checklist
- [ ] Clear and concise language
- [ ] Accurate technical details
- [ ] Examples actually work as shown
- [ ] Cross-references are correct
- [ ] No obvious typos or grammar errors

### Consistency Checklist
- [ ] Consistent terminology throughout
- [ ] Standard comment format used
- [ ] Parameter naming follows conventions
- [ ] Documentation style matches project standards

## Tools and Automation

### Godot Documentation Integration
Use Godot's built-in documentation system:
```gdscript
## This comment appears in Godot's help system
func documented_function():
```

### Documentation Generation
Consider using tools like:
- Godot's built-in help system
- Custom documentation generators
- Automated documentation validation scripts

## Examples from NederTiek Codebase

### Good Documentation Example
```gdscript
## Validate party data against Dutch political simulation rules
##
## Performs comprehensive validation including name appropriateness,
## policy keyword requirements, and ideology score constraints.
## Uses integrated profanity filter for content validation.
##
## @param party: Party - The party instance to validate
## @return ValidationResult - Contains validation status and any error messages
##
## @example
## var party = Party.new()
## party.name = "Progressive Alliance"
## var result = validate_party_data(party)
## if not result.is_valid:
##     print("Validation errors: " + str(result.errors))
func validate_party_data(party: Party) -> ValidationResult:
```

### Poor Documentation Example (Avoid)
```gdscript
# Check party
func check(p):
```

This example lacks:
- Clear description of what is being checked
- Parameter type and purpose
- Return value documentation
- No usage guidance

## Maintenance

1. **Update documentation** when changing function behavior
2. **Review documentation** during code reviews
3. **Test examples** to ensure they remain accurate
4. **Deprecate outdated** documentation patterns
5. **Refactor documentation** when refactoring code

Remember: Good documentation is an investment in code maintainability and developer productivity.
