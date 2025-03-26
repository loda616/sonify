# SON: Sonify Object Notation ID System

## Overview

The SON ID system provides a structured approach to creating identifiers for tasks and issues in project management. This system enables quick identification of item type, priority, area of focus, and chronology through a compact, human-readable format.

## ID Structure

Each SON ID follows this pattern:

```
SON-[TYPE][PRIORITY]-[AREA][NUMBER]
```

### Components

1. **Prefix**: Always "SON-" to identify the Sonify system
2. **Type**: Single letter identifying the item type
   - T: Task
   - I: Issue
   - B: Bug
   - F: Feature
   - E: Enhancement
3. **Priority**: Single digit priority level
   - 1: Critical
   - 2: High
   - 3: Medium
   - 4: Low
   - 5: Trivial
4. **Area**: Two-letter code denoting the area of the system
   - UI: User Interface
   - BE: Backend
   - DB: Database
   - TS: Text-to-Speech
   - TH: Theming
   - AP: Audio Player
   - ST: Storage
   - SY: System-wide
5. **Number**: Sequential number (padded to 3 digits) for chronological tracking

## Examples

- `SON-T1-UI001`: Critical task related to User Interface, first in sequence
- `SON-I3-TS042`: Medium priority issue with Text-to-Speech functionality, 42nd in sequence
- `SON-B2-AP007`: High priority bug in the Audio Player component, 7th in sequence
- `SON-F4-DB015`: Low priority feature request for Database, 15th in sequence

## Benefits

- **Quick Recognition**: Type and priority are immediately visible
- **Sortable**: Alphabetical sorting groups items by type, priority, and area
- **Contextual**: Area codes provide immediate context about the affected system component
- **Traceable**: Sequential numbering allows for chronological tracking
- **Compact**: Efficiently encodes multiple dimensions of information in a short string

## Implementation Guidelines

1. Maintain a central register of assigned IDs to prevent duplicates
2. Generate IDs sequentially within each area category
3. Include the SON ID in all communications regarding the task or issue
4. Use the ID as a reference in commit messages and documentation

## Integration with Version Control

When committing changes related to a specific SON ID, include the ID at the beginning of the commit message:

```
SON-B2-AP007: Fixed audio player crashing when seeking past end of file
```

This practice enables easy tracing between code changes and the issues they address.
