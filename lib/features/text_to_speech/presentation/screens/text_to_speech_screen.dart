import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../settings/presentation/screens/model_manager_screen.dart';
import 'package:provider/provider.dart';

import '../../../theme/presentation/providers/theme_provider.dart';
import '../../../../services/tts_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/widgets/sound_wave_animation.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/audio_player_widget.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedAudioPath;
  late TTSService _ttsService;
  double _speed = AppConstants.defaultSpeed;

  // Text history
  List<String> _textHistory = [];

  // Batch generation state
  int _batchCurrentPart = 0;
  int _batchTotalParts = 0;

  // Computed helpers
  int get _wordCount {
    final text = _textController.text.trim();
    if (text.isEmpty) return 0;
    // Match sequences of Unicode letters/digits (handles Arabic, English, etc.)
    return RegExp(r'[\p{L}\p{N}]+', unicode: true).allMatches(text).length;
  }

  String get _estimatedDuration {
    if (_wordCount == 0) return '0s';
    final minutes = _wordCount / (150.0 * _speed);
    if (minutes < 1.0) return '${(minutes * 60).round()}s';
    return '${minutes.toStringAsFixed(1)}min';
  }

  List<String> get _paragraphs => _textController.text
      .split(RegExp(r'\n\s*\n'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .toList();

  bool get _isBatchMode => _paragraphs.length > 1;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
    _loadDefaultSpeed();
    _loadTextHistory();
  }

  Future<void> _loadDefaultSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    final speed = prefs.getDouble(AppConstants.storageKeyDefaultSpeed);
    if (speed != null && mounted) {
      setState(() => _speed = speed);
    }
  }

  Future<void> _loadTextHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.storageKeyTextHistory);
    if (raw != null && mounted) {
      setState(() => _textHistory = raw);
    }
  }

  Future<void> _addToHistory(String text) async {
    _textHistory.remove(text); // deduplicate
    _textHistory.insert(0, text);
    if (_textHistory.length > AppConstants.maxTextHistory) {
      _textHistory = _textHistory.sublist(0, AppConstants.maxTextHistory);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.storageKeyTextHistory, _textHistory);
  }

  Future<void> _removeFromHistory(int index) async {
    setState(() => _textHistory.removeAt(index));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.storageKeyTextHistory, _textHistory);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsService = Provider.of<TTSService>(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _generateSpeech() async {
    final text = _textController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (text.isEmpty) {
      _showErrorSnackBar(l10n.ttsEmptyTextError);
      return;
    }
    if (text.length > AppConstants.maxTextLength) {
      _showErrorSnackBar(l10n.ttsTextTooLong(AppConstants.maxTextLength));
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedAudioPath = null;
    });

    try {
      final audioPath = await _ttsService.generateSpeech(
        text,
        voice: AppConstants.defaultVoice,
        speed: _speed,
      );
      if (mounted) {
        setState(() => _generatedAudioPath = audioPath);
        _addToHistory(text);
      }
    } catch (e) {
      if (mounted) {
        String message = l10n.genericError;
        if (e is TtsInitializationException) {
          message = l10n.ttsEngineError;
        } else if (e is TtsGenerationException) {
          message = l10n.ttsGenerationError;
        }
        _showErrorSnackBar(message);
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _batchGenerate() async {
    final paragraphs = _paragraphs;
    final l10n = AppLocalizations.of(context)!;

    if (paragraphs.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _generatedAudioPath = null;
      _batchTotalParts = paragraphs.length;
      _batchCurrentPart = 0;
    });

    int successCount = 0;
    try {
      for (int i = 0; i < paragraphs.length; i++) {
        if (!mounted) break;
        setState(() => _batchCurrentPart = i + 1);

        final audioPath = await _ttsService.generateSpeech(
          paragraphs[i],
          voice: AppConstants.defaultVoice,
          speed: _speed,
        );

        final snippet = paragraphs[i].length > 25
            ? paragraphs[i].substring(0, 25)
            : paragraphs[i];
        await _ttsService.saveAudio(audioPath, 'Part ${i + 1}: $snippet');
        successCount++;
      }
      if (mounted) {
        _showSuccessSnackBar(l10n.ttsBatchComplete(successCount));
        _addToHistory(_textController.text.trim());
      }
    } catch (e) {
      if (mounted) {
        String message = l10n.genericError;
        if (e is TtsInitializationException) {
          message = l10n.ttsEngineError;
        } else if (e is TtsGenerationException) {
          message = l10n.ttsGenerationError;
        }
        _showErrorSnackBar(message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _batchCurrentPart = 0;
          _batchTotalParts = 0;
        });
      }
    }
  }

  void _showHistorySheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(l10n.ttsHistoryTitle, style: Theme.of(sheetContext).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (_textHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          l10n.ttsHistoryEmpty,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.4),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _textHistory.length,
                        itemBuilder: (_, index) {
                          final text = _textHistory[index];
                          return Dismissible(
                            key: ValueKey('history_${index}_$text'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              color: Colors.red,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              _removeFromHistory(index);
                              setSheetState(() {});
                            },
                            child: ListTile(
                              title: Text(
                                text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              dense: true,
                              onTap: () {
                                _textController.text = text;
                                _textController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: text.length),
                                );
                                Navigator.pop(sheetContext);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Text(message),
        ]),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final charCount = _textController.text.length;
    final isOverLimit = charCount > AppConstants.maxTextLength;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(l10n.ttsTitle, style: theme.textTheme.titleLarge)),
                IconButton(
                  icon: const Icon(Icons.history, size: 22),
                  tooltip: l10n.ttsHistory,
                  onPressed: _showHistorySheet,
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const ModelManagerScreen(),
                        transitionsBuilder: (_, animation, __, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  icon: const Icon(Icons.language, size: 18),
                  label: Text(
                    _ttsService.activeModel.language,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Text input
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 6,
                maxLength: AppConstants.maxTextLength + 100,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: l10n.ttsHint,
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                  counterText: '', // hide default counter
                ),
              ),
            ),

            // Character counter + word count
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_textController.text.trim().isNotEmpty)
                    Text(
                      l10n.ttsWordCount(_wordCount, _estimatedDuration),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Text(
                    '$charCount / ${AppConstants.maxTextLength}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isOverLimit ? Colors.red : null,
                      fontWeight: isOverLimit ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Speed control
            Row(
              children: [
                Text(l10n.ttsSpeedLabel, style: theme.textTheme.bodyMedium),
                Expanded(
                  child: Slider(
                    value: _speed,
                    min: AppConstants.minSpeed,
                    max: AppConstants.maxSpeed,
                    divisions: 25,
                    label: '${_speed.toStringAsFixed(1)}x',
                    onChanged: (value) => setState(() => _speed = value),
                  ),
                ),
                Text('${_speed.toStringAsFixed(1)}x',
                    style: theme.textTheme.bodyMedium),
              ],
            ),

            const SizedBox(height: 20),

            // Sound wave animation
            if (_isGenerating)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: Column(
                    children: [
                      SoundWaveAnimation(
                        isAnimating: true,
                        color: isDarkMode
                            ? const Color(0xFF00D8FF)
                            : const Color(0xFF1A3684),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _batchTotalParts > 0
                            ? l10n.ttsBatchProgress(_batchCurrentPart, _batchTotalParts)
                            : (_textController.text.length > AppConstants.maxTextLengthForInstantGeneration
                                ? l10n.ttsGeneratingLong
                                : l10n.ttsGenerating),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating || _textController.text.trim().isEmpty || isOverLimit
                    ? null
                    : (_isBatchMode ? _batchGenerate : _generateSpeech),
                child: Text(
                  _isBatchMode
                      ? l10n.ttsBatchGenerate(_paragraphs.length)
                      : l10n.ttsGenerateButton,
                ),
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
                    final textSnippet = _textController.text.length > 30
                        ? _textController.text.substring(0, 30)
                        : _textController.text;
                    final success = await _ttsService.saveAudio(
                      _generatedAudioPath!,
                      textSnippet,
                    );
                    if (mounted) {
                      if (success) {
                        _showSuccessSnackBar(l10n.ttsAudioSaved);
                      } else {
                        _showErrorSnackBar(l10n.ttsAudioSaveFailed);
                      }
                    }
                  },
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}