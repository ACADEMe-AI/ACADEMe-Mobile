import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/face_card.dart';
import '../../core/ui/screen_scale.dart';
import '../../me/view_models/me_view_model.dart';
import '../../me/widgets/me_stats.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.me, required this.onGoPro});

  final MeViewModel me;
  final VoidCallback onGoPro;

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return ListenableBuilder(
      listenable: me,
      builder: (context, _) {
        final body = ListView(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
          children: [
            Text(
              'Your streak, level and XP update as you study.',
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            MeStats(
              xp: me.profile.xp,
              level: me.level,
              streak: me.profile.streak,
            ),
            const SizedBox(height: 16),
            FaceCard(
              child: Text(
                me.syllabusLabel,
                style: AppTextStyles.labelStrong.copyWith(
                  color: context.palette.text,
                ),
              ),
            ),
          ],
        );
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: AppBar(
            title: const Text('My Progress'),
            backgroundColor: context.palette.surface,
            foregroundColor: context.palette.text,
          ),
          body: me.isPro
              ? body
              : Stack(
                  children: [
                    IgnorePointer(child: body),
                    _ProgressHold(onGoPro: onGoPro),
                  ],
                ),
        );
      },
    );
  }
}

class _ProgressHold extends StatelessWidget {
  const _ProgressHold({required this.onGoPro});

  final VoidCallback onGoPro;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.palette.surface.withValues(alpha: .72),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'My Progress is part of Pro',
                textAlign: TextAlign.center,
                style: AppTextStyles.sheetTitle.copyWith(
                  color: context.palette.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'See streak, level and study insights with ACADEMe Pro.',
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: context.palette.textMuted,
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Go Pro · 3× limits',
                isPrimary: true,
                onTap: onGoPro,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
