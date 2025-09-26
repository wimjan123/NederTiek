# NederTiek - Scene Hierarchy & Navigation

## Scene Architecture Overview

NederTiek uses a hierarchical scene structure with clear separation between game phases and UI components. The architecture supports scalable UI rendering and seamless navigation between game states.

## Main Scene Flow

```
MainMenu.tscn
    ↓ [New Game Button]
NewGameFlow.tscn (Setup Coordinator)
    ├── PartySelection.tscn     (Phase 1)
    ├── LeaderCreation.tscn     (Phase 2)
    ├── MediaInterview.tscn     (Phase 3)
    └── [Review Phase]          (Phase 4 - Generated)
        ↓ [Start Game Button]
[Future: Main Game Scene]
```

## Scene Details

### MainMenu.tscn
**Path**: `scenes/main_menu/MainMenu.tscn`
**Controller**: `scripts/main_menu/MainMenu.gd`
**Purpose**: Primary entry point and main navigation hub

#### Node Structure
```
MainMenu (Control)
├── BackgroundLayer (CanvasLayer)
│   └── Background (ColorRect)
├── MainContainer (VBoxContainer)
│   ├── TitleSection (VBoxContainer)
│   │   ├── GameTitle (Label)
│   │   └── GameSubtitle (Label)
│   ├── MenuButtons (VBoxContainer)
│   │   ├── NewGameButton (Button)
│   │   ├── LoadGameButton (Button)
│   │   ├── SettingsButton (Button)
│   │   └── ExitButton (Button)
│   └── VersionLabel (Label)
└── SettingsDialog (AcceptDialog)
```

#### Navigation
- **New Game** → `NewGameFlow.tscn`
- **Load Game** → [Future: Save/Load System]
- **Settings** → Settings Dialog
- **Exit** → Application Close

---

### NewGameFlow.tscn
**Path**: `scenes/new_game/NewGameFlow.tscn`
**Controller**: `scripts/new_game/NewGameFlow.gd`
**Purpose**: Orchestrates the complete new game creation process

#### Node Structure
```
NewGameFlow (Control)
└── MainContainer (VBoxContainer)
    ├── Header (HBoxContainer)
    │   ├── BackButton (Button)
    │   ├── Title (Label)
    │   └── Progress (Label)
    ├── ContentArea (SubViewportContainer)
    │   └── SubViewport
    │       └── [Dynamic Phase Scene]
    └── Footer (HBoxContainer)
        ├── StatusLabel (Label)
        └── ContinueButton (Button)
```

#### SubViewport Architecture
The `ContentArea` uses a `SubViewportContainer` with a `SubViewport` for scalable rendering:
- **Automatic Scaling**: Handles different screen resolutions
- **Clean Transitions**: Seamless loading between phases
- **Resource Management**: Proper cleanup of previous scenes

#### Phase Management
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

---

### PartySelection.tscn
**Path**: `scenes/new_game/PartySelection.tscn`
**Controller**: `scripts/new_game/PartySelection.gd`
**Purpose**: Party selection and custom party creation (Phase 1)

#### Expected Node Structure
```
PartySelection (Control)
├── MainContainer (HBoxContainer)
│   ├── PartiesPanel (Panel)
│   │   └── PartiesContainer (VBoxContainer)
│   │       ├── SectionHeader (Label)
│   │       └── PartiesScroll (ScrollContainer)
│   │           └── PartiesList (VBoxContainer)
│   │               └── [PartyCard Components]
│   └── DetailsPanel (Panel)
│       └── DetailsContainer (VBoxContainer)
│           ├── PartyDetails (RichTextLabel)
│           ├── CustomPartyButton (Button)
│           └── ValidationLabel (Label)
└── CustomPartyDialog (AcceptDialog)
    └── [Custom Party Creation Form]
```

#### Features
- **Party List**: Display of 20+ real Dutch political parties
- **Party Details**: Comprehensive party information display
- **Custom Creation**: Dialog for creating custom parties
- **Validation**: Real-time validation of custom party data
- **Search/Filter**: [Future: Party filtering by ideology]

#### Signals
```gdscript
signal party_selected(party: Party)
signal custom_party_created(party: Party)
signal selection_changed()
```

---

### LeaderCreation.tscn
**Path**: `scenes/new_game/LeaderCreation.tscn`
**Controller**: `scripts/new_game/LeaderCreation.gd`
**Purpose**: Leader creation and background selection (Phase 2)

