import 'package:flutter/material.dart';

import '../../../data/repositories/photo_repository.dart';
import '../../../domain/models/pro.dart';
import '../../../domain/models/scan.dart';
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

  String get hint => switch (this) {
    ScanMode.solve => 'Hints first',
    ScanMode.check => 'Board-style marks',
    ScanMode.notes => 'Pages into a lesson',
    ScanMode.ask => 'Anything else',
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              mode.label,
              style: AppTextStyles.display.copyWith(
                fontSize: 24,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mode == ScanMode.notes
                  ? 'Up to 10 pages. Only the text is kept, not the photos.'
                  : 'Only the text is kept, not the photo.',
              style: AppTextStyles.label.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Take a photo',
              isPrimary: true,
              icon: const Icon(
                Icons.photo_camera_rounded,
                color: AppColors.onPrimary,
              ),
              onTap: () => Navigator.of(context).pop(PhotoSource.camera),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Choose from gallery',
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

  (String, String) get _words => switch (failure) {
    ScanFailure.unavailable => (
      'Scan isn’t ready yet',
      'Pebby can’t read photos right now. Try again later.',
    ),
    ScanFailure.noText => (
      'No words here',
      'Point the camera at your homework, a textbook page or your notes.',
    ),
    ScanFailure.tooLarge => (
      'Too many big photos',
      'Try fewer pages at a time.',
    ),
    ScanFailure.network => (
      'You’re offline',
      'Check your internet and try again.',
    ),
    ScanFailure.scanLimit => (
      'That’s today’s free scans',
      'They come back at midnight. Go Pro to scan as much as you like.',
    ),
    ScanFailure.checkLimit => (
      'That’s today’s free check',
      'It comes back at midnight. Go Pro to check every answer.',
    ),
    ScanFailure.proOnly => (
      'Lessons from notes are Pro',
      'Keep your notes for free, or go Pro and Pebby makes them a lesson.',
    ),
    ScanFailure.unknown => (
      'Pebby couldn’t read that',
      'Try again, or retake the photo in better light.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (title, text) = _words;
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
              AppButton(label: 'Go Pro', isPrimary: true, onTap: goPro),
              if (failure != ScanFailure.scanLimit) ...[
                const SizedBox(height: 12),
                AppButton(
                  label: failure == ScanFailure.proOnly
                      ? 'Just keep the notes'
                      : 'Back to your answer',
                  onTap: onRetry,
                ),
              ],
            ] else ...[
              if (canRetry) ...[
                AppButton(label: 'Try again', isPrimary: true, onTap: onRetry),
                const SizedBox(height: 12),
              ],
              AppButton(
                label: 'Retake',
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
