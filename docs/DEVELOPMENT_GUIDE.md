# NederTiek - Development Guide

## Getting Started

### Prerequisites
- **Godot Engine**: Version 4.x (latest stable)
- **Platform**: Windows, macOS, or Linux
- **Memory**: Minimum 4GB RAM recommended
- **Storage**: ~500MB for project and assets

### Initial Setup

1. **Clone Repository**
   ```bash
   git clone [repository-url]
   cd NederTiek
   ```

2. **Open in Godot**
   - Launch Godot Engine 4.x
   - Select "Import" and choose the `project.godot` file
   - Wait for initial import and asset processing

3. **Verify Setup**
   - Run the project (F5 or Play button)
   - Navigate through the main menu
   - Start a new game to verify all systems work

4. **Development Configuration**
   - Enable debug output in Project Settings
   - Configure version control settings if contributing
   - Set up any IDE/editor integrations for GDScript

### Project Structure Understanding

```
NederTiek/
├── project.godot           # Godot project configuration
├── scenes/                 # All game scenes
│   ├── main_menu/         # Main menu interface
│   ├── new_game/          # New game creation flow
│   └── ui/                # Reusable UI components
├── scripts/               # All GDScript code
│   ├── models/           # Data models and classes
│   ├── systems/          # Core game systems
│   ├── ui/               # UI controllers
│   ├── main_menu/        # Main menu logic
│   └── new_game/         # New game flow controllers
├── data/                 # Game data files
│   ├── parties/          # Party data and templates
│   ├── backgrounds/      # Leader background data
│   └── questions/        # Interview questions
├── assets/               # Art, audio, fonts
├── tests/                # Unit and integration tests
├── docs/                 # Documentation (this folder)
└── addons/               # Godot plugins/addons
```

---

## Development Workflow

### Git Workflow

#### Branch Strategy
```
main                    # Stable release branch
├── develop            # Integration branch
├── feature/xxx        # Feature development
├── bugfix/xxx         # Bug fixes
└── hotfix/xxx         # Critical fixes
```

#### Commit Guidelines
- **Atomic Commits**: One logical change per commit
- **Clear Messages**: Descriptive commit messages
- **Testing**: Ensure all tests pass before committing
- **Code Style**: Follow project coding standards

#### Example Workflow
```bash
# Create feature branch
git checkout -b feature/interview-system

# Make changes and commit
git add .
git commit -m "Add media interview question selection system"

# Push and create pull request
git push origin feature/interview-system
```

### Code Style Guidelines

#### GDScript Standards

**File Organization**
```gdscript
# File header with description
extends BaseClass
class_name ClassName

# Constants (SCREAMING_SNAKE_CASE)
const MAX_PARTY_COUNT = 20

# Signals
signal data_updated(data: Dictionary)

# Exported variables
@export var party_name: String = ""

# Public variables
var current_phase: String = "setup"

# Private variables
var _internal_data: Dictionary = {}

# Built-in overrides
func _ready():
    pass

# Public methods
func setup_party(party: Party):
    pass

# Private methods
func _validate_input() -> bool:
    return true
```

**Naming Conventions**
- **Classes**: PascalCase (`PartyGenerator`)
- **Functions**: snake_case (`create_leader`)
- **Variables**: snake_case (`selected_party`)
- **Constants**: SCREAMING_SNAKE_CASE (`BASE_TREASURY`)
- **Private Members**: _underscore_prefix (`_internal_state`)
- **Signals**: snake_case (`party_selected`)

**Documentation Standards**
```gdscript
# Class documentation
class_name PartyGenerator
# Generates and validates political parties for the game
# Supports both real Dutch parties and custom player-created parties

# Function documentation
func calculate_treasury(leader: Leader, party: Party, responses: Array) -> int:
    # Calculate starting treasury based on background, party, and interview
    # Args:
    #   leader: The created leader with background
    #   party: The selected political party
    #   responses: Array of MediaAnswer objects from interview
    # Returns:
    #   Final treasury amount in euros (10K - 1M range)
```

#### Scene Organization

