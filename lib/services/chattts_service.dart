import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:just_audio/just_audio.dart';

class ChatTTSService {
  static const String _modelPath = 'assets/models/chattts.tflite';
  static const String _metadataPath = 'assets/models/chattts_metadata.json';
  static const String _vocabPath = 'assets/models/chattts_vocab.txt';

  Interpreter? _interpreter;
  Map<String, dynamic>? _metadata;
  List<String>? _vocabulary;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> initialize() async {
    try {
      // Load the TFLite model
      _interpreter = await Interpreter.fromAsset(_modelPath);

      // Load metadata
      final String metadataJson = await rootBundle.loadString(_metadataPath);
      _metadata = json.decode(metadataJson);

      // Load vocabulary
      final String vocabText = await rootBundle.loadString(_vocabPath);
      _vocabulary = vocabText.split('\n');

      // Initialize audio player
      await _audioPlayer.setLoopMode(LoopMode.off);
    } catch (e) {
      print('Error initializing ChatTTS: $e');
      throw Exception('Failed to initialize ChatTTS');
    }
  }

  Future<void> generateSpeech(String text) async {
    if (_interpreter == null || _metadata == null || _vocabulary == null) {
      throw Exception('ChatTTS not initialized');
    }

    try {
      // Prepare input tensor
      final inputShape = _metadata!['input_shapes']['text_input'];
      final outputShape = _metadata!['output_shapes']['audio_output'];

      // Create input tensor
      var input = [text.toLowerCase()];

      // Create output tensor
      var output = List.filled(outputShape[0] * outputShape[1], 0.0);

      // Run inference
      _interpreter!.run(input, [output]);

      // Convert output to audio samples
      final audioSamples = Float32List.fromList(output);

      // Save the generated audio to a temporary file
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/generated_audio.wav');

      // Write WAV header and audio data
      final sampleRate = _metadata!['sample_rate'];
      await _writeWavFile(audioFile, audioSamples, sampleRate);

      // Play the generated audio
      await _audioPlayer.setFilePath(audioFile.path);
      await _audioPlayer.play();
    } catch (e) {
      print('Error generating speech: $e');
      throw Exception('Failed to generate speech');
    }
  }

  Future<void> _writeWavFile(
      File file, Float32List samples, int sampleRate) async {
    final writer = ByteData(44 + samples.length * 2);

    // Write WAV header
    writer.setUint32(0, 0x46464952, Endian.big); // "RIFF"
    writer.setUint32(4, 36 + samples.length * 2, Endian.little);
    writer.setUint32(8, 0x45564157, Endian.big); // "WAVE"
    writer.setUint32(12, 0x20746D66, Endian.big); // "fmt "
    writer.setUint32(16, 16, Endian.little); // PCM
    writer.setUint16(20, 1, Endian.little); // Mono
    writer.setUint16(22, 1, Endian.little); // Number of channels
    writer.setUint32(24, sampleRate, Endian.little);
    writer.setUint32(28, sampleRate * 2, Endian.little);
    writer.setUint16(32, 2, Endian.little);
    writer.setUint16(34, 16, Endian.little);
    writer.setUint32(36, 0x61746164, Endian.big); // "data"
    writer.setUint32(40, samples.length * 2, Endian.little);

    // Write audio samples
    for (var i = 0; i < samples.length; i++) {
      writer.setInt16(44 + i * 2, (samples[i] * 32767).round(), Endian.little);
    }

    await file.writeAsBytes(writer.buffer.asUint8List());
  }

  void dispose() {
    _interpreter?.close();
    _audioPlayer.dispose();
  }
}
