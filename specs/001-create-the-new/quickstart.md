# Quickstart Guide: New Game Setup Implementation

## Quick Verification Steps

After implementing the new game setup feature, verify it works by following these steps:

### 1. Launch Game & Start New Game
1. Run the project in Godot
2. Click "New Game" from the main menu
3. **Expected**: Party selection screen appears with two options

### 2. Test Party Selection - Browse Generated Parties
1. Choose "Select from Existing Parties"
2. **Expected**: List of ~20 parties appears with:
   - Party names and abbreviations
   - Full descriptions
   - Policy positions displayed
   - Color-coded party identities
3. Scroll through the list
4. Click on any party to see details
5. Select "VVD" (or any party)
6. Click "Continue with this Party"
7. **Expected**: Proceeds to leader creation

### 3. Test Party Selection - Create Custom Party
1. Return to party selection (use Back button)
2. Choose "Create Custom Party"
3. Enter party name: "Test Partij"
4. Enter abbreviation: "TP"
5. Select exactly 7 policy keywords across categories:
   - 2 Economic policies
   - 2 Social policies
   - 2 Environmental policies
   - 1 EU policy
6. Click "Create Party"
7. **Expected**: Validation passes, party created
8. **Expected**: Proceeds to leader creation

### 4. Test Leader Creation
1. View all 8 background options
2. **Expected** backgrounds:
   - Career Politician
   - Business Executive
   - Academic/Professor
   - Activist/NGO Leader
   - Media Personality
   - Local Administrator
   - Union Leader
   - Military/Security Background
3. Select "Business Executive"
4. **Expected**: Shows attribute preview
5. Enter first name: "Jan"
6. Enter last name: "de Vries"
7. Click "Create Leader"
8. **Expected**: Proceeds to media interview

### 5. Test Media Interview
1. **Expected**: 4-6 contextual questions appear
2. First question should relate to your party type
3. Answer all questions by selecting options
4. **Expected**: Each answer shows impact preview
5. Complete all questions
6. Click "Finish Interview"
7. **Expected**: Shows summary screen with:
   - Final leader attributes
   - Starting treasury amount (€10,000 - €1,000,000)
   - Initial popularity (5% - 25%)

### 6. Test Navigation
1. From summary, click "Back" repeatedly
2. **Expected**: Can navigate back through:
   - Interview → Leader → Party
3. Make different choices
4. Proceed forward again
5. **Expected**: Previous choices are remembered

### 7. Test Edge Cases

#### Invalid Party Name
1. Go to custom party creation
2. Try party name: "X" (too short)
3. **Expected**: Validation error
4. Try party name with 51+ characters
5. **Expected**: Validation error

#### Insufficient Keywords
1. Select only 3 policy keywords
2. Try to continue
3. **Expected**: Error message about minimum 5 keywords

#### Conflicting Keywords
1. Select "Free Market Economy" and "Planned Economy"
2. **Expected**: Warning about conflicting positions

### 8. Test Save & Load
1. Complete full setup
2. Click "Start Game"
3. **Expected**: Game starts with your configuration
4. Check save file exists in `user://save_games/`
5. Quit and restart
6. Load save
7. **Expected**: Party and leader data preserved

## Performance Verification

Run these checks to ensure performance requirements are met:

1. **Scene Load Time**: Each scene transition < 3 seconds
2. **FPS Check**: Maintain 60 FPS during all interactions
3. **Memory Usage**: Check debugger, should be < 500MB during setup
4. **Save Time**: Complete save operation < 1 second

## Accessibility Verification

1. **UI Scaling**:
   - Set UI scale to 75% - works correctly
   - Set UI scale to 150% - text remains readable

2. **Keyboard Navigation**:
   - Tab through all options
   - Enter to select
   - Escape to go back

3. **Color Blindness**:
   - Enable deuteranopia mode
   - All party colors still distinguishable

## Console Commands for Testing

```gdscript
# In Godot console during runtime:

# Force regenerate parties
PartyGenerator.generate_parties(30)

# Test with specific ideology
var test_party = Party.new()
test_party.ideology_scores["economic_left_right"] = -1.0
GameSetupState.selected_party = test_party

# Skip to interview
get_tree().change_scene_to_file("res://scenes/new_game/MediaInterview.tscn")

# Set extreme attributes
GameSetupState.leader.attributes["charisma"] = 100
GameSetupState.leader.attributes["integrity"] = 0

# Test save system
GameSetupState.compile_game_start_data()
SaveManager.save_game("test_save")
```

## Validation Checklist

- [ ] All 20 generated parties have unique names
- [ ] Party descriptions are 2-3 sentences
- [ ] Each party has 5-10 policy keywords
- [ ] All 8 backgrounds available and selectable
- [ ] Interview has 4-6 contextual questions
- [ ] Treasury calculated correctly (€10k - €1M range)
- [ ] Popularity calculated correctly (0-100% range)
- [ ] Back navigation works from any screen
- [ ] All text displays correctly (no overflow)
- [ ] No memory leaks after multiple setup runs
- [ ] Save files can be loaded successfully
- [ ] Profanity filter blocks inappropriate names
- [ ] Dutch political context reflected in parties
- [ ] Color contrast sufficient for readability
- [ ] All tooltips display helpful information

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Parties not generating | Check `data/parties/templates.json` exists |
| Interview questions missing | Verify `data/questions/pool.json` loaded |
| Attributes not calculating | Check `LeaderBackground` modifiers |
| Save fails | Ensure write permissions for `user://` |
| Back button broken | Verify signal connections in scene |
| Memory leak | Check scenes are freed properly |

## Success Criteria

The feature is complete when:
1. Full flow works end-to-end without errors
2. All validation rules are enforced
3. Performance targets are met
4. Save/load functionality works
5. All 16 functional requirements (FR-001 to FR-016) pass