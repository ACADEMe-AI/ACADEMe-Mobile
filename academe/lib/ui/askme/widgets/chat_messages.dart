import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/pebby_peek.dart';
import '../../core/ui/reply_text.dart';
import 'reply_actions.dart';

class StudentBubble extends StatelessWidget {
  const StudentBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .78,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              topRight: Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(AppRadius.lg),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              text,
              style: AppTextStyles.label.copyWith(
                color: AppColors.onPrimary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PebbyMessage extends StatelessWidget {
  const PebbyMessage({super.key, required this.child, this.footer});

  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(top: 4), child: PebbyPeek()),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.palette.surfaceRaised,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(AppRadius.lg),
                    bottomRight: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: child,
                ),
              ),
              ?footer,
            ],
          ),
        ),
      ],
    );
  }
}

class PebbyReply extends StatelessWidget {
  const PebbyReply({
    super.key,
    required this.message,
    required this.onRate,
    required this.onRetry,
    required this.onReport,
    this.followUps = const [],
  });

  final ChatMessage message;
  final ValueChanged<int> onRate;
  final VoidCallback? onRetry;
  final ReportAnswer onReport;
  final List<FollowUp> followUps;

  @override
  Widget build(BuildContext context) {
    return PebbyMessage(
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReplyActions(
            message: message,
            onRate: onRate,
            onRetry: onRetry,
            onReport: onReport,
          ),
          if (followUps.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final followUp in followUps)
                  _FollowUpChip(followUp: followUp),
              ],
            ),
        ],
      ),
      child: ReplyText(message.body),
    );
  }
}

class FollowUp {
  const FollowUp({
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isHighlighted;
}

class _FollowUpChip extends StatelessWidget {
  const _FollowUpChip({required this.followUp});

  final FollowUp followUp;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: followUp.isHighlighted
          ? context.palette.tintAmber
          : context.palette.surfaceRaised,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: followUp.onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            followUp.label,
            style: AppTextStyles.caption.copyWith(
              color: context.palette.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class ThinkingBubble extends StatefulWidget {
  const ThinkingBubble({super.key});

  @override
  State<ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PebbyMessage(
      child: Semantics(
        label: 'Pebby is thinking',
        child: SizedBox(
          width: 32,
          height: 16,
          child: AnimatedBuilder(
            animation: _dots,
            builder: (context, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 3; i++)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.palette.textMuted.withValues(
                        alpha: ((_dots.value * 3 - i) % 3) < 1 ? 1 : .35,
                      ),
                    ),
                    child: const SizedBox.square(dimension: 6),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
