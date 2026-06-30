# Sonify AI Models & TTS Engines Notes

This document provides a detailed overview of the text-to-speech (TTS) engines and AI models configured, implemented, or planned within the Sonify application.

---

## Overview of TTS Engines / AI Models

| Engine / Model | Status | Package / Library | Description |
| :--- | :--- | :--- | :--- |
| **System Native TTS** | **ACTIVE** (Currently Used) | `flutter_tts` | Uses the host operating system's built-in text-to-speech engine. |
| **TensorFlow Lite (TFLite)** | **INACTIVE** (Placeholder Only) | `tflite_flutter` | References a `.tflite` model in code configuration, but is not implemented. |
| **Piper TTS (via Sherpa-ONNX)** | **INACTIVE / PLANNED** (Phase 2) | `sherpa_onnx` | High-quality local neural TTS planned to replace `flutter_tts`. |

---

## 1. System Native TTS Engine

### Status: **ACTIVE (Currently Used)**
The application currently uses the native text-to-speech engine provided by the device's operating system. This is implemented in [tts_service.dart](file:///d:/My_Projects/sonify/lib/services/tts_service.dart) using the `flutter_tts` library.

### Implementation Details
* **File Location**: [tts_service.dart](file:///d:/My_Projects/sonify/lib/services/tts_service.dart)
* **Configuration**: Sets language (e.g., `en-US`), speech rate, pitch, and attempts to load native voices.
* **Mechanism**:
  - **Android**: Connects to the Android `TextToSpeech` API, which typically uses *Google Speech Services* or a device-specific alternative (e.g., Samsung TTS).
  - **iOS/macOS**: Connects to Apple's `AVSpeechSynthesizer` (using system voices like Samantha, Siri voices, etc.).
  - **Web**: Uses the browser's native `SpeechSynthesis` Web API.

### Pros & Cons
* **Pros**:
  - Extremely lightweight (no large files bundled with the app).
  - High performance and very low memory usage.
  - Multi-language support comes pre-installed on most modern devices.
* **Cons**:
  - Voice quality is highly variable and often sounds robotic or artificial.
  - Output differs between devices, meaning users will get a completely different UX depending on their phone model.

### Sources & Documentation
* [flutter_tts on Pub.dev](https://pub.dev/packages/flutter_tts)
* [flutter_tts Source Code on GitHub](https://github.com/dlutton/flutter_tts)
* [Android TextToSpeech API Reference](https://developer.android.com/reference/android/speech/tts/TextToSpeech)
* [Apple AVSpeechSynthesizer Class Reference](https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer)

---

## 2. TensorFlow Lite (TFLite) TTS Engine

### Status: **INACTIVE (Scaffolding / Placeholder Only)**
The codebase contains legacy scaffolding pointing towards a TensorFlow Lite configuration, but it is not currently implemented or used.

### Implementation Details
* **File Location**: [constants.dart](file:///d:/My_Projects/sonify/lib/core/constants/constants.dart#L25) defines `static const String modelName = 'tts_model.tflite';`.
* **Dependency**: [pubspec.yaml](file:///d:/My_Projects/sonify/pubspec.yaml#L24) includes the package `tflite_flutter: ^0.11.0`.
* **Current State**:
  - There is **no actual `.tflite` model file** anywhere in the project assets.
  - The `tflite_flutter` package is **never imported or invoked** in any of the Dart files.

### Pros & Cons
* **Pros**:
  - Custom deep neural network architectures (like FastSpeech2) can be optimized for mobile deployment.
* **Cons**:
  - High complexity: Implementing a TTS pipeline with TFLite in Flutter requires manual text tokenization, phoneme conversion, mel-spectrogram prediction, and a vocoder model (like MelGAN) to generate actual audio waveforms.

### Sources & Documentation
* [tflite_flutter on Pub.dev](https://pub.dev/packages/tflite_flutter)
* [TensorFlow Lite Official Website](https://www.tensorflow.org/lite)
* [TensorFlow Text-to-Speech (TensorFlowTTS) Repository](https://github.com/TensorSpeech/TensorFlowTTS) (Common reference for running TFLite TTS)

---

## 3. Piper TTS Engine (via Sherpa-ONNX)

### Status: **INACTIVE / PLANNED (Future Integration)**
The project documentation outlines a concrete plan in [02PHASE2TTSENGINE.md](file:///d:/My_Projects/sonify/docs/02PHASE2TTSENGINE.md) to integrate **Piper TTS** using the **Sherpa-ONNX** framework to achieve high-quality, local, offline voice generation.

### Current State & Scaffolding
* **Asset Folder**: [assets/tts-model/vits-piper-en_US-ryan-medium/](file:///d:/My_Projects/sonify/assets/tts-model/vits-piper-en_US-ryan-medium/) has been created and contains:
  - `tokens.txt` (a mapping vocabulary for text-to-phoneme-index).
  - `espeak-ng-data/` (linguistic phonemization files).
* **Missing Elements**:
  - The actual `.onnx` and `.onnx.json` model files (e.g., `en_US-ryan-medium.onnx`) are **missing** from this folder.
  - The `sherpa_onnx` dependency is **not yet added** to [pubspec.yaml](file:///d:/My_Projects/sonify/pubspec.yaml).
  - The engine class (`TtsEngine`) proposed in [02PHASE2TTSENGINE.md](file:///d:/My_Projects/sonify/docs/02PHASE2TTSENGINE.md) is **not yet written**.

### Pros & Cons
* **Pros**:
  - Natural-sounding, human-like voice synthesis (state-of-the-art VITS architecture).
  - Fully local, offline, and private.
  - Custom voice selection (Piper has hundreds of open-source voices).
* **Cons**:
  - Heavy asset footprint (each voice model adds 60MB - 100MB+ to the app size).
  - Copying assets from the assets bundle to the device storage during first launch takes 3-10 seconds.
  - Higher CPU and memory usage during speech generation.

### Sources & Documentation
* [Piper TTS Official Repository on GitHub](https://github.com/rhasspy/piper)
* [Sherpa-ONNX Repository on GitHub](https://github.com/k2-fsa/sherpa-onnx)
* [sherpa-onnx on Pub.dev](https://pub.dev/packages/sherpa_onnx)
* [VITS Research Paper (arXiv)](https://arxiv.org/abs/2106.06103)
* [Downloadable Piper TTS Models & Voices](https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models)
