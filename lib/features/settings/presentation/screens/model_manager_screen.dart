import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/models/remote_model.dart';
import '../../../../services/model_downloader_service.dart';
import '../../../../services/tts_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../theme/presentation/providers/theme_provider.dart';

class ModelManagerScreen extends StatefulWidget {
  const ModelManagerScreen({super.key});

  @override
  State<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

class _ModelManagerScreenState extends State<ModelManagerScreen> {
  late final TTSService _ttsService;
  Map<String, List<RemoteModel>>? _cachedGroupedModels;

  @override
  void initState() {
    super.initState();
    _ttsService = sl<TTSService>();
  }

  Future<void> _setActiveModel(RemoteModel model) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _ttsService.setActiveModel(model);
      if (mounted) {
        Navigator.pop(context);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.modelActivated(model.name)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.modelActivateFailed),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloader = context.watch<ModelDownloaderService>();
    final allModels = downloader.allModels;

    // Memoize grouped models - only recalculate when allModels changes
    if (_cachedGroupedModels == null ||
        _cachedGroupedModels!.length != allModels.length) {
      _cachedGroupedModels = {};
      for (var model in allModels) {
        _cachedGroupedModels!.putIfAbsent(model.language, () => []).add(model);
      }
    }

    final isDarkMode = context.select<ThemeProvider, bool>((p) => p.isDarkMode);
    final activeColor = Theme.of(context).colorScheme.primary;
    final isLoading = downloader.isLoadingModels;
    // Use context.select to get active model ID - prevents full rebuilds
    final activeModelId = context.select<TTSService, String>(
      (s) => s.activeModel.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.modelManagerTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body:
          isLoading
              ? _buildShimmerList(isDarkMode)
              : CustomScrollView(
                slivers: [
                  ..._cachedGroupedModels!.entries.map((entry) {
                    final language = entry.key;
                    final models = entry.value;

                    return SliverMainAxisGroup(
                      slivers: [
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _LanguageHeaderDelegate(
                            language: language,
                            isDarkMode: isDarkMode,
                            themeColor:
                                Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final model = models[index];
                            return _buildModelCard(
                              model,
                              activeColor,
                              isDarkMode,
                              activeModelId,
                            );
                          }, childCount: models.length),
                        ),
                      ],
                    );
                  }),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                ],
              ),
    );
  }

  Widget _buildShimmerList(bool isDarkMode) {
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        padding: const EdgeInsets.only(top: 16),
        itemBuilder:
            (_, __) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
      ),
    );
  }

  Widget _buildModelCard(
    RemoteModel model,
    Color activeColor,
    bool isDarkMode,
    String activeModelId,
  ) {
    final isActive = activeModelId == model.id;

    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor =
        isActive
            ? activeColor
            : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isActive ? 2 : 1),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!isActive) {
              _setActiveModel(model);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? activeColor.withValues(alpha: 0.15)
                            : (isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[100]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.record_voice_over_rounded,
                    color:
                        isActive
                            ? activeColor
                            : (isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.modelQuality(model.quality),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                              ),
                            ),
                          ),
                          if (model.isBundled) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? Colors.green.withValues(alpha: 0.15)
                                        : Colors.green.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.modelBundled,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isDarkMode
                                          ? Colors.green[300]
                                          : Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _buildTrailingAction(model, isActive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingAction(RemoteModel model, bool isActive) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.of(context)!.modelActive,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _LanguageHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String language;
  final bool isDarkMode;
  final Color themeColor;

  _LanguageHeaderDelegate({
    required this.language,
    required this.isDarkMode,
    required this.themeColor,
  });

  @override
  double get minExtent => 50.0;

  @override
  double get maxExtent => 50.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: themeColor.withValues(alpha: 0.98),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      alignment: Alignment.centerLeft,
      child: Text(
        language,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_LanguageHeaderDelegate oldDelegate) {
    return oldDelegate.language != language ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.themeColor != themeColor;
  }
}