**Node Naming**
- **Descriptive Names**: Clear purpose indication
- **Consistent Hierarchy**: Logical grouping
- **No Spaces**: Use underscores or PascalCase

**Scene Structure**
```
SceneName (Control)
├── MainContainer (VBoxContainer)
│   ├── HeaderSection (HBoxContainer)
│   ├── ContentArea (Panel)
│   └── FooterSection (HBoxContainer)
└── DialogLayer (CanvasLayer)
```

### Testing Strategy

#### Test Organization
```
tests/
├── unit/                  # Unit tests for individual classes
│   ├── test_party.gd     # Party model tests
│   ├── test_leader.gd    # Leader model tests
│   └── test_systems.gd   # System logic tests
├── integration/           # Integration tests
│   ├── test_setup_flow.gd # Full setup process tests
│   └── test_data_flow.gd  # Data flow between systems
└── ui/                    # UI and scene tests
    ├── test_navigation.gd # Scene navigation tests
    └── test_validation.gd # Form validation tests
```

#### Test Framework
The project uses **GUT (Godot Unit Testing)** for automated testing.

**Installation**
1. Install GUT addon from Asset Library
2. Configure test settings in project
3. Set up test runner in CI/CD

**Writing Tests**
```gdscript
extends GutTest

func test_party_validation():
    # Arrange
    var party = Party.new()
    party.name = "Test Party"
    party.abbreviation = "TP"
    party.description = "A test party for validation"
    party.policy_keywords = ["policy1", "policy2", "policy3", "policy4", "policy5"]

    # Act
    var result = party.validate()

    # Assert
    assert_true(result["valid"], "Valid party should pass validation")
    assert_eq(result["errors"].size(), 0, "No errors expected for valid party")

func test_party_validation_fails_short_name():
    # Arrange
    var party = Party.new()
    party.name = "TP"  # Too short

    # Act
    var result = party.validate()

    # Assert
    assert_false(result["valid"], "Party with short name should fail validation")
    assert_true("Party name must be at least 3 characters" in result["errors"])
```

#### Test Coverage Goals
- **Unit Tests**: >80% coverage for models and systems
- **Integration Tests**: All major workflows covered
- **UI Tests**: Critical user paths validated

### Debugging Guidelines

#### Debug Output
```gdscript
# Use structured debug output
print("GameSetupState: Phase changed from '%s' to '%s'" % [previous_phase, current_phase])

# Include context in error messages
push_error("PartyGenerator: Failed to validate party '%s': %s" % [party.name, error_message])

# Use appropriate log levels
print("INFO: Successfully loaded %d backgrounds" % backgrounds.size())
print("WARNING: Low treasury amount may create difficult gameplay")
push_error("ERROR: Critical validation failure")
```

#### Performance Monitoring
- **PerformanceMonitor**: Use built-in performance tracking
- **Memory Profiling**: Monitor resource usage in development
- **Frame Rate**: Maintain 60 FPS target

#### Common Debug Scenarios

**Setup Flow Issues**
```gdscript
# Enable debug output in GameSetupState
func advance_phase():
    print("DEBUG: advance_phase() called, current_phase = '%s'" % current_phase)
    print("DEBUG: Validation state: party=%s, leader=%s, background=%s" %
          [selected_party != null, leader != null, selected_background != null])
```

**UI Layout Problems**
```gdscript
# Debug SubViewport sizing
func _on_viewport_size_changed():
    print("DEBUG: Window resized to %s" % get_viewport().size)
    print("DEBUG: SubViewport size: %s" % sub_viewport.size)
```

---

## System Extension Guidelines

### Adding New Game Systems

1. **System Design**
   - Create system class in `scripts/systems/`
   - Extend `Node` for singleton systems
   - Follow existing patterns and naming

2. **Integration Points**
   - Add to autoload if needed
   - Connect to GameSetupState signals
   - Update relevant UI controllers

3. **Testing**
   - Create unit tests for system logic
   - Add integration tests for system interactions
   - Test UI integration

### Adding New Data Models

1. **Model Creation**
   ```gdscript
   extends Resource
   class_name NewModel

   @export var id: String = ""
   @export var name: String = ""
   # ... other properties

   func validate() -> Dictionary:
       # Implement validation
       pass
   ```

