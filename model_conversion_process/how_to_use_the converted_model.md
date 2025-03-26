# Using ChatTTS TensorFlow Model in Flutter and Android Apps

## Overview
This guide explains how to integrate the converted ChatTTS TensorFlow model (`chattts_tf`) into Flutter and Android applications. The model can be used to generate speech from text input.

## Android Integration

### 1. Setup Android Project

#### Add TensorFlow Dependencies
Add the following to your app's `build.gradle`:

```gradle
dependencies {
    implementation 'org.tensorflow:tensorflow-lite:2.12.0'
    implementation 'org.tensorflow:tensorflow-lite-support:0.4.4'
}
```

#### Add Model to Assets
1. Create an `assets` folder in your Android project
2. Copy the `chattts_tf` folder to `app/src/main/assets/`

### 2. Create Model Interface

```kotlin
// ChatTTSModel.kt
class ChatTTSModel(private val context: Context) {
    private var interpreter: Interpreter? = null
    
    init {
        // Load model from assets
        val modelFile = FileUtil.loadMappedFile(context, "chattts_tf")
        val options = Interpreter.Options()
        interpreter = Interpreter(modelFile, options)
    }
    
    fun generateSpeech(text: String): FloatArray {
        // Convert text to tensor
        val inputBuffer = ByteBuffer.allocateDirect(text.length * 4)
        inputBuffer.order(ByteOrder.nativeOrder())
        inputBuffer.put(text.toByteArray())
        
        // Prepare output buffer
        val outputBuffer = ByteBuffer.allocateDirect(MAX_AUDIO_LENGTH * 4)
        outputBuffer.order(ByteOrder.nativeOrder())
        
        // Run inference
        interpreter?.run(inputBuffer, outputBuffer)
        
        // Convert output to float array
        return FloatArray(MAX_AUDIO_LENGTH) { outputBuffer.getFloat() }
    }
    
    fun close() {
        interpreter?.close()
    }
}
```

### 3. Create Audio Service

```kotlin
// AudioService.kt
class AudioService(private val context: Context) {
    private var audioTrack: AudioTrack? = null
    
    fun playAudio(audioData: FloatArray) {
        // Convert float array to PCM
        val pcmData = convertToPCM(audioData)
        
        // Initialize AudioTrack
        audioTrack = AudioTrack(
            AudioManager.STREAM_MUSIC,
            SAMPLE_RATE,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            pcmData.size,
            AudioTrack.MODE_STATIC
        )
        
        // Write and play audio
        audioTrack?.write(pcmData, 0, pcmData.size)
        audioTrack?.play()
    }
    
    private fun convertToPCM(audioData: FloatArray): ShortArray {
        return ShortArray(audioData.size) { 
            (audioData[it] * Short.MAX_VALUE).toInt().toShort() 
        }
    }
    
    fun release() {
        audioTrack?.release()
    }
}
```

## Flutter Integration

### 1. Setup Flutter Project

#### Add Dependencies
Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  tflite_flutter: ^0.10.4
  path_provider: ^2.1.2
  just_audio: ^0.9.36
```

### 2. Create Model Service

```dart
// lib/services/chat_tts_service.dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ChatTTSService {
  late Interpreter _interpreter;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load model from assets
    final modelPath = await _getModelPath();
    _interpreter = await Interpreter.fromFile(modelPath);
    _isInitialized = true;
  }

  Future<String> _getModelPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${appDir.path}/chattts_tf');
    
    if (!await modelDir.exists()) {
      // Copy model from assets to app directory
      await _copyModelFromAssets();
    }
    
    return modelDir.path;
  }

  Future<List<double>> generateSpeech(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Prepare input
    final inputBuffer = Float32List.fromList(
      text.codeUnits.map((unit) => unit.toDouble()).toList()
    );

    // Prepare output buffer
    final outputBuffer = Float32List(MAX_AUDIO_LENGTH);

    // Run inference
    _interpreter.run(inputBuffer, outputBuffer);

    return outputBuffer.toList();
  }

  void dispose() {
    _interpreter.close();
    _isInitialized = false;
  }
}
```

### 3. Create Audio Player Service

```dart
// lib/services/audio_player_service.dart
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAudio(List<double> audioData) async {
    // Convert audio data to PCM
    final pcmData = _convertToPCM(audioData);
    
    // Create temporary file
    final tempFile = await _createTempAudioFile(pcmData);
    
    // Play audio
    await _player.setFilePath(tempFile.path);
    await _player.play();
  }

  List<int> _convertToPCM(List<double> audioData) {
    return audioData.map((sample) {
      return (sample * 32767).round().clamp(-32767, 32767);
    }).toList();
  }

  Future<File> _createTempAudioFile(List<int> pcmData) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/temp_audio.pcm');
    await file.writeAsBytes(pcmData);
    return file;
  }

  void dispose() {
    _player.dispose();
  }
}
```

### 4. Usage in Flutter UI

```dart
// lib/screens/tts_screen.dart
class TTSScreen extends StatefulWidget {
  @override
  _TTSScreenState createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  final ChatTTSService _ttsService = ChatTTSService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _ttsService.initialize();
  }

  Future<void> _generateAndPlaySpeech() async {
    final text = _textController.text;
    if (text.isEmpty) return;

    final audioData = await _ttsService.generateSpeech(text);
    await _audioService.playAudio(audioData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text to Speech')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter text to convert to speech',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateAndPlaySpeech,
              child: Text('Generate Speech'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _audioService.dispose();
    _textController.dispose();
    super.dispose();
  }
}
```

## Constants and Configuration

```kotlin
// Android
companion object {
    private const val SAMPLE_RATE = 22050
    private const val MAX_AUDIO_LENGTH = 32768
}
```

```dart
// Flutter
const int SAMPLE_RATE = 22050;
const int MAX_AUDIO_LENGTH = 32768;
```

## Performance Considerations

1. **Model Loading**
    - Load model once and reuse the instance
    - Consider lazy loading for better app startup time

2. **Memory Management**
    - Release resources when not in use
    - Handle large audio outputs efficiently

3. **Error Handling**
    - Implement proper error handling for model loading
    - Handle audio playback errors gracefully

4. **Background Processing**
    - Use background threads for model inference
    - Implement proper audio session handling

## Troubleshooting

1. **Model Loading Issues**
    - Verify model file is properly included in assets
    - Check model file permissions
    - Ensure sufficient storage space

2. **Audio Playback Issues**
    - Verify audio format compatibility
    - Check audio session configuration
    - Handle audio focus changes

3. **Performance Issues**
    - Monitor memory usage
    - Profile model inference time
    - Optimize audio buffer sizes 