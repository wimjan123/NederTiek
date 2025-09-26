
# Implementation Plan: New Game Setup - NederTiek

**Branch**: `001-create-the-new` | **Date**: 2025-09-26 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-create-the-new/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Implement the new game setup flow for NederTiek, a Dutch political simulation game. Players select or create a political party (from ~20 generated options or custom), choose a leader background (from 8 options), and complete a media interview (4-6 contextual questions) to determine starting attributes, treasury, and popularity. Built with Godot 4.x and GDScript following the node-based architecture.

## Technical Context
**Language/Version**: GDScript (Godot 4.x latest stable)
**Primary Dependencies**: Godot Engine 4.x native UI system, node-based architecture
**Storage**: JSON files for save games, party data, and configuration
**Testing**: GUT (Godot Unit Testing) framework for unit and integration tests
**Target Platform**: Standalone 2D desktop application (Windows/Mac/Linux)
**Project Type**: single (Godot project structure)
**Performance Goals**: 60 FPS on integrated graphics, smooth UI transitions
**Constraints**: <3 sec scene load, <2GB RAM usage, <1 sec save/load operations
**Scale/Scope**: 18-22 parties, 8 backgrounds, 5-10 policy categories, Dutch political context

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Core Principles Compliance:**
- ✅ **Simulation Realism**: Party generation based on Dutch political patterns
- ✅ **Deep Strategic Gameplay**: Player choices impact starting position meaningfully
- ✅ **Accessible UI**: Clear party selection, intuitive flow, tooltips for political terms
- ✅ **Modular Design**: Setup module independent from main game systems
- ✅ **Beginner-Friendly Code**: Extensive comments, descriptive naming planned
- ✅ **Up-to-Date Knowledge**: Using Godot 4.x, Context7 for documentation

**Technical Standards:**
- ✅ **Engine**: Godot 4.x confirmed
- ✅ **Language**: GDScript for all code
- ✅ **Data Format**: JSON for party/leader configuration
- ✅ **Performance**: Target 60fps, <3 sec loads
- ✅ **Accessibility**: UI scaling, color-blind safe planned

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
project.godot              # Godot project configuration

scenes/
├── new_game/             # New game setup scenes
│   ├── NewGameFlow.tscn  # Main setup orchestrator scene
│   ├── PartySelection.tscn
│   ├── LeaderCreation.tscn
│   └── MediaInterview.tscn
└── ui/
    └── components/       # Reusable UI components

scripts/
├── new_game/            # New game setup scripts
│   ├── NewGameFlow.gd   # Main flow controller
│   ├── PartySelection.gd
│   ├── LeaderCreation.gd
│   └── MediaInterview.gd
├── models/              # Data models
│   ├── Party.gd
│   ├── Leader.gd
│   ├── LeaderBackground.gd
│   ├── PolicyKeyword.gd
│   ├── MediaQuestion.gd
│   └── MediaAnswer.gd
└── systems/             # Core game systems
    ├── GameSetupState.gd
    ├── PartyGenerator.gd
    ├── SetupDataManager.gd
    └── QuestionSelector.gd

data/
├── parties/            # Party configuration JSONs
├── backgrounds/        # Leader backgrounds
└── questions/          # Interview question pools

tests/
├── unit/              # GUT unit tests
└── integration/       # Full flow tests
```

**Structure Decision**: Using Godot's standard project structure with scenes and scripts separated. The new game setup is a self-contained module under scenes/new_game/ and scripts/new_game/. Data files in JSON format stored in data/ directory for easy modification and localization.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - ✅ Resolved: Godot architecture patterns
   - ✅ Resolved: Dutch political context
   - ✅ Resolved: UI/UX flow management
   - ✅ Resolved: Data persistence approach

2. **Research completed**:
   - Godot 4.x best practices for scene management
   - Signal-based communication patterns
   - Resource classes for data models
   - ConfigFile vs JSON for different data types
   - Dutch political party structures and naming

3. **Findings consolidated** in `research.md`:
   - Scene architecture decision
   - Data persistence strategy
   - State management approach
   - UI framework selection

**Output**: ✅ research.md created with all clarifications resolved

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Entities extracted** → `data-model.md`:
   - ✅ Party (with ideology scores, policies)
   - ✅ Leader (with attributes, treasury, popularity)
   - ✅ LeaderBackground (8 types defined)
   - ✅ PolicyKeyword (categories and conflicts)
   - ✅ MediaQuestion/Answer (contextual system)
   - ✅ GameSetupState (flow management)

2. **Signal contracts defined** (Godot-specific):
   - ✅ PartySelection signals
   - ✅ LeaderCreation signals
   - ✅ MediaInterview signals
   - ✅ GameSetupState orchestration
   - ✅ Output to `/contracts/game_setup_signals.md`

3. **Method contracts specified**:
   - ✅ PartyGenerator system
   - ✅ SetupDataManager calculations
   - ✅ QuestionSelector logic

4. **Test scenarios extracted** → `quickstart.md`:
   - ✅ Full flow walkthrough
   - ✅ Edge case testing
   - ✅ Performance verification
   - ✅ Accessibility checks

5. **Agent file updated**:
   - ✅ Ran update-agent-context.sh for Claude
   - ✅ Added Godot/GDScript context
   - ✅ Created CLAUDE.md

**Output**: ✅ All Phase 1 artifacts generated

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Core Godot project setup tasks
- Each entity (6) → Resource class creation task [P]
- Each scene (4) → Scene creation and script task [P]
- Signal contract implementation tasks
- Party generation system implementation
- Interview question system implementation
- Integration test scenarios from quickstart

**Ordering Strategy**:
1. Project setup and structure creation
2. Data models (Resources) - can be parallel [P]
3. Core systems (PartyGenerator, QuestionSelector) [P]
4. UI scenes and controllers in flow order
5. Signal connections and flow management
6. Integration testing following quickstart scenarios
7. Performance and accessibility validation

**Task Categories**:
- Setup: Godot project configuration (2-3 tasks)
- Models: Resource classes for entities (6 tasks) [P]
- Systems: Core game systems (3-4 tasks) [P]
- UI: Scene creation and scripts (8-10 tasks)
- Integration: Connect everything (3-4 tasks)
- Testing: Unit and integration tests (5-6 tasks)
- Validation: Performance and accessibility (2-3 tasks)

**Estimated Output**: 47 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command)
- [x] Phase 1: Design complete (/plan command)
- [x] Phase 2: Task planning complete (/plan command - describe approach only)
- [x] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (none needed)

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
