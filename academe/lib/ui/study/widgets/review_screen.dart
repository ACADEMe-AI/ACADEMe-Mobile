import 'package:flutter/material.dart';

import '../../../domain/models/deck.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/celebration.dart';
import '../../core/ui/keycap.dart';
import '../../core/ui/pebby.dart';
import '../view_models/review_view_model.dart';
import 'card_parts.dart';
import 'deck_top_bar.dart';
import 'swipe_deck.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.viewModel});

  final ReviewViewModel viewModel;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  ReviewViewModel get _viewModel => widget.viewModel;

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
              if (_viewModel.load.isRunning) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (_viewModel.items.isEmpty) {
                return _ReviewEnd(
                  title: 'Nothing to revise',
                  text:
                      'Keep cards in a lesson, or miss a question, and they '
                      'come back here.',
                  onClose: _close,
                );
              }
              if (_viewModel.isFinished) {
                return _ReviewEnd(
                  isDone: true,
                  title: 'Revision done',
                  text:
                      '${_viewModel.countOf(ReviewRating.knew)} knew it · '
                      '${_viewModel.countOf(ReviewRating.almost)} almost · '
                      '${_viewModel.countOf(ReviewRating.again)} to see again '
                      'tomorrow',
                  onClose: _close,
                );
              }
              return _ReviewPlayer(viewModel: _viewModel, onClose: _close);
            },
          ),
        ),
      ),
    );
  }
}

class _ReviewPlayer extends StatelessWidget {
  const _ReviewPlayer({required this.viewModel, required this.onClose});

  final ReviewViewModel viewModel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final item = viewModel.current;
    final (front, back) = _faces(item.content);
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DeckTopBar(
          title: 'Revision',
          total: viewModel.items.length,
          current: viewModel.index,
          onClose: onClose,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: GestureDetector(
              onTap: viewModel.reveal,
              child: DeckCardFrame(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CardKicker(
                        icon: item.isMissed
                            ? Icons.replay_rounded
                            : Icons.bookmark_rounded,
                        text: '${item.lessonTitle} · ${item.chapterTitle}',
                      ),
                      const SizedBox(height: 8),
                      CardTitle(front, size: 21),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: viewModel.isRevealed
                            ? Text(
                                back,
                                key: const ValueKey('back'),
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 16,
                                  height: 1.45,
                                  color: palette.text,
                                ),
                              )
                            : Text(
                                'Think of the answer, then tap to check.',
                                key: const ValueKey('front'),
                                style: AppTextStyles.label.copyWith(
                                  color: palette.textMuted,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: viewModel.isRevealed
              ? Row(
                  children: [
                    for (final (i, rating) in ReviewRating.values.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _RatingKey(
                          rating: rating,
                          onTap: () => viewModel.rate(rating),
                        ),
                      ),
                    ],
                  ],
                )
              : AppButton(
                  label: 'Show answer',
                  isPrimary: true,
                  onTap: viewModel.reveal,
                ),
        ),
      ],
    );
  }

  static (String, String) _faces(DeckCard card) => switch (card) {
    ConceptCard(:final title, :final body) => (title, body),
    TableCard(:final title, :final rows) => (
      title,
      rows.map((r) => '${r.$1}: ${r.$2}').join('\n'),
    ),
    ExampleCard(:final question, :final steps) => (question, steps.join('\n')),
    QuizCard(:final question, :final options, :final answer, :final why) => (
      question,
      '${options[answer]}\n\n$why',
    ),
    SummaryCard(:final points) => (
      'The lesson in three lines',
      points.join('\n'),
    ),
    StartCard(:final goals) => ('Goals', goals.join('\n')),
  };
}

class _RatingKey extends StatelessWidget {
  const _RatingKey({required this.rating, required this.onTap});

  final ReviewRating rating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Keycap(
      face: switch (rating) {
        ReviewRating.again => palette.tintRose,
        ReviewRating.almost => palette.tintAmber,
        ReviewRating.knew => palette.tintMint,
      },
      depth: 4,
      height: 54,
      onTap: onTap,
      child: Center(
        child: Text(
          rating.label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelStrong.copyWith(color: palette.text),
        ),
      ),
    );
  }
}

class _ReviewEnd extends StatelessWidget {
  const _ReviewEnd({
    this.isDone = false,
    required this.title,
    required this.text,
    required this.onClose,
  });

  final bool isDone;
  final String title;
  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
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
                if (isDone)
                  const Burst(
                    size: 240,
                    dots: 14,
                    duration: Duration(milliseconds: 900),
                  ),
                const SizedBox.square(
                  dimension: 160,
                  child: Pebby(pose: PebbyPose.happy),
                ),
              ],
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.display.copyWith(
              fontSize: 26,
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
            ),
          ),
          const Spacer(),
          AppButton(label: 'Done', isPrimary: true, onTap: onClose),
        ],
      ),
    );
  }
}
