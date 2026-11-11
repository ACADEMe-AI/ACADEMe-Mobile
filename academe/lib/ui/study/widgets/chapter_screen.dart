import 'package:flutter/material.dart';

import '../../../domain/models/deck.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/screen_scale.dart';
import '../study_actions.dart';
import '../view_models/study_view_model.dart';
import 'continue_key.dart';
import 'page_scaffold.dart';
import 'planned_lesson_row.dart';

class ChapterScreen extends StatelessWidget {
  const ChapterScreen({
    super.key,
    required this.viewModel,
    required this.chapterId,
    required this.actions,
  });

  final StudyViewModel viewModel;
  final String chapterId;
  final StudyActions actions;

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final chapter = viewModel.chapter(chapterId);
        return StudyPage(
          title: chapter == null ? '' : l10n.chapterTitle(chapter.number),
          child: chapter == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
                  children: [
                    _ChapterHeader(chapter: chapter),
                    const SizedBox(height: 16),
                    if (!chapter.isComingSoon)
                      _ResumeKey(
                        chapter: chapter,
                        onTap: () => actions.openLesson(chapter.resume.id),
                      ),
                    SectionTitle(l10n.chapterLessons),
                    for (final entry in chapter.outline)
                      if (entry.lesson case final lesson?)
                        _LessonRow(
                          lesson: lesson,
                          isCurrent:
                              !chapter.isDone && lesson.id == chapter.resume.id,
                          onTap: () => actions.openLesson(lesson.id),
                        )
                      else
                        PlannedLessonRow(
                          position: entry.position,
                          title: entry.title,
                        ),
                    if (!chapter.isComingSoon) ...[
                      const SizedBox(height: 8),
                      LinkRow(
                        icon: Icons.quiz_outlined,
                        title: l10n.chapterTest,
                        subtitle: switch (chapter.result) {
                          final r? => l10n.chapterTestLast(r.correct, r.total),
                          null => l10n.chapterTestSubtitle(chapter.quizzes),
                        },
                        onTap: () => actions.openChapterTest(chapter.id),
                      ),
                      LinkRow(
                        icon: Icons.bookmark_rounded,
                        title: l10n.chapterKeptCards,
                        subtitle: chapter.kept == 0
                            ? l10n.chapterKeptEmpty
                            : l10n.chapterKeptCount(chapter.kept),
                        onTap: () => actions.openReview(chapter.id),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: l10n.folderAddTo,
                        icon: Icon(
                          Icons.create_new_folder_outlined,
                          color: context.palette.text,
                        ),
                        onTap: () => actions.addToFolder([chapter.id]),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.chapter});

  final StudyChapter chapter;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          chapter.title,
          style: AppTextStyles.display.copyWith(
            fontSize: 26,
            height: 1.1,
            color: palette.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          [
            l10n.studyLessonsDoneOf(
              chapter.lessonsDone,
              chapter.lessons.length,
            ),
            if (chapter.lessonsComing > 0)
              l10n.studyComingSoonCount(chapter.lessonsComing),
            if (chapter.isFormativeOnly) l10n.studyNotInBoardExam,
          ].join(' · '),
          style: AppTextStyles.caption.copyWith(color: palette.textMuted),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: chapter.progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(AppRadius.full),
          color: AppColors.primary,
          backgroundColor: palette.surfaceRaised,
        ),
      ],
    );
  }
}

class _ResumeKey extends StatelessWidget {
  const _ResumeKey({required this.chapter, required this.onTap});

  final StudyChapter chapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lesson = chapter.resume;
    return ContinueKey(
      kicker: chapter.isDone
          ? l10n.chapterAllDoneGoAgain
          : lesson.resumeCard > 0
          ? l10n.chapterResumeCard(lesson.resumeCard + 1, lesson.cards)
          : l10n.chapterNextLesson,
      title: lesson.title,
      subtitle: l10n.chapterLessonMeta(
        lesson.position,
        l10n.studyCardsCount(lesson.cards),
      ),
      onTap: onTap,
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.lesson,
    required this.isCurrent,
    required this.onTap,
  });

  final DeckSummary lesson;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    final progress = lesson.cards == 0 ? 0.0 : lesson.resumeCard / lesson.cards;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: lesson.isDone
                        ? palette.tintMint
                        : isCurrent
                        ? AppColors.selected
                        : palette.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: palette.edge,
                      width: AppKeycap.borderWidth,
                    ),
                  ),
                  child: Center(
                    child: lesson.isDone
                        ? Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: palette.success,
                          )
                        : Text(
                            '${lesson.position}',
                            style: AppTextStyles.display.copyWith(
                              fontSize: 17,
                              color: isCurrent
                                  ? AppColors.keycapEdge
                                  : palette.text,
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
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelStrong.copyWith(
                        color: palette.text,
                      ),
                    ),
                    Text(
                      lesson.isDone
                          ? l10n.chapterCardsRight(
                              l10n.studyCardsCount(lesson.cards),
                              lesson.correct,
                              lesson.quizzes,
                            )
                          : l10n.chapterCardsChecks(
                              l10n.studyCardsCount(lesson.cards),
                              l10n.studyQuickChecksCount(lesson.quizzes),
                            ),
                      style: AppTextStyles.caption.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                    if (!lesson.isDone && lesson.resumeCard > 0) ...[
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          color: AppColors.primary,
                          backgroundColor: palette.surfaceRaised,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
