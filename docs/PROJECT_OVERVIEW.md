# NederTiek - Project Overview

## Project Description
**NederTiek** is a Dutch political simulation game built with Godot 4.x and GDScript. Players create political parties, develop party leaders, and navigate the complex landscape of Dutch politics through strategic decision-making and media interactions.

## Core Concept
The game simulates the Dutch political system, allowing players to:
- Choose from 20+ real Dutch political parties or create custom parties
- Develop unique party leaders with different backgrounds and attributes
- Navigate media interviews that shape public opinion
- Make strategic decisions that affect party popularity and treasury

## Technical Architecture

### Engine & Language
- **Engine**: Godot 4.x (latest stable)
- **Language**: GDScript
- **Architecture**: Node-based scene system with autoload singletons

### Project Structure
```
NederTiek/
├── scenes/                 # Game scenes and UI
│   ├── main_menu/         # Main menu interface
│   ├── new_game/          # New game creation flow
│   └── ui/                # Reusable UI components
├── scripts/               # All GDScript files
│   ├── models/           # Data models (Party, Leader, etc.)
│   ├── systems/          # Core game systems
│   ├── ui/               # UI controllers
│   ├── main_menu/        # Main menu logic
│   └── new_game/         # New game flow logic
├── data/                 # Game data files
│   ├── parties/          # Party templates and data
│   ├── backgrounds/      # Leader background data
│   └── questions/        # Media interview questions
├── assets/               # Game assets
└── docs/                 # Documentation
```

### Core Systems

#### 1. GameSetupState (Singleton)
The central coordination system that manages the entire new game creation process:
- **Purpose**: Maintains state across scene transitions during game setup
- **Phases**: Party Selection → Leader Creation → Media Interview → Review
- **Responsibilities**:
  - Phase progression management
  - Data validation and persistence
  - Signal coordination between UI components
  - Final game data compilation

#### 2. Party System
Comprehensive political party management:
- **Real Dutch Parties**: 20+ authentic Dutch political parties with accurate ideologies
- **Custom Parties**: Player-created parties with policy keyword validation
- **Party Generator**: Procedural generation system for additional variety
- **Ideology Scoring**: Multi-dimensional political positioning system

#### 3. Leader System
Character creation and development:
- **8 Background Types**: Career Politician, Business Executive, Academic, Activist, etc.
- **Attribute System**: Charisma, Intelligence, Integrity, Experience, Energy, Networking
- **Visual Customization**: Simple portrait system with color variations
- **Background Modifiers**: Each background affects starting attributes and conditions

#### 4. Media Interview System
Political positioning through interactive interviews:
- **Question Pool**: Dynamic question selection system
- **Answer Impact**: Responses affect leader attributes and party positioning
- **Treasury Calculation**: Interview performance influences starting funds
- **Popularity Impact**: Media responses directly affect initial public support

### Scene Architecture

#### Main Flow
```
MainMenu.tscn
    ↓ [New Game]
NewGameFlow.tscn
    ↓ [Phase Management]
├── PartySelection.tscn     # Phase 1: Choose/Create Party
├── LeaderCreation.tscn     # Phase 2: Create Leader
├── MediaInterview.tscn     # Phase 3: Answer Questions
└── [Review Phase]          # Phase 4: Final Confirmation
    ↓ [Start Game]
[Future: Main Game Scene]
```

#### UI Component System
- **SubViewport Architecture**: Scalable UI system with proper rendering
- **Component Reusability**: Modular UI components (PartyCard, BackgroundCard, etc.)
- **Signal-Driven Communication**: Loose coupling between UI components
- **Validation System**: Real-time form validation with user feedback

### Data Models

#### Party Model
```gdscript
class_name Party extends Resource
- id: String                    # Unique identifier
- name: String                  # Full party name
- abbreviation: String          # Short acronym
- description: String           # Party description
- policy_keywords: Array        # Political positions
- ideology_scores: Dictionary   # Multi-dimensional political positioning
- color_primary/secondary: Color # Visual identity
- is_custom/is_official: bool   # Origin tracking
```

#### Leader Model
```gdscript
class_name Leader extends Resource
- first_name/last_name: String      # Personal identity
- background_id: String             # Associated background type
- attributes: Dictionary            # Core attributes (0-100 scale)
- starting_treasury: int            # Initial campaign funds
- starting_popularity: float        # Initial public support
- portrait_index: int               # Visual representation
```

#### LeaderBackground Model
```gdscript
class_name LeaderBackground extends Resource
- name/description: String          # Background information
- attribute_modifiers: Dictionary   # Attribute bonuses/penalties
- treasury_modifier: float          # Financial impact multiplier
- popularity_modifier: float        # Base popularity adjustment
- special_traits: Array            # Unique background advantages
```

### Game Flow

#### Setup Process
1. **Party Selection**: Choose existing party or create custom party
2. **Leader Creation**: Select background and customize leader details
3. **Media Interview**: Answer 4+ questions to establish political positions
4. **Review & Confirm**: Final validation and game start preparation

#### State Management
- **Phase Progression**: Controlled advancement through setup phases
- **Data Validation**: Comprehensive validation at each phase
- **Save/Load System**: Persistent setup state for session resumption
- **Error Handling**: Graceful error recovery with user feedback

### Key Features

#### Accessibility
- **AccessibilityHelper**: Dedicated system for screen reader support
- **Keyboard Navigation**: Full keyboard accessibility
- **High Contrast**: Visual accessibility considerations

#### Performance
- **PerformanceMonitor**: Real-time performance tracking
- **Profanity Filter**: Content validation system
- **Resource Management**: Efficient memory and loading patterns

#### Extensibility
- **Template System**: JSON-driven party generation templates
- **Plugin Architecture**: Modular system design
- **Configuration Files**: External data files for easy modification

## Technical Highlights

### Signal Architecture
Comprehensive signal-based communication system:
- **GameSetupState Signals**: Phase changes, data updates, validation errors
- **UI Component Signals**: User interactions, state changes
- **Cross-System Communication**: Loose coupling through signal patterns

### Resource Management
- **Godot Resource System**: Proper use of Godot's resource architecture
- **Save/Load Integration**: ConfigFile-based persistence system
- **Memory Efficiency**: Proper resource cleanup and management

### Validation System
Multi-layer validation approach:
- **Model-Level Validation**: Data integrity at the model level
- **UI-Level Validation**: Real-time user feedback
- **System-Level Validation**: Cross-system consistency checks

## Development Philosophy
- **Dutch Political Accuracy**: Authentic representation of Dutch political landscape
- **Educational Value**: Teaches political system mechanics through gameplay
- **Accessibility First**: Inclusive design for all players
- **Modular Architecture**: Easy to extend and modify
- **Quality Assurance**: Comprehensive validation and error handling

## Future Expansion
The architecture supports expansion into:
- **Main Game Loop**: Turn-based political gameplay
- **Coalition Building**: Multi-party negotiation systems
- **Election Campaigns**: Strategic campaign management
- **Policy Implementation**: Governance simulation mechanics
- **Multiplayer Support**: Multi-player political competition

This foundation provides a robust platform for a comprehensive Dutch political simulation experience.