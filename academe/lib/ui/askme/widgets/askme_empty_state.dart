import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/screen_scale.dart';

class AskMeEmptyState extends StatelessWidget {
  const AskMeEmptyState({
    super.key,
    required this.name,
    required this.syllabus,
    required this.mode,
    required this.onAsk,
  });

  final String name;
  final String? syllabus;
  final ChatMode mode;
  final ValueChanged<String> onAsk;

  static const swap = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = {
      ChatMode.explain: l10n.askmeModeExplainLine,
      ChatMode.solve: l10n.askmeModeSolveLine,
      ChatMode.quiz: l10n.askmeModeQuizLine,
    };
    final suggestions = {
      ChatMode.explain: [
        l10n.askmeSuggestExplain1,
        l10n.askmeSuggestExplain2,
        l10n.askmeSuggestExplain3,
      ],
      ChatMode.solve: [
        l10n.askmeSuggestSolve1,
        l10n.askmeSuggestSolve2,
        l10n.askmeSuggestSolve3,
      ],
      ChatMode.quiz: [
        l10n.askmeSuggestQuiz1,
        l10n.askmeSuggestQuiz2,
        l10n.askmeSuggestQuiz3,
      ],
    };
    final padding = ScreenScale.of(context).pagePadding;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, 16, padding, 16 + bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 32 - bottom).clamp(
              0,
              double.infinity,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: SizedBox.square(
                  dimension: 180,
                  child: Pebby(pose: PebbyPose.reading),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.askmeStudying(name),
                textAlign: TextAlign.center,
                style: AppTextStyles.display.copyWith(
                  fontSize: 24,
                  color: context.palette.text,
                ),
              ),
              if (syllabus case final text?)
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : swap,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(0, .08), end: Offset.zero),
                    ),
                    child: child,
                  ),
                ),
                child: _ModeContent(
                  key: ValueKey(mode),
                  line: lines[mode]!,
                  suggestions: suggestions[mode]!,
                  onAsk: onAsk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeContent extends StatelessWidget {
  const _ModeContent({
    super.key,
    required this.line,
    required this.suggestions,
    required this.onAsk,
  });

  final String line;
  final List<String> suggestions;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text(
          line,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: context.palette.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        for (final suggestion in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: context.palette.surfaceRaised,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: InkWell(
                onTap: () => onAsk(suggestion),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    suggestion,
                    style: AppTextStyles.labelStrong.copyWith(
                      color: context.palette.text,
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
