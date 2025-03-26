import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../services/tts_service.dart';
import '../widgets/audio_player_widget.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({Key? key}) : super(key: key);

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedAudioPath;
  final TTSService _ttsService = TTSService();
  double _pitch = 1.0;
  double _speed = 1.0;
  String _selectedVoice = 'Default';

  final List<String> _availableVoices = ['Default', 'Male', 'Female', 'Child'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _generateSpeech() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedAudioPath = null;
    });

    try {
      final audioPath = await _ttsService.generateSpeech(
        _textController.text,
        voice: _selectedVoice,
        pitch: _pitch,
        speed: _speed,
      );

      setState(() {
        _generatedAudioPath = audioPath;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating speech: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Convert Text to Speech',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 6,
                style: theme.textTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Enter text to convert to speech...',
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Voice selection
            DropdownButtonFormField<String>(
              value: _selectedVoice,
              decoration: const InputDecoration(
                labelText: 'Voice',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              items: _availableVoices.map((voice) {
                return DropdownMenuItem(
                  value: voice,
                  child: Text(voice),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedVoice = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // Pitch control
            Row(
              children: [
                Text('Pitch:', style: theme.textTheme.bodyMedium),
                Expanded(
                  child: Slider(
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 30,
                    label: _pitch.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _pitch = value;
                      });
                    },
                  ),
                ),
                Text(_pitch.toStringAsFixed(1), style: theme.textTheme.bodyMedium),
              ],
            ),

            // Speed control
            Row(
              children: [
                Text('Speed:', style: theme.textTheme.bodyMedium),
                Expanded(
                  child: Slider(
                    value: _speed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 30,
                    label: _speed.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _speed = value;
                      });
                    },
                  ),
                ),
                Text(_speed.toStringAsFixed(1), style: theme.textTheme.bodyMedium),
              ],
            ),

            const SizedBox(height: 20),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateSpeech,
                child: _isGenerating
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Generating...'),
                  ],
                )
                    : const Text('Generate Speech'),
              ),
            ),

            const SizedBox(height: 20),

            // Audio player
            if (_generatedAudioPath != null)
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: AudioPlayerWidget(
                  audioPath: _generatedAudioPath!,
                  onSave: () async {
                    // Save the generated audio
                    final success = await _ttsService.saveAudio(
                      _generatedAudioPath!,
                      _textController.text.substring(0,
                          _textController.text.length > 30 ? 30 : _textController.text.length),
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio saved successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save audio')),
                      );
                    }
                  },
                ),
              ),
            const SizedBox(height: 40), // Add some padding at the bottom for better scrolling
          ],
        ),
      ),
    );
  }
}