import 'package:flutter/material.dart';

import '../../../domain/models/scan.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/celebration.dart';
import '../../core/ui/reply_text.dart';
import '../../core/ui/screen_scale.dart';
import '../../study/widgets/card_parts.dart';
import '../../study/widgets/page_scaffold.dart';

class CheckResultScreen extends StatelessWidget {
  const CheckResultScreen({
    super.key,
    required this.marking,
    required this.chapter,
    required this.onAskPebby,
    required this.onCheckAgain,
  });

  final Marking marking;
  final String chapter;
  final VoidCallback onAskPebby;
  final VoidCallback onCheckAgain;

  String get _verdict {
    if (marking.isFull) return 'Full marks!';
    if (marking.awarded * 2 >= marking.marks) return 'Nearly there';
    return 'Keep going';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final padding = ScreenScale.of(context).pagePadding;
    final ring = _MarksRing(marking: marking);
    return StudyPage(
      title: 'Check my answer',
      child: ListView(
        padding: EdgeInsets.fromLTRB(padding, 8, padding, 32),
        children: [
          Row(
            children: [
              marking.isFull ? PopIn(haptic: true, child: ring) : ring,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _verdict,
                      style: AppTextStyles.display.copyWith(
                        fontSize: 24,
                        color: palette.text,
                      ),
                    ),
                    if (chapter.isNotEmpty)
                      Text(
                        chapter,
                        style: AppTextStyles.caption.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (marking.question.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              marking.question,
              style: AppTextStyles.labelStrong.copyWith(
                color: palette.textMuted,
              ),
            ),
          ],
          const SectionTitle('What got marks'),
          for (final point in marking.points) _PointRow(point: point),
          const SizedBox(height: 16),
          RememberBox(
            label: marking.isFull ? 'Well done' : 'For full marks',
            icon: marking.isFull
                ? Icons.emoji_events_rounded
                : Icons.priority_high_rounded,
            text: marking.fullMarks,
          ),
          if (marking.modelAnswer.isNotEmpty)
            _ModelAnswer(text: marking.modelAnswer),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Ask Pebby',
                  icon: Icon(Icons.chat_rounded, color: palette.text),
                  onTap: onAskPebby,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Check again',
                  isPrimary: true,
                  icon: const Icon(
                    Icons.photo_camera_rounded,
                    color: AppColors.onPrimary,
                  ),
                  onTap: onCheckAgain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarksRing extends StatelessWidget {
  const _MarksRing({required this.marking});

  final Marking marking;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox.square(
      dimension: 88,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: marking.awarded / marking.marks,
            strokeWidth: 8,
            color: marking.isFull ? palette.success : AppColors.primary,
            backgroundColor: palette.surfaceRaised,
          ),
          Center(
            child: Text(
              '${marking.awarded}/${marking.marks}',
              style: AppTextStyles.display.copyWith(
                fontSize: 22,
                color: palette.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointRow extends StatelessWidget {
  const _PointRow({required this.point});

  final MarkPoint point;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (icon, color) = switch (point) {
      MarkPoint(isFull: true) => (Icons.check_circle_rounded, palette.success),
      MarkPoint(awarded: 0) => (Icons.cancel_rounded, palette.errorInk),
      _ => (Icons.remove_circle_rounded, AppColors.primary),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              point.text,
              style: AppTextStyles.label.copyWith(color: palette.text),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${point.awarded}/${point.marks}',
            style: AppTextStyles.labelStrong.copyWith(color: palette.text),
          ),
        ],
      ),
    );
  }
}

class _ModelAnswer extends StatefulWidget {
  const _ModelAnswer({required this.text});

  final String text;

  @override
  State<_ModelAnswer> createState() => _ModelAnswerState();
}

class _ModelAnswerState extends State<_ModelAnswer> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _isOpen = !_isOpen),
            icon: Icon(
              _isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            ),
            label: Text(_isOpen ? 'Hide model answer' : 'Show model answer'),
          ),
        ),
        if (_isOpen)
          DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surfaceRaised,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ReplyText(widget.text, fontSize: 15),
            ),
          ),
      ],
    );
  }
}