2. **Integration**
   - Add to relevant systems
   - Update UI components
   - Add to save/load system

3. **Documentation**
   - Update API reference
   - Add usage examples
   - Document validation rules

### Adding New UI Components

1. **Component Structure**
   ```
   ComponentName.tscn
   ├── ComponentName (Control)
   │   └── [Component hierarchy]
   ```

2. **Controller Script**
   ```gdscript
   extends Control
   class_name ComponentName

   signal component_interaction(data)

   @export var data: CustomData

   func setup_component(data: CustomData):
       # Initialize component
       pass
   ```

3. **Integration**
   - Add to parent scenes
   - Connect signals
   - Update theme if needed

### Extending Interview System

1. **New Question Categories**
   ```gdscript
   # Add to MediaQuestion
   static func create_new_category_questions() -> Array[MediaQuestion]:
       var questions: Array[MediaQuestion] = []
       # Create questions for new category
       return questions
   ```

2. **Update Question Selector**
   ```gdscript
   # Add to QuestionSelector._load_question_pools()
   var new_questions = MediaQuestion.create_new_category_questions()
   all_questions.append_array(new_questions)
   ```

3. **UI Updates**
   - Update interview UI for new categories
   - Add category-specific styling
   - Test question flow

---

## Quality Assurance

### Code Review Checklist

#### Functionality
- [ ] Code works as intended
- [ ] All edge cases handled
- [ ] Error handling implemented
- [ ] Performance implications considered

#### Code Quality
- [ ] Follows project style guidelines
- [ ] Proper documentation included
- [ ] No code duplication
- [ ] Clean, readable code structure

#### Testing
- [ ] Unit tests written/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] No regression issues

#### Integration
- [ ] Signals properly connected
- [ ] GameSetupState integration
- [ ] UI properly updated
- [ ] Resource management correct

### Performance Guidelines

#### Optimization Targets
- **Frame Rate**: Maintain 60 FPS
- **Memory Usage**: < 500MB typical usage
- **Load Times**: < 3 seconds scene transitions
- **Responsiveness**: < 100ms UI interactions

#### Profiling Tools
- **Godot Profiler**: Built-in performance analysis
- **Memory Profiler**: Track resource usage
- **Network Profiler**: Monitor signals and calls

#### Common Optimizations
```gdscript
# Cache expensive calculations
var cached_result: Dictionary = {}

func get_expensive_calculation(key: String) -> Dictionary:
    if key not in cached_result:
        cached_result[key] = _perform_calculation(key)
    return cached_result[key]

# Use object pooling for frequently created objects
var answer_button_pool: Array[Button] = []

func get_answer_button() -> Button:
    if answer_button_pool.size() > 0:
        return answer_button_pool.pop_back()
    else:
        return Button.new()
```

### Accessibility Guidelines

#### Implementation Requirements
- **Keyboard Navigation**: All UI accessible via keyboard
- **Screen Reader**: Proper ARIA labels and descriptions
- **Color Blind**: Don't rely solely on color for information
- **Text Scaling**: Support system text scaling
- **High Contrast**: Alternative color schemes

#### Testing
- Test with screen reader software
- Verify keyboard-only navigation
- Test with high contrast themes
- Validate with accessibility tools

---

## Deployment & Distribution

### Build Configuration

#### Export Settings
1. **Platform Configuration**
   - Windows: 64-bit executable
   - macOS: Universal binary
   - Linux: 64-bit executable

2. **Resources**
   - Include all necessary files
   - Exclude development assets
   - Optimize texture imports

3. **Features**
   - Enable required Godot features only
   - Configure window settings
   - Set icon and metadata

#### Build Process
```bash
# Automated build script
godot --headless --export "Windows Desktop" builds/NederTiek-Windows.exe
godot --headless --export "macOS" builds/NederTiek-macOS.app
godot --headless --export "Linux/X11" builds/NederTiek-Linux.x86_64
```

### Release Process

1. **Version Management**
   - Update version in project.godot
   - Tag release in version control
   - Update documentation

