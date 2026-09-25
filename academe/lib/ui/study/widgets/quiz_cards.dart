import 'package:flutter/material.dart';

import '../../../domain/models/deck.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/celebration.dart';
import '../../core/ui/keycap.dart';
import '../../core/ui/reply_text.dart';
import 'answer_feedback.dart';
import 'card_parts.dart';

class QuizCardView extends StatelessWidget {
  const QuizCardView({
    super.key,
    required this.card,
    required this.pick,
    required this.result,
    required this.onPick,
    this.kicker = 'Quick check',
    this.streak = 0,
    this.xp = 0,
  });

  final QuizCard card;
  final int? pick;
  final bool? result;
  final ValueChanged<int> onPick;
  final String kicker;
  final int streak;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final result = this.result;
    return CardBody(
      children: [
        Row(
          children: [
            Expanded(
              child: CardKicker(icon: Icons.task_alt_rounded, text: kicker),
            ),
            const _XpTag(),
          ],
        ),
        const SizedBox(height: 8),
        CardTitle(card.question, size: 20),
        const SizedBox(height: 12),
        for (var i = 0; i < card.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OptionKey(
              label: card.options[i],
              state: _stateOf(i),
              celebrate: result != null,
              xp: i == card.answer ? xp : 0,
              onTap: result == null ? () => onPick(i) : null,
            ),
          ),
        if (result != null)
          ResultLine(
            isCorrect: result,
            streak: streak,
            praise: _praise[card.question.length % _praise.length],
          ),
      ],
    );
  }

  static const _praise = [
    'Nice! That’s right.',
    'Spot on!',
    'You got it!',
    'Correct, well done!',
    'Exactly right!',
  ];

  OptionState _stateOf(int i) {
    if (result == null) {
      return i == pick ? OptionState.picked : OptionState.idle;
    }
    if (i == card.answer) return OptionState.right;
    if (i == pick) return OptionState.wrong;
    return OptionState.idle;
  }
}

class WhyCardView extends StatelessWidget {
  const WhyCardView({
    super.key,
    required this.card,
    required this.pick,
    required this.tools,
  });

  final QuizCard card;
  final int? pick;
  final Widget tools;

  @override
  Widget build(BuildContext context) {
    final pick = this.pick;
    return CardBody(
      tools: tools,
      children: [
        const CardKicker(icon: Icons.help_outline_rounded, text: 'Here’s why'),
        const SizedBox(height: 8),
        Text(
          card.question,
          style: AppTextStyles.labelStrong.copyWith(
            color: context.palette.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        if (pick != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OptionKey(
              label: card.options[pick],
              note: 'Your answer',
              state: OptionState.wrong,
            ),
          ),
        OptionKey(
          label: card.options[card.answer],
          note: 'Right answer',
          state: OptionState.right,
        ),
        const SizedBox(height: 16),
        ReplyText(card.why, fontSize: 16),
        const SizedBox(height: 16),
        const RememberBox(
          label: 'Kept for you',
          icon: Icons.bookmark_added_rounded,
          text: 'This question comes back in your revision tomorrow.',
        ),
      ],
    );
  }
}

enum OptionState { idle, picked, right, wrong }

class OptionKey extends StatelessWidget {
  const OptionKey({
    super.key,
    required this.label,
    required this.state,
    this.note,
    this.onTap,
    this.celebrate = false,
    this.xp = 0,
  });

  final String label;
  final OptionState state;
  final String? note;
  final VoidCallback? onTap;
  final bool celebrate;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final face = switch (state) {
      OptionState.idle => palette.surface,
      OptionState.picked => AppColors.selected,
      OptionState.right => palette.tintMint,
      OptionState.wrong => palette.tintRose,
    };
    final ink = state == OptionState.picked
        ? AppColors.keycapEdge
        : palette.text;
    final mark = switch (state) {
      OptionState.right => Icons.check_circle_rounded,
      OptionState.wrong => Icons.cancel_rounded,
      _ => null,
    };
    final key = Semantics(
      selected: state == OptionState.picked,
      child: Keycap(
        face: face,
        depth: 3,
        height: 52,
        isLatched: state == OptionState.picked,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelStrong.copyWith(color: ink),
                ),
              ),
              if (note case final text?)
                Text(
                  text,
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              if (mark != null) ...[
                const SizedBox(width: 8),
                Icon(
                  mark,
                  size: 20,
                  color: state == OptionState.right
                      ? palette.success
                      : palette.errorInk,
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (!celebrate) return key;
    if (state == OptionState.wrong) return Shake(child: key);
    if (state != OptionState.right) return key;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PopIn(haptic: true, child: key),
        const Positioned(
          right: -30,
          top: -24,
          child: Burst(
            size: 100,
            dots: 12,
            duration: Duration(milliseconds: 900),
          ),
        ),
        if (xp > 0)
          Positioned(
            right: 44,
            top: -4,
            child: FloatUp(child: XpChip(xp: xp)),
          ),
      ],
    );
  }
}

class _XpTag extends StatelessWidget {
  const _XpTag();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.keycapEdge, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          '+${QuizCard.xp} XP',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.keycapEdge,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
