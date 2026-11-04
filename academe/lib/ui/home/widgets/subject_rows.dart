import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/subject_icons.dart';
import '../../study/view_models/study_view_model.dart';

class SubjectRows extends StatelessWidget {
  const SubjectRows({
    super.key,
    required this.study,
    required this.hasSyllabus,
    required this.onEdit,
    required this.onOpen,
  });

  final StudyViewModel study;
  final bool hasSyllabus;
  final VoidCallback onEdit;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your subjects',
                style: AppTextStyles.subhead.copyWith(
                  fontSize: 16,
                  color: palette.text,
                ),
              ),
            ),
            if (hasSyllabus)
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(48, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Edit', style: AppTextStyles.labelStrong),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (!hasSyllabus)
          const _Placeholder('Set your class and board to see your subjects')
        else
          ListenableBuilder(
            listenable: study,
            builder: (context, _) {
              final rows = study.subjectRows;
              if (rows.isEmpty) {
                return _Placeholder(
                  study.load.isRunning
                      ? 'Loading your subjects…'
                      : 'Your subjects show up here soon.',
                );
              }
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg + 2),
                  border: Border.all(color: palette.border, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      for (final (i, row) in rows.indexed) ...[
                        if (i > 0) Divider(height: 1, color: palette.border),
                        _SubjectRow(row: row, onTap: () => onOpen(row.id)),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.row, required this.onTap});

  final SubjectRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final next = row.next;
    final subtitle = next != null
        ? 'Next: Ch ${next.chapterNumber} · ${next.title}'
        : row.hasLessons
        ? 'All lessons done'
        : 'Lessons coming soon';
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.tints[row.tint % palette.tints.length],
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    SubjectIcons.of(row.id),
                    size: 20,
                    color: palette.text,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.name,
                      style: AppTextStyles.labelStrong.copyWith(
                        color: palette.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (row.hasLessons)
                SizedBox.square(
                  dimension: 28,
                  child: CircularProgressIndicator(
                    value: row.progress,
                    strokeWidth: 4,
                    color: palette.success,
                    backgroundColor: palette.surfaceRaised,
                  ),
                )
              else
                Icon(Icons.schedule_rounded, color: palette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.palette.border, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(color: context.palette.textMuted),
        ),
      ),
    );
  }
}
