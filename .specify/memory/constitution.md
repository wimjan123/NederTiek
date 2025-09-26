<!--
Sync Impact Report:
Version change: [undefined] → 1.0.0
Modified principles: New constitution created with 6 core principles
Added sections: Core Principles, Technical Standards, Development Workflow, Governance
Templates requiring updates:
  ✅ Updated (no other templates present yet)
Follow-up TODOs: None
-->

# NederTiek Constitution

## Core Principles

### I. Simulation Realism
Voter behavior and party AI must realistically model Dutch political dynamics. All electoral mechanics, coalition negotiations, and political events must reflect authentic patterns from Dutch democracy. Political actors must respond to player actions with plausible behavioral models grounded in political science research. Every simplification for gameplay must explicitly justify how it preserves the essential dynamics of Dutch parliamentary democracy.

### II. Deep Strategic Gameplay
Meaningful strategic choices must drive the core experience over visual complexity. Campaign strategies, media manipulation, coalition building, and policy positioning form the primary interaction layer. Every system must present clear trade-offs with long-term consequences. Emergent narratives and political crises must arise naturally from player decisions rather than scripted events. Complexity belongs in decision trees, not in UI interactions or graphical presentations.

### III. Accessible User Interface
The game interface must remain intuitive and immediately understandable for political novices. Visual feedback for political influence, voter sentiment, and party relationships must use clear iconography and consistent color coding. All critical information must be accessible within two clicks from the main screen. Tooltips and contextual help must explain political concepts without breaking immersion. The UI must scale gracefully from mobile to desktop resolutions while maintaining readability.

### IV. Modular Design in Godot
Core systems (voting, media, economy, demographics) must be built as independent, loosely-coupled modules. Each module must expose a clear API for inter-module communication. Module dependencies must be explicitly declared and minimized. Systems must be testable in isolation with mock interfaces. Scene organization must follow a consistent hierarchy: Main → System Controllers → UI Overlays. Resource loading and state management must be centralized through dedicated manager nodes.

### V. Beginner-Friendly Code
All GDScript must be extensively commented with clear explanations of logic and political mechanics. Variable and function names must be descriptive and avoid abbreviations (use `voter_satisfaction` not `v_sat`). Complex algorithms must include step-by-step documentation with examples. Design patterns must be explicitly noted and explained when used. Code organization must follow a consistent structure with clear separation between data, logic, and presentation layers. Every non-trivial function must include a header comment explaining purpose, parameters, and return values.

### VI. Up-to-Date Knowledge
Technical implementation must use current Godot 4.x best practices and features. When implementing Godot functionality, Context7 MCP must be consulted FIRST for official documentation. Only if Context7 lacks the required information should general web search be used as fallback. All external political data sources must be verified for currency and accuracy. Dutch political system changes (electoral reforms, party mergers) must be reflected in design documents. Dependencies and third-party assets must be actively maintained versions only.

## Technical Standards

### Technology Stack
- **Engine**: Godot 4.x (latest stable)
- **Primary Language**: GDScript for all gameplay code
- **Data Format**: JSON for configuration, save games, and scenario definitions
- **Version Control**: Git with semantic versioning for releases
- **Architecture**: MVC pattern with clear separation of concerns

### Performance Requirements
- **Target FPS**: 60fps on mid-range hardware (integrated graphics)
- **Load Times**: Under 3 seconds for scene transitions
- **Save/Load**: Under 1 second for game state serialization
- **Memory**: Under 2GB RAM usage at peak
- **Battery Life**: Optimized for laptop/mobile with power-saving modes

### Accessibility Standards
- **Font Scaling**: 75% to 150% UI scale support
- **Color Blindness**: Deuteranopia and Protanopia safe palettes
- **Input Methods**: Full keyboard navigation alongside mouse/touch
- **Screen Readers**: Semantic UI structure for assistive technology

## Development Workflow

### Code Review Requirements
- All merge requests must include play-tested scenarios demonstrating feature
- Political mechanics changes require justification with real-world examples
- Performance impact must be measured for systems touching the simulation loop
- UI changes must include screenshots at multiple resolutions
- Breaking changes to module APIs require migration documentation

### Testing Gates
- Unit tests required for all political calculation functions
- Integration tests for inter-module communication
- Scenario tests validating realistic political outcomes
- UI automation tests for critical user journeys
- Performance benchmarks for simulation-heavy operations

### Documentation Standards
- Every module must maintain a README with API documentation
- Political mechanics must be documented in design docs with sources
- Complex algorithms require accompanying flowcharts or diagrams
- Godot scene structures must be documented with node responsibility maps
- Localization keys must include context notes for translators

## Governance

### Amendment Process
Constitution amendments require:
1. Documented rationale with impact analysis
2. Review by project maintainer
3. Migration plan for existing code/assets
4. Update to all dependent documentation

### Compliance Verification
- All pull requests must verify constitutional compliance in description
- Automated linting enforces code style principles
- Module boundary violations block merge
- Performance regression tests prevent degradation
- Documentation coverage tracked and enforced at 80% minimum

### Versioning Policy
- MAJOR: Breaking changes to save compatibility or core mechanics
- MINOR: New features, campaigns, or significant content additions
- PATCH: Bug fixes, balance tweaks, localization updates

The constitution supersedes all other project guidelines. In case of conflicts, constitutional principles take precedence. Runtime development follows the active Godot style guide where not explicitly overridden here.

**Version**: 1.0.0 | **Ratified**: 2025-09-26 | **Last Amended**: 2025-09-26