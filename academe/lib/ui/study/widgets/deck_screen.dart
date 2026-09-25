import 'package:flutter/material.dart';

import '../../../domain/models/deck.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../view_models/deck_view_model.dart';
import 'card_parts.dart';
import 'chapter_report_view.dart';
import 'deck_done_view.dart';
import 'deck_top_bar.dart';
import 'example_card_view.dart';
import 'lesson_cards.dart';
import 'quiz_cards.dart';
import 'swipe_deck.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({
    super.key,
    required this.viewModel,
    required this.onAsk,
    this.nextTitle,
    this.onNext,
    this.onRevise,
    this.onAddToFolder,
  });

  final DeckViewModel viewModel;
  final ValueChanged<String> onAsk;
  final String? nextTitle;
  final VoidCallback? onNext;
  final VoidCallback? onRevise;
  final VoidCallback? onAddToFolder;

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  DeckViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load.execute();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: context.palette.systemBars,
      child: Scaffold(
        backgroundColor: context.palette.surface,
        body: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (!_viewModel.isLoaded) {
                return DeckLoading(
                  hasError: _viewModel.load.hasError,
                  onRetry: _viewModel.load.execute,
                  onClose: _close,
                );
              }
              if (_viewModel.isFinished && _viewModel.isChapterTest) {
                return ChapterReportView(
                  title: _viewModel.title,
                  correct: _viewModel.correctCount,
                  total: _viewModel.quizCount,
                  xp: _viewModel.xpEarned,
                  scores: _viewModel.lessonScores,
                  onRevise: widget.onRevise,
                  onAddToFolder: widget.onAddToFolder,
                  onClose: _close,
                );
              }
              if (_viewModel.isFinished) {
                return DeckDoneView(
                  title: _viewModel.title,
                  correct: _viewModel.correctCount,
                  quizzes: _viewModel.quizCount,
                  xp: _viewModel.xpEarned,
                  kept: _viewModel.keptCount,
                  nextTitle: widget.nextTitle,
                  onNext: widget.onNext,
                  onClose: _close,
                );
              }
              return _DeckPlayer(
                viewModel: _viewModel,
                onClose: _close,
                onAsk: widget.onAsk,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeckPlayer extends StatelessWidget {
  const _DeckPlayer({
    required this.viewModel,
    required this.onClose,
    required this.onAsk,
  });

  final DeckViewModel viewModel;
  final VoidCallback onClose;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DeckTopBar(
          title: viewModel.title,
          total: viewModel.cards.length,
          current: viewModel.step.card,
          onClose: onClose,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SwipeDeck(
              key: ValueKey(viewModel.index),
              hasUnder: viewModel.hasNext,
              canForward: viewModel.canGoForward,
              canBack: viewModel.canGoBack,
              onForward: viewModel.forward,
              onBack: viewModel.back,
              top: _StepCard(viewModel: viewModel, onAsk: onAsk),
            ),
          ),
        ),
        _DeckControls(viewModel: viewModel),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.viewModel, required this.onAsk});

  final DeckViewModel viewModel;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final step = viewModel.step;
    final at = step.card;
    final tools = CardTools(
      isKept: viewModel.isKept(at),
      onKeep: () => viewModel.toggleKeep(at),
      onAsk: () => onAsk(_question(viewModel.current.content)),
    );
    return switch (viewModel.current.content) {
      final QuizCard quiz when step.isWhy => WhyCardView(
        card: quiz,
        pick: viewModel.pickOf(at),
        tools: tools,
      ),
      final QuizCard quiz => QuizCardView(
        card: quiz,
        pick: viewModel.pickOf(at),
        result: viewModel.resultOf(at),
        onPick: viewModel.pick,
        kicker: viewModel.isChapterTest
            ? 'Question ${at + 1} of ${viewModel.cards.length}'
            : 'Quick check',
        streak: viewModel.streakAt(at),
        xp: viewModel.xpAt(at),
      ),
      final StartCard start => StartCardView(
        card: start,
        title: viewModel.title,
        cards: viewModel.cards.length,
        quizzes: viewModel.quizCount,
      ),
      final ConceptCard concept => ConceptCardView(card: concept, tools: tools),
      final TableCard table => TableCardView(card: table, tools: tools),
      final ExampleCard example => ExampleCardView(
        card: example,
        revealed: viewModel.revealedOf(at),
        tools: tools,
      ),
      final SummaryCard summary => SummaryCardView(
        card: summary,
        kept: viewModel.keptCount,
      ),
    };
  }

  static String _question(DeckCard card) => switch (card) {
    ConceptCard(:final title, :final body) =>
      'Can you explain this more simply? $title: $body',
    TableCard(:final title) => 'Can you explain "$title" with an example?',
    ExampleCard(:final question) => 'Can you explain how to solve: $question',
    QuizCard(:final question, :final why) =>
      'I got this wrong: $question Why is it: $why',
    _ => 'Can you explain this lesson?',
  };
}

class _DeckControls extends StatelessWidget {
  const _DeckControls({required this.viewModel});

  final DeckViewModel viewModel;

  String get _label {
    if (viewModel.current.content is StartCard) return 'Start';
    if (viewModel.hasHiddenStep) {
      return 'Show step ${viewModel.revealedOf(viewModel.step.card) + 1}';
    }
    if (viewModel.needsCheck) return 'Check';
    return viewModel.hasNext ? 'Next' : 'Finish';
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled =
        !viewModel.needsCheck || viewModel.pickOf(viewModel.step.card) != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Semantics(
              label: 'Previous card',
              child: AppButton(
                label: '',
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: context.palette.text,
                ),
                isEnabled: viewModel.canGoBack,
                onTap: viewModel.back,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: _label,
              isPrimary: true,
              isEnabled: isEnabled,
              onTap: viewModel.primary,
            ),
          ),
        ],
      ),
    );
  }
}