#### Node Structure
```
LeaderCreation (Control)
├── MainContainer (HBoxContainer)
│   ├── ContentArea (VBoxContainer)
│   │   ├── BackgroundPanel (Panel)
│   │   │   └── BackgroundContainer (VBoxContainer)
│   │   │       ├── SectionHeader (Label)
│   │   │       └── BackgroundScroll (ScrollContainer)
│   │   │           └── BackgroundList (VBoxContainer)
│   │   │               └── [BackgroundCard Components]
│   │   └── DetailsPanel (Panel)
│   │       └── DetailsContainer (VBoxContainer)
│   │           ├── PortraitContainer (HBoxContainer)
│   │           │   ├── PortraitRect (ColorRect)
│   │           │   └── PortraitButton (Button)
│   │           ├── NameForm (VBoxContainer)
│   │           │   ├── FirstNameInput (LineEdit)
│   │           │   └── LastNameInput (LineEdit)
│   │           ├── AttributesContainer (VBoxContainer)
│   │           │   ├── CharismaBar (HBoxContainer)
│   │           │   │   ├── CharismaProgress (ProgressBar)
│   │           │   │   └── CharismaValue (Label)
│   │           │   ├── IntelligenceBar (HBoxContainer)
│   │           │   ├── IntegrityBar (HBoxContainer)
│   │           │   ├── ExperienceBar (HBoxContainer)
│   │           │   ├── EnergyBar (HBoxContainer)
│   │           │   └── NetworkingBar (HBoxContainer)
│   │           └── ValidationLabel (Label)
│   └── LeaderPreview (Panel)
│       └── PreviewContainer (VBoxContainer)
│           ├── PreviewTitle (Label)
│           └── PreviewDetails (RichTextLabel)
```

#### Background Selection
- **8 Backgrounds**: All professional backgrounds available
- **Attribute Preview**: Real-time attribute display with modifiers
- **Impact Summary**: Clear display of background effects
- **Validation**: Real-time form validation

#### Portrait System
- **Simple Implementation**: Color-based avatar system
- **4 Color Options**: Different skin tone representations
- **Expandable**: Architecture supports future portrait assets

#### Signals
```gdscript
signal leader_created(leader: Leader)
signal background_selected(background: LeaderBackground)
signal validation_changed()
```

---

### MediaInterview.tscn
**Path**: `scenes/new_game/MediaInterview.tscn`
**Controller**: `scripts/new_game/MediaInterview.gd`
**Purpose**: Political positioning through interview questions (Phase 3)

#### Expected Node Structure
```
MediaInterview (Control)
├── MainContainer (VBoxContainer)
│   ├── ProgressSection (HBoxContainer)
│   │   ├── ProgressLabel (Label)
│   │   └── ProgressBar (ProgressBar)
│   ├── QuestionPanel (Panel)
│   │   └── QuestionContainer (VBoxContainer)
│   │       ├── QuestionCategory (Label)
│   │       ├── QuestionText (RichTextLabel)
│   │       └── AnswersContainer (VBoxContainer)
│   │           └── [Answer Button Components]
│   └── StatusPanel (Panel)
│       └── StatusContainer (VBoxContainer)
│           ├── ResponseCount (Label)
│           ├── ImpactPreview (RichTextLabel)
│           └── SkipButton (Button)
```

#### Question System
- **Dynamic Selection**: Questions chosen based on party and leader
- **Contextual Relevance**: Questions match political context
- **Category Diversity**: Ensures variety across policy areas
- **Progress Tracking**: Minimum 4 questions required

#### Answer Impact Display
- **Real-time Preview**: Shows impacts before selection
- **Detailed Tooltips**: Comprehensive impact descriptions
- **Cumulative Effects**: Running total of all answers

#### Signals
```gdscript
signal interview_complete(responses: Array)
signal question_answered(answer: MediaAnswer)
signal progress_changed()
```

---

## UI Component System

### Reusable Components

#### PartyCard.tscn
**Path**: `scenes/ui/components/PartyCard.tscn`
**Controller**: `scripts/ui/components/PartyCard.gd`
**Purpose**: Reusable party display component

```
PartyCard (Panel)
├── CardContainer (VBoxContainer)
│   ├── HeaderContainer (HBoxContainer)
│   │   ├── PartyName (Label)
│   │   └── PartyAbbrev (Label)
│   ├── DescriptionLabel (RichTextLabel)
│   ├── IdeologyContainer (HBoxContainer)
│   │   └── [Ideology Indicators]
│   ├── KeywordsContainer (FlowContainer)
│   │   └── [Policy Keyword Tags]
│   └── SelectButton (Button)
```

