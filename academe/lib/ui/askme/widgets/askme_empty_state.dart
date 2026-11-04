import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
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

  static const _lines = {
    ChatMode.explain: 'Pebby explains it simply, step by step.',
    ChatMode.solve: 'Pebby gives hints. You solve it.',
    ChatMode.quiz: 'Pebby asks, you answer, you earn XP.',
  };

  static const _suggestions = {
    ChatMode.explain: [
      'Explain reflection of light simply',
      'Why is the sky blue?',
      'What is photosynthesis?',
    ],
    ChatMode.solve: [
      'Help me solve 2x + 3y = 11 and x − 2y = −12',
      'Find the area of a circle with r = 7 cm',
      'Balance H₂ + O₂ → H₂O',
    ],
    ChatMode.quiz: [
      'Quiz me on Light',
      'Give me 5 questions on linear equations',
      'Quiz me on the French Revolution',
    ],
  };

  @override
  Widget build(BuildContext context) {
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
                'What are we studying, $name?',
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
                  line: _lines[mode]!,
                  suggestions: _suggestions[mode]!,
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
