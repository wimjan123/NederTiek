# Research Document: New Game Setup Implementation

## Technical Decisions

### 1. Godot Scene Architecture
**Decision**: Use separate scenes for each setup phase (PartySelection, LeaderCreation, MediaInterview)
**Rationale**:
- Promotes modularity and easier testing of individual components
- Allows for scene transitions with built-in Godot scene management
- Each scene can be developed and tested independently
**Alternatives Considered**:
- Single monolithic scene: Rejected due to complexity and maintainability concerns
- Popup-based flow: Rejected as it doesn't provide clear progression feedback

### 2. Party Generation System
**Decision**: Hybrid procedural generation using base templates with variations
**Rationale**:
- Base templates ensure authentic Dutch political archetypes
- Procedural variations provide replayability
- JSON configuration allows easy balancing and localization
**Alternatives Considered**:
- Fully random generation: Rejected as it may produce unrealistic parties
- Fixed party list: Rejected as it reduces replayability

### 3. Data Persistence
**Decision**: Use Godot's ConfigFile for save data, JSON for configuration
**Rationale**:
- ConfigFile provides native Godot integration for save games
- JSON for party/background data enables external editing and modding
- Clear separation between player data and game content
**Alternatives Considered**:
- SQLite database: Rejected as overkill for this scope
- Binary save files: Rejected due to debugging difficulty

### 4. UI Framework
**Decision**: Godot's native Control nodes with custom theming
**Rationale**:
- Native integration with Godot's scene system
- Built-in support for UI scaling and accessibility
- Consistent with constitution's requirement for accessible UI
**Alternatives Considered**:
- External UI library: Rejected due to added complexity
- Immediate mode GUI: Not well-supported in Godot

### 5. State Management
**Decision**: Singleton GameSetupState autoload for setup flow state
**Rationale**:
- Persists across scene changes
- Provides central access point for setup data
- Follows common Godot pattern for game state
**Alternatives Considered**:
- Scene-to-scene parameter passing: Error-prone and complex
- Global signals only: Insufficient for data persistence

## Best Practices Research

### Godot 4.x Patterns
1. **Signal-based Communication**: Use signals for loose coupling between UI and logic
2. **Resource Classes**: Define Party and Leader as Resource classes for easy serialization
3. **Scene Inheritance**: Create base UI components that can be extended
4. **Autoload Managers**: Use autoloads for persistent systems (PartyGenerator, SaveManager)

### Dutch Political Context
1. **Party Naming Conventions**:
   - Abbreviations common (VVD, PvdA, D66)
   - Descriptive names for new parties
   - Include both traditional and modern party types

2. **Policy Categories**:
   - Economic (taxes, welfare, business)
   - Social (healthcare, education, housing)
   - Environmental (climate, energy, agriculture)
   - Immigration & Integration
   - EU & International Relations
   - Law & Order

3. **Leader Backgrounds** (8 types):
   - Career Politician
   - Business Executive
   - Academic/Professor
   - Activist/NGO Leader
   - Media Personality
   - Local Administrator
   - Union Leader
   - Military/Security Background

### Interview Question Design
1. **Contextual Questions**: Based on party ideology and current events
2. **Response Types**: Multiple choice with clear trade-offs
3. **Impact**: Each answer affects multiple attributes (popularity, treasury, credibility)
4. **Localization**: Questions reference Dutch political issues and institutions

## Integration Requirements

### Scene Flow Management
```gdscript
# NewGameFlow.gd manages the entire setup sequence
extends Node

signal setup_complete(game_data: Dictionary)

var current_phase: int = 0
var setup_data: Dictionary = {}

func advance_phase():
    match current_phase:
        0: get_tree().change_scene_to_file("res://scenes/new_game/PartySelection.tscn")
        1: get_tree().change_scene_to_file("res://scenes/new_game/LeaderCreation.tscn")
        2: get_tree().change_scene_to_file("res://scenes/new_game/MediaInterview.tscn")
        3: finalize_setup()
```

### Data Model Relationships
- Party has_many PolicyKeywords
- Leader belongs_to Party
- Leader has_one Background
- Interview affects Leader.attributes and Party.treasury/popularity

## Performance Considerations
1. **Party Generation**: Pre-generate at scene load, not during browsing
2. **Asset Loading**: Lazy-load party images/descriptions as needed
3. **Save Operations**: Async save to prevent UI freezing
4. **Memory Management**: Clear setup scenes from memory after completion

## Resolved Clarifications
All technical context items have been researched and resolved. No NEEDS CLARIFICATION items remain.