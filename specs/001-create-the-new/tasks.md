# Tasks: New Game Setup - NederTiek

**Input**: Design documents from `/specs/001-create-the-new/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Extract: Godot 4.x, GDScript, node-based architecture
2. Load design documents:
   → data-model.md: 6 entities (Party, Leader, etc.)
   → contracts/: Signal contracts for Godot scenes
   → research.md: Technical decisions (scene architecture, state management)
3. Generate tasks by category:
   → Setup: Godot project init, folder structure
   → Models: Resource classes for entities
   → Systems: Core game systems (PartyGenerator, etc.)
   → Scenes: UI scenes and controllers
   → Integration: Signal connections, flow management
   → Tests: GUT framework tests
4. Apply Godot-specific rules:
   → Resource files can be created in parallel [P]
   → Scene files can be created in parallel [P]
   → Scripts for scenes depend on scene creation
5. Number tasks sequentially (T001, T002...)
6. Return: SUCCESS (47 tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- Godot project structure as defined in plan.md
- Scenes in `scenes/` directory
- Scripts in `scripts/` directory
- Data files in `data/` directory
- Tests in `tests/` directory

## Phase 3.1: Setup & Structure
- [x] T001 Initialize Godot 4.x project with project.godot configuration
- [x] T002 Create directory structure: scenes/, scripts/, data/, tests/
- [x] T003 [P] Create subdirectories: scenes/new_game/, scenes/ui/components/, scripts/new_game/, scripts/models/, scripts/systems/
- [x] T004 [P] Install and configure GUT testing framework addon
- [x] T005 [P] Create data subdirectories: data/parties/, data/backgrounds/, data/questions/

## Phase 3.2: Data Models (Resource Classes)
**Note**: These are Godot Resource classes that can be created independently
- [x] T006 [P] Create Party resource class in scripts/models/Party.gd with all fields from data-model.md
- [x] T007 [P] Create Leader resource class in scripts/models/Leader.gd with attributes dictionary
- [x] T008 [P] Create LeaderBackground resource in scripts/models/LeaderBackground.gd
- [x] T009 [P] Create PolicyKeyword resource in scripts/models/PolicyKeyword.gd
- [x] T010 [P] Create MediaQuestion resource in scripts/models/MediaQuestion.gd
- [x] T011 [P] Create MediaAnswer resource in scripts/models/MediaAnswer.gd

## Phase 3.3: Core Systems
- [x] T012 Create GameSetupState singleton autoload in scripts/systems/GameSetupState.gd
- [x] T013 [P] Create PartyGenerator system in scripts/systems/PartyGenerator.gd with generate_parties() method
- [x] T014 [P] Create SetupDataManager in scripts/systems/SetupDataManager.gd for calculations
- [x] T015 [P] Create QuestionSelector in scripts/systems/QuestionSelector.gd for contextual questions
- [x] T016 Create party templates JSON in data/parties/templates.json with Dutch political archetypes
- [x] T017 [P] Create background definitions in data/backgrounds/ (8 .tres files)
- [x] T018 [P] Create question pool JSON in data/questions/pool.json

## Phase 3.4: UI Scenes & Controllers
**Scene Creation** (can be parallel as they're independent files)
- [x] T019 [P] Create NewGameFlow.tscn in scenes/new_game/ with base Control node structure
- [x] T020 [P] Create PartySelection.tscn in scenes/new_game/ with UI layout
- [x] T021 [P] Create LeaderCreation.tscn in scenes/new_game/ with background selection UI
- [x] T022 [P] Create MediaInterview.tscn in scenes/new_game/ with question/answer UI

**Scene Scripts** (depend on scene creation)
- [x] T023 Create NewGameFlow.gd in scripts/new_game/ implementing flow control and scene transitions
- [x] T024 Create PartySelection.gd with party browsing and custom creation logic
- [x] T025 Create LeaderCreation.gd with background selection and leader creation
- [x] T026 Create MediaInterview.gd with question presentation and answer handling

## Phase 3.5: UI Components
- [ ] T027 [P] Create PartyCard component scene in scenes/ui/components/PartyCard.tscn
- [ ] T028 [P] Create BackgroundCard component in scenes/ui/components/BackgroundCard.tscn
- [ ] T029 [P] Create PolicyKeywordSelector in scenes/ui/components/PolicyKeywordSelector.tscn
- [ ] T030 Create UI theme resource in scenes/ui/theme.tres for consistent styling

## Phase 3.6: Integration & Signal Connections
- [ ] T031 Connect signals between NewGameFlow and child scenes (party_selected, leader_created, etc.)
- [ ] T032 Wire up GameSetupState to persist data across scene changes
- [ ] T033 Implement back navigation functionality across all scenes
- [ ] T034 Add save/load functionality using ConfigFile for game state persistence

## Phase 3.7: Testing
- [ ] T035 [P] Create unit tests for Party model in tests/unit/test_party.gd
- [ ] T036 [P] Create unit tests for PartyGenerator in tests/unit/test_party_generator.gd
- [ ] T037 [P] Create integration test for full setup flow in tests/integration/test_setup_flow.gd
- [ ] T038 Create validation test suite following quickstart.md scenarios

## Phase 3.8: Polish & Validation
- [ ] T039 Add tooltips and help text for political terms throughout UI
- [ ] T040 [P] Implement profanity filter for custom party names
- [ ] T041 [P] Add Dutch political context to party generation templates
- [ ] T042 Performance optimization: ensure 60 FPS and <3 sec scene loads
- [ ] T043 Accessibility pass: UI scaling, keyboard navigation, color-blind safe colors

## Phase 3.9: Additional Requirements & Quality
- [ ] T044 Create GDScript documentation templates with required comment headers for all non-trivial functions
- [ ] T045 [P] Create unit test for profanity filter validation in tests/unit/test_profanity_filter.gd
- [ ] T046 [P] Create unit test for duplicate party name prevention in tests/unit/test_party_validation.gd
- [ ] T047 Integrate new game setup with main menu scene - add "New Game" button connection

## Dependencies
- Setup (T001-T005) must complete first
- Models (T006-T011) can run in parallel after setup
- T012 (GameSetupState) blocks T032
- T013-T015 (Systems) can run in parallel after models
- T019-T022 (Scenes) can be created in parallel after setup
- T023-T026 (Scripts) depend on their respective scenes
- T031-T034 (Integration) require scenes and scripts complete
- Testing and polish can begin after integration

## Parallel Execution Examples
```bash
# After setup, launch all models in parallel:
Task: "Create Party resource class in scripts/models/Party.gd"
Task: "Create Leader resource class in scripts/models/Leader.gd"
Task: "Create LeaderBackground resource in scripts/models/LeaderBackground.gd"
Task: "Create PolicyKeyword resource in scripts/models/PolicyKeyword.gd"
Task: "Create MediaQuestion resource in scripts/models/MediaQuestion.gd"
Task: "Create MediaAnswer resource in scripts/models/MediaAnswer.gd"

