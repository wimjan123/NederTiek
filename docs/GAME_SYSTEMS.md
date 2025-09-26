# NederTiek - Game Systems Documentation

## Core Game Systems

### 1. GameSetupState System (Singleton)

**File**: `scripts/systems/GameSetupState.gd`
**Type**: Autoload Singleton
**Purpose**: Central coordinator for the new game creation process

#### Responsibilities
- **Phase Management**: Controls progression through setup phases
- **Data Persistence**: Maintains state across scene transitions
- **Validation**: Ensures data integrity throughout setup
- **Signal Coordination**: Communicates between different UI components

#### Setup Phases
1. **party_selection**: Choose or create political party
2. **leader_creation**: Define party leader with background
3. **media_interview**: Answer questions to establish positions
4. **review**: Final confirmation and game start

#### Key Properties
```gdscript
# Current setup data
var selected_party: Party
var selected_background: LeaderBackground
var leader: Leader
var interview_responses: Array = []
var setup_complete: bool = false

# Phase tracking
var current_phase: String = "party_selection"
var previous_phase: String = ""

# Generated data cache
var generated_parties: Array = []
var available_backgrounds: Array[LeaderBackground] = []
```

#### Signal Events
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
```

#### Key Methods
- `advance_phase()`: Progress to next setup phase
- `go_back()`: Return to previous phase
- `set_party(party: Party)`: Set selected party with validation
- `create_leader(first_name: String, last_name: String)`: Create leader instance
- `compile_game_start_data()`: Generate final game configuration

---

### 2. Party Management System

**Files**: `scripts/models/Party.gd`, `scripts/systems/PartyGenerator.gd`

#### Party Model (scripts/models/Party.gd)
Represents political parties with comprehensive data model.

**Core Properties**:
```gdscript
@export var id: String                    # Unique identifier
@export var name: String                  # Full party name
@export var abbreviation: String          # Short acronym (2-6 chars)
@export var description: String           # Party description
@export var policy_keywords: Array        # Political positions (5-10 keywords)
@export var ideology_scores: Dictionary   # Multi-dimensional positioning
@export var color_primary: Color          # Primary brand color
@export var color_secondary: Color        # Secondary brand color
@export var is_custom: bool              # Player-created party
@export var is_official: bool            # Real Dutch party
```

**Ideology Dimensions**:
- `economic_left_right`: Economic policy spectrum (-1.0 to 1.0)
- `social_liberal_conservative`: Social policy spectrum (-1.0 to 1.0)
- `eu_skeptic_federal`: EU integration stance (-1.0 to 1.0)
- `environment_economy`: Environmental vs Economic priorities (-1.0 to 1.0)
- `centralization`: Government centralization preference (-1.0 to 1.0)

#### Party Generator (scripts/systems/PartyGenerator.gd)
Manages party creation and validation.

**Features**:
- **20 Real Dutch Parties**: Accurate representation of major Dutch political parties
- **Custom Party Validation**: Comprehensive validation for player-created parties
- **Profanity Filtering**: Content validation using ProfanityFilter system
- **Uniqueness Checking**: Prevents duplicate names and abbreviations

**Real Dutch Parties Included**:
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

### 3. Leader Management System

**Files**: `scripts/models/Leader.gd`, `scripts/models/LeaderBackground.gd`

#### Leader Model (scripts/models/Leader.gd)
Represents party leaders with attributes and background.

**Core Properties**:
```gdscript
@export var first_name: String            # Leader's first name
@export var last_name: String             # Leader's last name
@export var background_id: String         # Associated background type
@export var party_id: String              # Associated party
@export var portrait_index: int           # Visual representation
@export var attributes: Dictionary        # Core leadership attributes
@export var starting_treasury: int        # Initial campaign funds (euros)
@export var starting_popularity: float    # Initial public support (0-100%)
```

**Leadership Attributes** (0-100 scale):
- **Charisma**: Media appeal and rally effectiveness
- **Intelligence**: Policy development and debate performance
- **Integrity**: Scandal resistance and coalition trust
- **Experience**: Crisis management and negotiation skill
- **Energy**: Campaign stamina and action points
- **Networking**: Coalition building and fundraising ability

#### Leader Background System (scripts/models/LeaderBackground.gd)
Eight distinct professional backgrounds that modify leader attributes.

**Available Backgrounds**:

1. **Career Politician**
   - +20 Experience, +15 Networking, +10 Intelligence, +5 Charisma, +5 Energy
   - -5 Integrity
   - +30% Treasury, -5% Popularity
   - Traits: Coalition Builder, System Knowledge

2. **Business Executive**
   - +15 Intelligence, +15 Energy, +10 Charisma, +10 Networking, +5 Integrity
   - -10 Experience
   - +100% Treasury, +5% Popularity
   - Traits: Business Connections, Economic Focus

3. **Academic/Professor**
   - +25 Intelligence, +15 Integrity
   - -5 Experience, -5 Energy
   - -20% Treasury
   - Traits: Policy Expert, Research Skills

4. **Activist/NGO Leader**
   - +20 Integrity, +20 Energy, +15 Charisma, +5 Intelligence
   - -10 Networking, -5 Experience
   - -40% Treasury, +10% Popularity
   - Traits: Grassroots Support, Social Movement Ties

5. **Media Personality**
   - +25 Charisma, +10 Energy, +5 Networking
   - -15 Experience, -5 Integrity
   - +20% Treasury, +20% Popularity
   - Traits: Media Savvy, Name Recognition

6. **Local Administrator**
   - +15 Experience, +10 Intelligence, +10 Integrity, +5 Charisma, +5 Energy, +5 Networking
   - Balanced background
   - Traits: Practical Experience, Local Network

7. **Union Leader**
   - +20 Networking, +15 Energy, +10 Charisma, +10 Integrity, +10 Experience, +5 Intelligence
   - -10% Treasury, +5% Popularity
   - Traits: Labor Support, Negotiation Skills

8. **Military/Security Background**
   - +20 Integrity, +15 Experience, +10 Intelligence, +10 Energy
   - -5 Networking
   - -5% Popularity
   - Traits: Security Expertise, Disciplined Leadership

---

### 4. Media Interview System

**File**: `scripts/new_game/MediaInterview.gd`
**Purpose**: Political positioning through interactive question-answer sessions

#### System Features
- **Dynamic Question Selection**: Questions chosen based on party type and current events
- **Response Impact**: Answers affect leader attributes and party positioning
- **Progress Tracking**: Minimum 4 questions required for completion
- **Treasury Calculation**: Interview performance influences starting campaign funds
- **Popularity Impact**: Media responses directly affect initial public support

#### Question Categories
- Economic Policy
- Social Issues
- Environmental Policy
- EU Relations
- Immigration
- Security & Defense
- Education & Healthcare

#### Response Effects
Each answer can modify:
- Leader attributes (+/- adjustments)
- Party ideology scores
- Starting treasury (through public/business support)
- Initial popularity ratings

---

### 5. UI Flow Management

**File**: `scripts/new_game/NewGameFlow.gd`
**Purpose**: Orchestrates the complete new game creation experience

#### Phase Management
Manages four distinct phases with seamless transitions:

```gdscript
var phases = [
    {
        "id": "party_selection",
        "title": "Choose Your Party",
        "scene_path": "res://scenes/new_game/PartySelection.tscn",
        "status_text": "Select or create your political party"
    },
    {
        "id": "leader_creation",
        "title": "Create Your Leader",
        "scene_path": "res://scenes/new_game/LeaderCreation.tscn",
        "status_text": "Define your party leader's background and details"
    },
    {
        "id": "media_interview",
        "title": "Media Interview",
        "scene_path": "res://scenes/new_game/MediaInterview.tscn",
        "status_text": "Answer questions to establish your political positions"
    },
    {
        "id": "review",
        "title": "Review & Confirm",
        "scene_path": "",  # Generated dynamically
        "status_text": "Review your setup and start the game"
    }
]
```

#### SubViewport Architecture
Uses SubViewportContainer for scalable UI rendering:
- **Responsive Design**: Automatic scaling for different screen sizes
- **Clean Transitions**: Seamless scene loading within viewport
- **Memory Management**: Proper cleanup of previous scenes

#### State Persistence
- **Auto-Save**: Progress saved after each phase completion
- **Resume Support**: Can resume interrupted setup sessions
- **Validation Gates**: Cannot advance without completing current phase

---

### 6. Data Management Systems

#### SetupDataManager (scripts/systems/SetupDataManager.gd)
Calculates final starting conditions based on setup choices.

**Calculations**:
- **Treasury Calculation**: Based on background, party type, and interview responses
- **Popularity Calculation**: Influenced by background, party appeal, and media performance
- **Attribute Finalization**: Applies all modifiers from background and interviews

#### ProfanityFilter (scripts/systems/ProfanityFilter.gd)
Content validation system for user-generated content.

**Features**:
- Custom party name validation
- Inappropriate content detection
- Configurable filtering levels
- Dutch language support

---

### 7. Accessibility Systems

#### AccessibilityHelper (scripts/systems/AccessibilityHelper.gd)
Comprehensive accessibility support system.

**Features**:
- Screen reader compatibility
- Keyboard navigation support
- High contrast mode support
- Text scaling options
- Audio cues for important events

#### PerformanceMonitor (scripts/systems/PerformanceMonitor.gd)
Real-time performance tracking and optimization.

**Monitoring**:
- Frame rate tracking
- Memory usage monitoring
- Scene loading performance
- User experience metrics

---

## System Integration

### Signal Flow Architecture
```
GameSetupState (Central Hub)
    ↓ signals ↑
NewGameFlow (UI Coordinator)
    ↓ signals ↑
Phase-Specific Scenes
    ↓ signals ↑
UI Components
```

### Data Flow
1. **User Input** → UI Components
2. **Validation** → GameSetupState
3. **State Update** → Signal Emission
4. **UI Update** → Visual Feedback
5. **Phase Completion** → Advance to Next Phase

### Error Handling
- **Validation Errors**: Real-time feedback for invalid input
- **System Errors**: Graceful degradation with user notification
- **Recovery**: Ability to correct errors and continue
- **Logging**: Comprehensive debug information for development

This modular system architecture provides a robust foundation for political simulation gameplay while maintaining clean separation of concerns and excellent user experience.