2. **Quality Assurance**
   - Run full test suite
   - Manual testing on target platforms
   - Performance validation

3. **Distribution**
   - Package for distribution platforms
   - Create release notes
   - Update documentation

### Continuous Integration

#### GitHub Actions Example
```yaml
name: Build and Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
      - name: Run Tests
        run: godot --headless -s addons/gut/gut_cmdln.gd
```

---

## Troubleshooting

### Common Issues

#### Scene Loading Problems
```gdscript
# Issue: Gray screen on scene transition
# Solution: Verify SubViewport configuration
func _load_scene(scene_path: String):
    print("DEBUG: Loading scene: %s" % scene_path)
    var scene_resource = load(scene_path)
    if scene_resource == null:
        push_error("Failed to load scene: %s" % scene_path)
        return

    current_scene = scene_resource.instantiate()
    sub_viewport.add_child(current_scene)
```

#### Signal Connection Issues
```gdscript
# Issue: Signals not firing
# Solution: Check signal connections
func _ready():
    if not GameSetupState.setup_phase_changed.is_connected(_on_phase_changed):
        GameSetupState.setup_phase_changed.connect(_on_phase_changed)
```

#### Validation Problems
```gdscript
# Issue: Validation not updating
# Solution: Ensure validation is called
func _on_input_changed():
    _update_validation()
    validation_changed.emit()
```

### Debug Tools

#### Built-in Debugging
- **Remote Debugger**: Debug running games
- **Scene Dock**: Inspect node hierarchy
- **Inspector**: Monitor property values
- **Output Panel**: View print statements and errors

#### Custom Debug Features
```gdscript
# Debug overlay for development
func _input(event):
    if OS.is_debug_build() and event.is_action_pressed("debug_overlay"):
        toggle_debug_overlay()

func toggle_debug_overlay():
    var debug_info = "Phase: %s\nParty: %s\nLeader: %s" % [
        GameSetupState.current_phase,
        GameSetupState.selected_party.name if GameSetupState.selected_party else "None",
        GameSetupState.leader.get_full_name() if GameSetupState.leader else "None"
    ]
    # Display debug overlay
```

### Performance Issues

#### Memory Leaks
- Check for unreleased resources
- Verify signal disconnections
- Monitor scene cleanup

#### Frame Rate Drops
- Profile using Godot's profiler
- Check for expensive operations in _process()
- Optimize UI updates

---

## Contributing Guidelines

### Pull Request Process

1. **Before Starting**
   - Check existing issues and PRs
   - Discuss major changes first
   - Fork repository and create feature branch

2. **Development**
   - Follow coding standards
   - Write/update tests
   - Update documentation

3. **Submission**
   - Clear PR description
   - Link related issues
   - Request appropriate reviewers

### Issue Reporting

#### Bug Reports
- **Clear Title**: Descriptive issue summary
- **Reproduction Steps**: How to reproduce the bug
- **Expected vs Actual**: What should happen vs what happens
- **Environment**: Godot version, platform, etc.
- **Screenshots**: Visual evidence if applicable

#### Feature Requests
- **Use Case**: Why is this needed?
- **Proposed Solution**: How should it work?
- **Alternatives**: Other approaches considered
- **Implementation**: Technical considerations

### Community Guidelines

- **Be Respectful**: Professional and constructive communication
- **Be Patient**: Maintainers are volunteers
- **Be Helpful**: Help others when possible
- **Follow Standards**: Adhere to project conventions

---

## Resources & References

### Godot Resources
- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/)

### Dutch Politics References
- [Tweede Kamer](https://www.tweedekamer.nl/)
- [Political Parties Netherlands](https://en.wikipedia.org/wiki/List_of_political_parties_in_the_Netherlands)
- [Dutch Electoral System](https://www.government.nl/topics/elections)

### Development Tools
- **IDEs**: VS Code with Godot Tools, Vim with LSP
- **Version Control**: Git with GitHub/GitLab
- **Testing**: GUT (Godot Unit Testing)
- **Documentation**: Markdown with GitHub Pages

This development guide provides a comprehensive foundation for contributing to and extending the NederTiek political simulation game.