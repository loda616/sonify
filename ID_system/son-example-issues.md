# SON ID System: Example Issue Register

Below is an example issue register using the SON ID system for the Sonify application. This demonstrates how the system would be applied to track various tasks, bugs, features, and enhancements across different components of the application.

## Active Issues

| SON ID | Type | Priority | Component | Description | Status | Assigned To |
|--------|------|----------|-----------|-------------|--------|-------------|
| SON-B1-TS001 | Bug | Critical | Text-to-Speech | App crashes when processing text with emoji | In Progress | Sarah Chen |
| SON-F2-AP002 | Feature | High | Audio Player | Add speed control for audio playback | To Do | Michael Rodriguez |
| SON-T3-UI003 | Task | Medium | User Interface | Improve accessibility of dark mode toggle | In Review | Jamie Taylor |
| SON-E4-ST004 | Enhancement | Low | Storage | Optimize audio file storage format | To Do | Alex Johnson |
| SON-B1-TS005 | Bug | Critical | Text-to-Speech | Voice selection not persisting after app restart | In Progress | Sarah Chen |
| SON-F3-BE006 | Feature | Medium | Backend | Implement cloud backup for saved audio files | To Do | Unassigned |
| SON-I2-UI007 | Issue | High | User Interface | Text input field not resizing properly on keyboard show | To Do | Jamie Taylor |
| SON-T2-TH008 | Task | High | Theming | Implement custom color schemes for user themes | In Progress | Devon Lee |

## Recently Completed Issues

| SON ID | Type | Priority | Component | Description | Completed Date | Completed By |
|--------|------|----------|-----------|-------------|----------------|--------------|
| SON-B1-AP001 | Bug | Critical | Audio Player | Audio playback freezes after 30 seconds | 2025-03-15 | Michael Rodriguez |
| SON-F2-TS002 | Feature | High | Text-to-Speech | Add male voice option | 2025-03-10 | Sarah Chen |
| SON-E3-UI003 | Enhancement | Medium | User Interface | Animate transitions between screens | 2025-03-08 | Jamie Taylor |
| SON-T4-DB004 | Task | Low | Database | Update metadata structure for audio files | 2025-03-05 | Alex Johnson |

## Example Issue Details

### SON-B1-TS001: App crashes when processing text with emoji

**Description:**  
When a user enters text containing emoji characters into the text input field and attempts to generate speech, the application crashes immediately with a null pointer exception in the TTS engine.

**Steps to Reproduce:**
1. Open the Text-to-Speech screen
2. Enter text containing emoji (e.g., "Hello 😊")
3. Press the "Generate Speech" button
4. Observe app crash

**Technical Details:**  
The crash occurs in `tts_service.dart` in the `generateSpeech` method when attempting to process the emoji character. The underlying Flutter TTS plugin does not handle Unicode characters outside a certain range.

**Proposed Solution:**  
1. Add a text sanitization method to filter out or replace emoji characters before passing to the TTS engine
2. Add error handling to prevent crashes when unexpected characters are encountered
3. Add unit tests to verify handling of various character types

**Commits:**
```
SON-B1-TS001: Added character filtering for TTS input
SON-B1-TS001: Implemented error handling for invalid characters
SON-B1-TS001: Added unit tests for emoji handling
```

**Related Issues:**  
SON-B1-TS005 (Voice selection not persisting)

### SON-F2-AP002: Add speed control for audio playback

**Description:**  
Add functionality to control the playback speed of audio files in the audio player widget. Users should be able to adjust speed from 0.5x to 2.0x.

**Requirements:**
1. Add a speed control slider to the AudioPlayerWidget
2. Implement playback speed adjustment in the audio player
3. Persist speed settings between playback sessions
4. Update UI to display current speed setting

**Technical Approach:**  
Extend the JustAudio plugin implementation in the AudioPlayerWidget to support playback speed adjustment. Add a new slider component and connect it to the speed control API.

**UI Design Notes:**  
Speed control should be accessible but not dominate the player interface. Consider a collapsible control or inclusion in an "advanced options" section.

**Affected Files:**
- audio_player_widget.dart
- settings_screen.dart (for default speed preferences)

**Assigned To:** Michael Rodriguez  
**Target Completion:** 2025-03-25

## Status Summary

**Total Issues:** 12  
**By Type:**
- Bugs: 3
- Features: 3
- Tasks: 3
- Enhancements: 2
- Issues: 1

**By Priority:**
- Critical (1): 3
- High (2): 4
- Medium (3): 3
- Low (4): 2

**By Status:**
- To Do: 4
- In Progress: 3
- In Review: 1
- Completed: 4
