import '../models/remote_model.dart';

class ModelsDirectory {
  static const String baseUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/';

  static final List<RemoteModel> catalog = [
    // --- English (EN) ---
    const RemoteModel(
      id: 'en_US-lessac-medium',
      language: 'English (US)',
      name: 'Lessac (Female)',
      quality: 'Medium',
      filename: 'vits-piper-en_US-lessac-medium.tar.bz2',
      downloadUrl: '${baseUrl}vits-piper-en_US-lessac-medium.tar.bz2',
      isBundled: true,
    ),
    const RemoteModel(
      id: 'en_US-ryan-medium',
      language: 'English (US)',
      name: 'Ryan (Male)',
      quality: 'Medium',
      filename: 'vits-piper-en_US-ryan-medium.tar.bz2',
      downloadUrl: '${baseUrl}vits-piper-en_US-ryan-medium.tar.bz2',
      isBundled: true,
    ),

    // --- Arabic (AR) ---
    const RemoteModel(
      id: 'ar_JO-kareem-medium',
      language: 'Arabic (JO)',
      name: 'Kareem (Male)',
      quality: 'Medium',
      filename: 'vits-piper-ar_JO-kareem-medium.tar.bz2',
      downloadUrl: '${baseUrl}vits-piper-ar_JO-kareem-medium.tar.bz2',
      isBundled: true,
    ),
  ];
}
