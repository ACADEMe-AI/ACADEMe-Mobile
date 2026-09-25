import 'package:flutter/material.dart';

import '../../../domain/models/deck.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';
import '../../core/ui/screen_scale.dart';
import '../study_actions.dart';
import '../view_models/study_view_model.dart';
import 'pill_choices.dart';
import 'study_note.dart';

class CoursesView extends StatelessWidget {
  const CoursesView({
    super.key,
    required this.viewModel,
    required this.actions,
  });

  final StudyViewModel viewModel;
  final StudyActions actions;

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: viewModel.load.execute,
        child: ListView(
          padding: EdgeInsets.fromLTRB(padding, 0, padding, 120),
          children: [_CoursesBody(viewModel: viewModel, actions: actions)],
        ),
      ),
    );
  }
}

class _CoursesBody extends StatelessWidget {
  const _CoursesBody({required this.viewModel, required this.actions});

  final StudyViewModel viewModel;
  final StudyActions actions;

  @override
  Widget build(BuildContext context) {
    if (!viewModel.hasSyllabus) {
      return const StudyNote(
        'Set your class and board on Home to see your courses.',
      );
    }
    final next = viewModel.continueLesson;
    if (next == null && viewModel.allChapters.isEmpty) {
      if (viewModel.load.isRunning) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (viewModel.load.hasError) {
        return Center(
          child: TextButton(
            onPressed: viewModel.load.execute,
            child: const Text('Couldn’t load your courses. Retry'),
          ),
        );
      }
      return StudyNote(
        'Lessons for ${viewModel.syllabusLabel} are on their way. '
        'Ask Pebby anything in ASKMe meanwhile.',
      );
    }
    final chapters = viewModel.chapters;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          viewModel.syllabusLabel,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: context.palette.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        PillChoices(
          choices: [for (final s in viewModel.subjects) (s.id, s.name)],
          selected: viewModel.subject,
          onSelect: viewModel.selectSubject,
        ),
        const SizedBox(height: 16),
        if (next != null) ...[
          _ContinueKey(lesson: next, onTap: () => actions.openLesson(next.id)),
          const SizedBox(height: 16),
        ],
        PillChoices(
          choices: [for (final f in ChapterFilter.values) (f, f.label)],
          selected: viewModel.filter,
          onSelect: viewModel.selectFilter,
        ),
        const SizedBox(height: 8),
        if (chapters.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: StudyNote(
              viewModel.filter == ChapterFilter.done
                  ? 'Finished chapters show up here.'
                  : 'Chapters you’ve started show up here.',
            ),
          ),
        for (final chapter in chapters)
          ChapterRow(
            chapter: chapter,
            onTap: chapter.isComingSoon
                ? null
                : () => actions.openChapter(chapter.id),
          ),
      ],
    );
  }
}

class ChapterRow extends StatelessWidget {
  const ChapterRow({super.key, required this.chapter, required this.onTap});

  final StudyChapter chapter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final result = chapter.result;
    final soon = chapter.isComingSoon;
    final coming = chapter.lessonsComing > 0 && !soon
        ? ' · ${chapter.lessonsComing} coming soon'
        : '';
    final subtitle = soon
        ? chapter.lessonsPlanned == 0
              ? 'Coming soon'
              : 'Coming soon · ${chapter.lessonsPlanned} lessons'
        : chapter.isDone
        ? result == null
              ? 'Lessons done · test next$coming'
              : 'Done · test ${result.percent}%$coming'
        : '${chapter.lessonsDone} of ${chapter.lessons.length} lessons$coming';
    final ink = soon ? palette.textMuted : palette.text;
    final exam = chapter.isFormativeOnly ? ' · Not in board exam' : '';
    return Semantics(
      button: !soon,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      '${chapter.number}',
                      style: AppTextStyles.display.copyWith(
                        fontSize: 17,
                        color: ink,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelStrong.copyWith(color: ink),
                    ),
                    Text(
                      '$subtitle$exam',
                      style: AppTextStyles.caption.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (soon)
                Icon(Icons.schedule_rounded, color: palette.textMuted)
              else
                SizedBox.square(
                  dimension: 28,
                  child: CircularProgressIndicator(
                    value: chapter.progress,
                    strokeWidth: 4,
                    color: palette.success,
                    backgroundColor: palette.surfaceRaised,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueKey extends StatelessWidget {
  const _ContinueKey({required this.lesson, required this.onTap});

  final DeckSummary lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kicker = lesson.isDone
        ? 'Go again'
        : lesson.resumeCard > 0
        ? 'Continue · card ${lesson.resumeCard + 1} of ${lesson.cards}'
        : 'Start';
    return ContinueKey(
      kicker: kicker,
      title: lesson.title,
      subtitle: 'Ch ${lesson.chapterNumber} · ${lesson.chapterTitle}',
      onTap: onTap,
    );
  }
}

class ContinueKey extends StatelessWidget {
  const ContinueKey({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String kicker;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Keycap(
      face: AppColors.primary,
      depth: 4,
      height: 84,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kicker,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display.copyWith(
                      fontSize: 20,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.onPrimary,
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.play_arrow_rounded, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