#### BackgroundCard.tscn
**Path**: `scenes/ui/components/BackgroundCard.tscn`
**Controller**: `scripts/ui/components/BackgroundCard.gd`
**Purpose**: Reusable background display component

```
BackgroundCard (Panel)
├── CardContainer (VBoxContainer)
│   ├── BackgroundName (Label)
│   ├── DescriptionText (RichTextLabel)
│   ├── ImpactSummary (Label)
│   ├── TraitsContainer (FlowContainer)
│   │   └── [Special Trait Tags]
│   └── SelectButton (Button)
```

#### PolicyKeywordSelector.tscn
**Path**: `scenes/ui/components/PolicyKeywordSelector.tscn`
**Controller**: `scripts/ui/components/PolicyKeywordSelector.gd`
**Purpose**: Multi-select policy keyword interface

```
PolicyKeywordSelector (Control)
├── HeaderLabel (Label)
├── KeywordsScroll (ScrollContainer)
│   └── KeywordsGrid (GridContainer)
│       └── [Keyword Checkbox Components]
└── ValidationLabel (Label)
```

### Theme System
**Path**: `scenes/ui/theme.tres`
**Purpose**: Centralized visual styling for consistent UI appearance

#### Theme Features
- **Consistent Typography**: Font sizes and styles
- **Color Palette**: Political party colors and neutral tones
- **Component Styling**: Button, panel, and input styles
- **Accessibility**: High contrast options and readable fonts

---

## Navigation & State Management

### Scene Transitions

#### Linear Progression
```
MainMenu → NewGameFlow → [Phase Scenes] → [Main Game]
```

#### Phase Navigation
```
PartySelection ⇄ LeaderCreation ⇄ MediaInterview ⇄ Review
```
- **Forward Navigation**: Validation required to advance
- **Backward Navigation**: Always available except from first phase
- **Skip Navigation**: Development helper for testing

#### State Persistence
- **Auto-Save**: Progress saved after each phase
- **Resume Support**: Can resume interrupted sessions
- **Validation Gates**: Cannot advance with invalid data

### Signal Architecture

#### Cross-Scene Communication
```
UI Component → Scene Controller → GameSetupState → Other Scene Controllers
```

#### Signal Flow Example
```
PartyCard.selected → PartySelection.party_selected → GameSetupState.set_party →
GameSetupState.party_data_updated → NewGameFlow._on_party_updated
```

### Error Handling

#### Graceful Degradation
- **Scene Loading Errors**: Fallback to previous scene
- **Validation Errors**: Clear user feedback with retry options
- **Resource Errors**: Default values with error logging

#### User Feedback
- **Loading States**: Progress indicators during scene transitions
- **Error Messages**: Clear, actionable error descriptions
- **Validation Feedback**: Real-time form validation

---

## Resource Management

### Scene Loading Strategy
- **On-Demand Loading**: Scenes loaded when needed
- **Memory Cleanup**: Previous scenes properly freed
- **Resource Caching**: Frequently used resources cached

### Asset Organization
```
scenes/
├── main_menu/          # Main menu scenes
├── new_game/           # New game flow scenes
└── ui/                 # Reusable UI components
    ├── components/     # Individual UI components
    └── theme.tres      # Global theme resource
```

### Performance Considerations
- **SubViewport Optimization**: Efficient rendering pipeline
- **Component Reuse**: Shared components reduce memory usage
- **Lazy Loading**: Components instantiated when needed

---

## Development Guidelines

### Scene Creation Standards
1. **Consistent Naming**: Use descriptive, consistent node names
2. **Logical Hierarchy**: Group related nodes logically
3. **Signal Connections**: Use code-based signal connections
4. **Theme Usage**: Apply global theme consistently

### UI Layout Principles
1. **Responsive Design**: Use container nodes for flexible layouts
2. **Accessibility**: Ensure keyboard navigation and screen reader support
3. **Visual Hierarchy**: Clear information hierarchy and focus management
4. **Error States**: Handle and display error conditions gracefully

### Testing Considerations
1. **Scene Isolation**: Each scene should function independently
2. **Signal Testing**: Verify signal connections work correctly
3. **Validation Testing**: Test all validation scenarios
4. **Navigation Testing**: Verify all navigation paths work

This scene hierarchy provides a solid foundation for the political simulation game with clear separation of concerns, robust navigation, and excellent user experience.