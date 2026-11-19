import 'package:flutter/material.dart';

import '../../../domain/models/deck.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/reply_text.dart';
import 'card_parts.dart';

class StartCardView extends StatelessWidget {
  const StartCardView({
    super.key,
    required this.card,
    required this.title,
    required this.cards,
    required this.quizzes,
  });

  final StartCard card;
  final String title;
  final int cards;
  final int quizzes;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return CardBody(
      children: [
        CardKicker(icon: Icons.flag_rounded, text: l10n.deckNewLesson),
        const SizedBox(height: 8),
        CardTitle(title, size: 28),
        const SizedBox(height: 16),
        Text(
          l10n.deckByTheEnd,
          style: AppTextStyles.labelStrong.copyWith(color: palette.text),
        ),
        const SizedBox(height: 4),
        for (final goal in card.goals)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 20,
                  color: palette.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      color: palette.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Text(
          l10n.deckMetaLine(
            l10n.studyCardsCount(cards),
            l10n.studyQuickChecksCount(quizzes),
            card.minutes,
          ),
          style: AppTextStyles.caption.copyWith(color: palette.textMuted),
        ),
      ],
    );
  }
}

class ConceptCardView extends StatelessWidget {
  const ConceptCardView({super.key, required this.card, required this.tools});

  final ConceptCard card;
  final Widget tools;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final remember = card.remember;
    return CardBody(
      tools: tools,
      children: [
        CardKicker(
          icon: Icons.lightbulb_outline_rounded,
          text: l10n.deckConcept,
        ),
        const SizedBox(height: 8),
        CardTitle(card.title),
        const SizedBox(height: 12),
        ReplyText(card.body, fontSize: 17),
        if (remember != null) ...[
          const SizedBox(height: 16),
          RememberBox(text: remember),
        ],
      ],
    );
  }
}

class TableCardView extends StatelessWidget {
  const TableCardView({super.key, required this.card, required this.tools});

  final TableCard card;
  final Widget tools;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final remember = card.remember;
    return CardBody(
      tools: tools,
      children: [
        CardKicker(icon: Icons.table_rows_outlined, text: l10n.deckInOneLook),
        const SizedBox(height: 8),
        CardTitle(card.title),
        const SizedBox(height: 12),
        for (final (term, value) in card.rows)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: palette.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      term,
                      style: AppTextStyles.labelStrong.copyWith(
                        color: palette.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Text(
                      value,
                      style: AppTextStyles.label.copyWith(color: palette.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (remember != null) ...[
          const SizedBox(height: 16),
          RememberBox(text: remember),
        ],
      ],
    );
  }
}

class SummaryCardView extends StatelessWidget {
  const SummaryCardView({super.key, required this.card, required this.kept});

  final SummaryCard card;
  final int kept;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return CardBody(
      children: [
        CardKicker(icon: Icons.summarize_outlined, text: l10n.deckSummary),
        const SizedBox(height: 8),
        CardTitle(l10n.deckThreeLines),
        const SizedBox(height: 12),
        for (var i = 0; i < card.points.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox.square(
                  dimension: 24,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    card.points[i],
                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      color: palette.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (kept > 0) ...[
          const SizedBox(height: 16),
          RememberBox(
            label: l10n.deckKeptForRevision,
            icon: Icons.bookmark_rounded,
            text: kept == 1
                ? l10n.deckKeptRevisionOne
                : l10n.deckKeptRevisionMany(kept),
          ),
        ],
      ],
    );
  }
}