# Create all scenes in parallel:
Task: "Create NewGameFlow.tscn in scenes/new_game/"
Task: "Create PartySelection.tscn in scenes/new_game/"
Task: "Create LeaderCreation.tscn in scenes/new_game/"
Task: "Create MediaInterview.tscn in scenes/new_game/"

# Run all unit tests in parallel:
Task: "Create unit tests for Party model"
Task: "Create unit tests for PartyGenerator"
```

## Notes
- [P] tasks = different files, no shared dependencies
- Godot Resources and Scenes are independent files
- Scene scripts depend on their scene files existing
- Signal connections require both endpoints to exist
- Use GUT framework conventions for test files
- Follow constitution requirements for code comments and Dutch political accuracy

## Validation Checklist
*GATE: Verified before execution*

- ✅ All 6 entities have model tasks (T006-T011)
- ✅ All 4 scenes have creation and script tasks
- ✅ Signal contracts covered in integration tasks (T031)
- ✅ Testing includes unit and integration tests (T035-T038, T045-T046)
- ✅ Parallel tasks are truly independent files
- ✅ Each task specifies exact file path
- ✅ No [P] task modifies same file as another [P] task
- ✅ Dutch political context included (T041)
- ✅ Accessibility requirements addressed (T043)
- ✅ Performance targets included (T042)
- ✅ Code documentation standards enforced (T044)
- ✅ Profanity filter tested (T045)
- ✅ Duplicate name prevention tested (T046)
- ✅ Main menu integration included (T047)