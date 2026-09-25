import 'package:flutter/material.dart';

import '../../../domain/models/deck.dart';
import '../../core/themes/app_theme.dart';
import 'card_parts.dart';

class ExampleCardView extends StatelessWidget {
  const ExampleCardView({
    super.key,
    required this.card,
    required this.revealed,
    required this.tools,
  });

  final ExampleCard card;
  final int revealed;
  final Widget tools;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return CardBody(
      tools: tools,
      children: [
        const CardKicker(icon: Icons.edit_note_rounded, text: 'Worked example'),
        const SizedBox(height: 8),
        CardTitle(card.question, size: 19),
        const SizedBox(height: 12),
        for (var i = 0; i < card.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: i < revealed
                  ? _Step(
                      key: ValueKey('shown-$i'),
                      number: i + 1,
                      text: card.steps[i],
                    )
                  : DecoratedBox(
                      key: ValueKey('hidden-$i'),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: palette.border, width: 1.5),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: Center(
                          child: Text(
                            'Step ${i + 1} · try it first',
                            style: AppTextStyles.caption.copyWith(
                              color: palette.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({super.key, required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$number',
              style: AppTextStyles.labelStrong.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.label.copyWith(
                  fontSize: 16,
                  color: palette.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
