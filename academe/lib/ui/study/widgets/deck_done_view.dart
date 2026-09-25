import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/celebration.dart';
import '../../core/ui/pebby.dart';

class DeckDoneView extends StatelessWidget {
  const DeckDoneView({
    super.key,
    required this.title,
    required this.correct,
    required this.quizzes,
    required this.xp,
    required this.kept,
    required this.nextTitle,
    required this.onNext,
    required this.onClose,
  });

  final String title;
  final int correct;
  final int quizzes;
  final int xp;
  final int kept;
  final String? nextTitle;
  final VoidCallback? onNext;
  final VoidCallback onClose;

  bool get _isPerfect => quizzes > 0 && correct == quizzes;

  @override
  Widget build(BuildContext context) {
    final nextTitle = this.nextTitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Burst(
                  size: 260,
                  dots: 16,
                  duration: Duration(milliseconds: 900),
                ),
                SizedBox.square(
                  dimension: 180,
                  child: Pebby(
                    pose: _isPerfect
                        ? PebbyPose.celebrateBig
                        : PebbyPose.celebrateSmall,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _isPerfect ? 'Perfect lesson!' : 'Lesson done!',
            textAlign: TextAlign.center,
            style: AppTextStyles.display.copyWith(
              fontSize: 30,
              color: context.palette.text,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Stat(value: '$correct/$quizzes', label: 'right'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Stat(value: '+$xp', label: 'XP', countsUp: xp),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Stat(value: '$kept', label: 'kept'),
              ),
            ],
          ),
          const Spacer(),
          if (nextTitle != null) ...[
            AppButton(
              label: 'Next: $nextTitle',
              isPrimary: true,
              onTap: onNext,
            ),
            const SizedBox(height: 12),
          ],
          AppButton(
            label: 'Back to chapter',
            isPrimary: nextTitle == null,
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.countsUp});

  final String value;
  final String label;
  final int? countsUp;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            if (countsUp case final n?)
              CountUp(
                value: n,
                prefix: '+',
                style: AppTextStyles.display.copyWith(
                  fontSize: 24,
                  color: context.palette.text,
                ),
              )
            else
              Text(
                value,
                style: AppTextStyles.display.copyWith(
                  fontSize: 24,
                  color: context.palette.text,
                ),
              ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
