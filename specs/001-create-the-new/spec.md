# Feature Specification: New Game Setup - NederTiek

**Feature Branch**: `001-create-the-new`
**Created**: 2025-09-26
**Status**: Draft
**Input**: User description: "Create the new game setup for a Dutch political simulation game called NederTiek. The player should have two choices: either select from a list of about 20 dynamically generated fictional parties based on the current political situation, or create their own custom party by picking a name and several policy keywords. After choosing a party, the player must create their leader by selecting from 8 generated backgrounds, which sets their initial attributes. The process concludes with the leader's first media interview, where their answers to a few questions finalize their starting attributes, party treasury, and initial popularity."

## Execution Flow (main)
```
1. Parse user description from Input
   → If empty: ERROR "No feature description provided"
2. Extract key concepts from description
   → Identify: actors, actions, data, constraints
3. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION: specific question]
4. Fill User Scenarios & Testing section
   → If no clear user flow: ERROR "Cannot determine user scenarios"
5. Generate Functional Requirements
   → Each requirement must be testable
   → Mark ambiguous requirements
6. Identify Key Entities (if data involved)
7. Run Review Checklist
   → If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
   → If implementation details found: ERROR "Remove tech details"
8. Return: SUCCESS (spec ready for planning)
```

---

## Clarifications

### Session 2025-09-26
- Q: When a player creates a custom party, how many policy keywords should they select? → A: 5-10 keywords with mix requirements
- Q: How many questions should the media interview contain? → A: 4-6 questions based on party type + contextual
- Q: What should be the source for generating the ~20 fictional political parties? → A: Mix of historical and fictional patterns
- Q: What factors should determine the initial party treasury amount? → A: Background + party type + interview
- Q: When browsing generated parties, what information should be displayed for each party? → A: Name + description + full policies

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

### Section Requirements
- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

### For AI Generation
When creating this spec from a user prompt:
1. **Mark all ambiguities**: Use [NEEDS CLARIFICATION: specific question] for any assumption you'd need to make
2. **Don't guess**: If the prompt doesn't specify something (e.g., "login system" without auth method), mark it
3. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
4. **Common underspecified areas**:
   - User types and permissions
   - Data retention/deletion policies
   - Performance targets and scale
   - Error handling behaviors
   - Integration requirements
   - Security/compliance needs

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a new player starting NederTiek, I want to establish my political party and leader through a guided setup process that creates an engaging starting position for the game, with choices that meaningfully impact my initial gameplay experience.

### Acceptance Scenarios
1. **Given** a new game is started, **When** the player is presented with party selection, **Then** they can choose between browsing generated parties or creating a custom party
2. **Given** the player chooses to browse existing parties, **When** the list is displayed, **Then** 18-22 fictional parties are shown with name, description, and full policy positions
3. **Given** the player chooses to create a custom party, **When** entering party details, **Then** they can specify a party name and select 5-10 policy keywords with mix requirements from predefined categories
4. **Given** a party has been selected or created, **When** leader creation begins, **Then** the player is presented with exactly 8 different background options
5. **Given** a background is selected, **When** applied to the leader, **Then** initial attributes are set based on that background
6. **Given** the leader is created, **When** the media interview begins, **Then** the player answers 4-6 contextual questions based on their party type that affect final starting values

### Edge Cases
- What happens when the player tries to use an inappropriate party name?
- How does the system handle if the player exits during setup?
- What happens if the player wants to go back and change previous choices?
- How does the system ensure generated parties are sufficiently distinct from each other?
- What happens if the custom party name conflicts with a generated party name?

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST provide two party selection methods: browse generated parties OR create custom party
- **FR-002**: System MUST generate 18-22 fictional political parties based on a mix of historical Dutch political patterns and fictional variations
- **FR-003**: System MUST allow custom party creation with a user-specified name
- **FR-004**: System MUST allow selection of 5-10 policy keywords for custom parties from predefined categories with mix requirements (minimum 2 economic, 2 social, 1 other category) to ensure balanced political positioning
- **FR-005**: System MUST present exactly 8 different leader background options
- **FR-006**: System MUST assign initial leader attributes based on selected background
- **FR-007**: System MUST conduct a media interview with 4-6 contextual questions based on party type and policy positions
- **FR-008**: System MUST calculate final starting attributes based on interview answers
- **FR-009**: System MUST set initial party treasury (€10,000 - €1,000,000) based on combination of leader background, party type, and interview answers
- **FR-010**: System MUST determine initial popularity rating (5% - 25%) based on setup choices
- **FR-011**: System MUST ensure all generated party names are appropriate for PEGI 3/E for Everyone rating
- **FR-012**: System MUST prevent duplicate party names within the same game
- **FR-013**: System MUST save the completed setup configuration for game start
- **FR-014**: Generated parties MUST reflect Dutch political context and naming conventions
- **FR-015**: System MUST display party name, description, and full policy positions when browsing generated parties
- **FR-016**: System MUST allow player to navigate back to previous setup steps before final confirmation

### Key Entities *(include if feature involves data)*
- **Party**: Represents a political organization with name, policy positions, treasury, and popularity rating
- **Leader**: Represents the player character with background, attributes, and relationship to their party
- **LeaderBackground**: Predefined profile that determines initial leader attributes and capabilities
- **PolicyKeyword**: Tags or categories that define a party's political positions and priorities
- **MediaQuestion**: Interview questions contextual to party type and policies
- **MediaAnswer**: Possible responses to interview questions with impact on attributes
- **GameSetupState**: Complete configuration from new game setup including party, leader, and initial values

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed

---