# Sonify: Complete Implementation Plan

## Master Overview

This plan transforms Sonify from an incomplete prototype into a polished, production-ready TTS application. It is organized into 4 sequential phases, each with clear deliverables and a definition of done.

---

## Current State Assessment

### What Works
- Basic text-to-speech using device TTS (`flutter_tts`)
- Audio playback via `just_audio`
- Save/load/delete audio files with JSON metadata
- Export and share audio files
- Dark/light theme with persistence
- Splash screen with animation

### What's Broken or Incomplete
- **28 out of 41 Dart files are empty (0 bytes)** — the clean architecture scaffolding was created but never filled in
- Voice quality is low (device TTS sounds robotic)
- No error handling infrastructure (`exceptions.dart`, `failures.dart` are empty)
- No loading states for first-time model initialization
- No text character limit or validation
- Sound wave animation widget is empty
- File utilities class is empty
- App still uses `com.example.sonify` package name
- No app icon (uses Flutter default)
- Splash screen hardcodes 4-second delay (should wait for actual initialization)
- Different fonts for light/dark themes (Inter vs Manrope) — inconsistent
- No onboarding or first-launch experience
- Settings only has theme toggle and storage management

### Architecture Issues
- All business logic lives in a single `TTSService` singleton (250+ lines)
- Presentation layer directly depends on service layer (no repository abstraction)
- Directory typos: `presentaiont`, `domin`
- No dependency injection — everything is `TTSService()` singleton
- ThemeProvider duplicates logic that should be in the clean architecture files

---

## Phase Overview

| Phase | Name | Focus | Est. Effort |
|-------|------|-------|-------------|
| **1** | Architecture & Foundation | Fix structure, fill empty files, set up DI, error handling | 2-3 days |
| **2** | TTS Engine Integration | Replace flutter_tts with Piper via sherpa_onnx | 2-3 days |
| **3** | UI/UX Polish | Loading states, animations, onboarding, voice picker | 2-3 days |
| **4** | Production Readiness | App identity, testing, performance, release prep | 1-2 days |

**Total estimated effort: 7-11 days**

---

## File Plan

### Files to CREATE (new)
```
lib/services/tts_engine.dart              — sherpa-onnx Piper wrapper
lib/services/audio_storage_service.dart   — Extracted from TTSService
lib/core/di/service_locator.dart          — GetIt dependency injection
lib/core/errors/exceptions.dart           — Custom exception types
lib/core/errors/failures.dart             — Failure classes for Either pattern
lib/core/utils/file_utils.dart            — File path & format helpers
lib/core/widgets/sound_wave_animation.dart — Animated waveform widget
lib/core/widgets/loading_overlay.dart     — Reusable loading indicator
lib/features/text_to_speech/domain/*      — 4 files (entities, repos, usecases)
lib/features/text_to_speech/data/*        — 3 files (datasource, models, repo)
lib/features/text_to_speech/presentation/providers/tts_provider.dart
lib/features/saved_audios/domain/*        — 3 files (repos, usecases)
lib/features/saved_audios/data/*          — 3 files (datasource, models, repo)
lib/features/settings/domain/*            — 3 files (repos, usecases)
lib/features/settings/data/*              — 2 files (datasource, repo)
lib/features/theme/domain/*               — 3 files
lib/features/theme/data/*                 — 3 files
lib/features/onboarding/                  — First-launch experience
```

### Files to MODIFY (existing)
```
pubspec.yaml                              — Dependencies swap
lib/main.dart                             — Add DI initialization
lib/app/splash_screen.dart                — Real init instead of Timer
lib/app/home_screen.dart                  — Minor updates
lib/services/tts_service.dart             — Rewrite as facade
lib/core/constants/constants.dart         — Remove obsolete, add new
lib/core/themes/theme_config.dart         — Consistent fonts
lib/features/text_to_speech/presentation/ — UI updates
lib/features/settings/presentation/       — Add voice/model settings
android/app/build.gradle.kts             — minSdk, applicationId
```

### Files to DELETE
```
(none — all empty files get filled, not deleted)
```

### Files to RENAME (fix typos)
```
lib/features/text_to_speech/presentaiont/ → presentation/
lib/features/theme/domin/                 → domain/
```

---

## Detailed Plans

Each phase has its own document with file-by-file instructions:

| Document | Contents |
|----------|----------|
| [01-PHASE-1-ARCHITECTURE.md](./01-PHASE-1-ARCHITECTURE.md) | Fix structure, DI setup, error handling, fill domain/data layers |
| [02-PHASE-2-TTS-ENGINE.md](./02-PHASE-2-TTS-ENGINE.md) | Piper integration, model management, audio pipeline |
| [03-PHASE-3-UI-UX.md](./03-PHASE-3-UI-UX.md) | Loading states, voice picker, onboarding, animations |
| [04-PHASE-4-PRODUCTION.md](./04-PHASE-4-PRODUCTION.md) | App identity, testing, performance, release prep |
