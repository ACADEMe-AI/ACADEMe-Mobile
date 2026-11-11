import 'package:flutter/material.dart';

import '../../../data/repositories/photo_repository.dart';
import '../../../domain/models/pro.dart';
import '../../../domain/models/scan.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/pebby.dart';

extension ScanModeLook on ScanMode {
  IconData get icon => switch (this) {
    ScanMode.solve => Icons.calculate_rounded,
    ScanMode.check => Icons.fact_check_rounded,
    ScanMode.notes => Icons.description_rounded,
    ScanMode.ask => Icons.chat_rounded,
  };

  String title(AppLocalizations l10n) => switch (this) {
    ScanMode.solve => l10n.homeSolveHomework,
    ScanMode.check => l10n.homeCheckAnswer,
    ScanMode.notes => l10n.scanModeNotes,
    ScanMode.ask => l10n.scanModeAsk,
  };

  String hint(AppLocalizations l10n) => switch (this) {
    ScanMode.solve => l10n.scanHintSolve,
    ScanMode.check => l10n.scanHintCheck,
    ScanMode.notes => l10n.scanHintNotes,
    ScanMode.ask => l10n.scanHintAsk,
  };

  Color tint(AppPalette palette) => switch (this) {
    ScanMode.solve => palette.tintAmber,
    ScanMode.check => palette.tintMint,
    ScanMode.notes => palette.tintLavender,
    ScanMode.ask => palette.tintSky,
  };
}

class ScanSourceSheet extends StatelessWidget {
  const ScanSourceSheet({super.key, required this.mode});

  final ScanMode mode;

  static Future<PhotoSource?> show(BuildContext context, ScanMode mode) =>
      showModalBottomSheet<PhotoSource>(
        context: context,
        backgroundColor: context.palette.surface,
        barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
        showDragHandle: true,
        builder: (_) => ScanSourceSheet(mode: mode),
      );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              mode.title(l10n),
              style: AppTextStyles.display.copyWith(
                fontSize: 24,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mode == ScanMode.notes
                  ? l10n.scanSourceNotesBlurb
                  : l10n.scanSourceBlurb,
              style: AppTextStyles.label.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: l10n.scanTakePhoto,
              isPrimary: true,
              icon: const Icon(
                Icons.photo_camera_rounded,
                color: AppColors.onPrimary,
              ),
              onTap: () => Navigator.of(context).pop(PhotoSource.camera),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.scanChooseGallery,
              icon: Icon(Icons.photo_library_rounded, color: palette.text),
              onTap: () => Navigator.of(context).pop(PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanWaiting extends StatelessWidget {
  const ScanWaiting({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 160,
              child: Pebby(pose: PebbyPose.working),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.display.copyWith(
                fontSize: 22,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 160,
              child: LinearProgressIndicator(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

extension ScanFailureLimit on ScanFailure {
  ProFeature? get limitFeature => switch (this) {
    ScanFailure.scanLimit => ProFeature.scan,
    ScanFailure.checkLimit => ProFeature.check,
    ScanFailure.proOnly => ProFeature.lessons,
    _ => null,
  };
}

class ScanProblem extends StatelessWidget {
  const ScanProblem({
    super.key,
    required this.failure,
    required this.onRetry,
    required this.onRetake,
    this.onGoPro,
  });

  final ScanFailure failure;
  final VoidCallback onRetry;
  final VoidCallback onRetake;
  final VoidCallback? onGoPro;

  (String, String) _words(AppLocalizations l10n) => switch (failure) {
    ScanFailure.unavailable => (
      l10n.scanFailUnavailableTitle,
      l10n.scanFailUnavailableBody,
    ),
    ScanFailure.noText => (l10n.scanFailNoTextTitle, l10n.scanFailNoTextBody),
    ScanFailure.tooLarge => (
      l10n.scanFailTooLargeTitle,
      l10n.scanFailTooLargeBody,
    ),
    ScanFailure.network => (
      l10n.scanFailNetworkTitle,
      l10n.scanFailNetworkBody,
    ),
    ScanFailure.scanLimit => (
      l10n.scanFailScanLimitTitle,
      l10n.scanFailScanLimitBody,
    ),
    ScanFailure.checkLimit => (
      l10n.scanFailCheckLimitTitle,
      l10n.scanFailCheckLimitBody,
    ),
    ScanFailure.proOnly => (
      l10n.scanFailProOnlyTitle,
      l10n.scanFailProOnlyBody,
    ),
    ScanFailure.unknown => (
      l10n.scanFailUnknownTitle,
      l10n.scanFailUnknownBody,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final (title, text) = _words(l10n);
    final canRetry = failure != ScanFailure.noText;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox.square(
              dimension: 140,
              child: Pebby(pose: PebbyPose.think),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.display.copyWith(
                fontSize: 22,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 20),
            if (onGoPro case final goPro?
                when failure.limitFeature != null) ...[
              AppButton(label: l10n.actionGoPro, isPrimary: true, onTap: goPro),
              if (failure != ScanFailure.scanLimit) ...[
                const SizedBox(height: 12),
                AppButton(
                  label: failure == ScanFailure.proOnly
                      ? l10n.scanKeepNotes
                      : l10n.scanBackToAnswer,
                  onTap: onRetry,
                ),
              ],
            ] else ...[
              if (canRetry) ...[
                AppButton(
                  label: l10n.actionTryAgain,
                  isPrimary: true,
                  onTap: onRetry,
                ),
                const SizedBox(height: 12),
              ],
              AppButton(
                label: l10n.scanRetake,
                isPrimary: !canRetry,
                icon: Icon(
                  Icons.photo_camera_rounded,
                  color: canRetry ? palette.text : AppColors.onPrimary,
                ),
                onTap: onRetake,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ScanTextBox extends StatelessWidget {
  const ScanTextBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          text,
          maxLines: 8,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.label.copyWith(color: palette.text),
        ),
      ),
    );
  }
}
