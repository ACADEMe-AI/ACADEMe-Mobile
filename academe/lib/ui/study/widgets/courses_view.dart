import 'package:flutter/material.dart';

import '../../../domain/models/deck.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/screen_scale.dart';
import '../../core/ui/tab_bar_layout.dart';
import '../study_actions.dart';
import '../view_models/study_view_model.dart';
import 'active_filter_chips.dart';
import 'chapter_row.dart';
import 'continue_key.dart';
import 'pill_choices.dart';
import 'status_filter_row.dart';
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
          padding: EdgeInsets.fromLTRB(
            padding,
            0,
            padding,
            24 + TabBarLayout.scrollBottomPadding(context),
          ),
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
    final l10n = context.l10n;
    if (!viewModel.hasSyllabus) {
      return StudyNote(l10n.coursesNeedSyllabus);
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
            child: Text(l10n.coursesLoadError),
          ),
        );
      }
      return StudyNote(l10n.coursesComingSoon(viewModel.syllabusLabel));
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
          isOneRow: true,
        ),
        const SizedBox(height: 16),
        if (next != null) ...[
          _ContinueKey(lesson: next, onTap: () => actions.openLesson(next.id)),
          const SizedBox(height: 16),
        ],
        StatusFilterRow(
          status: viewModel.filter,
          onStatus: viewModel.selectFilter,
          filters: viewModel.filters,
          onFilters: viewModel.setFilters,
          count: viewModel.countWith,
        ),
        if (!viewModel.filters.isEmpty)
          ActiveFilterChips(
            filters: viewModel.filters,
            onChanged: viewModel.setFilters,
            count: chapters.length,
          ),
        const SizedBox(height: 8),
        if (chapters.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: StudyNote(
              !viewModel.filters.isEmpty
                  ? l10n.coursesNoFilterMatch
                  : viewModel.filter == ChapterFilter.done
                  ? l10n.coursesFinishedEmpty
                  : l10n.coursesStartedEmpty,
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

class _ContinueKey extends StatelessWidget {
  const _ContinueKey({required this.lesson, required this.onTap});

  final DeckSummary lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kicker = lesson.isDone
        ? l10n.coursesGoAgain
        : lesson.resumeCard > 0
        ? l10n.coursesContinueCard(lesson.resumeCard + 1, lesson.cards)
        : l10n.coursesStart;
    return ContinueKey(
      kicker: kicker,
      title: lesson.title,
      subtitle: l10n.studyChTitle(lesson.chapterNumber, lesson.chapterTitle),
      onTap: onTap,
    );
  }
}
