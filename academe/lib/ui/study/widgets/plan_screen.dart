import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../../utils/dates.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/screen_scale.dart';
import 'page_scaffold.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key, required this.folder});

  final FolderDetail folder;

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    final palette = context.palette;
    final due = folder.summary.dueOn;
    return StudyPage(
      title: folder.summary.name,
      child: ListView(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 24),
        children: [
          Text(
            due == null ? 'Plan' : 'Plan to ${shortDay(due)}',
            style: AppTextStyles.display.copyWith(
              fontSize: 26,
              color: palette.text,
            ),
          ),
          Text(
            'Made from the chapters in this folder. Missed something? It '
            'moves to the next day on its own.',
            style: AppTextStyles.label.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: 12),
          for (final (i, day) in folder.plan.indexed)
            _PlanDayRow(
              day: day,
              isToday: i == 0,
              isDue: due != null && dateOnly(day.day) == dateOnly(due),
            ),
        ],
      ),
    );
  }
}

class _PlanDayRow extends StatelessWidget {
  const _PlanDayRow({
    required this.day,
    required this.isToday,
    required this.isDue,
  });

  final PlanDay day;
  final bool isToday;
  final bool isDue;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final lines = isDue
        ? [('Test day · you’re ready', false)]
        : day.tasks.isEmpty
        ? [('Rest day', false)]
        : [for (final t in day.tasks) (t.title, t.isDone)];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Column(
                children: [
                  Text(
                    weekday(day.day).toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: palette.textMuted,
                    ),
                  ),
                  Text(
                    '${day.day.day}',
                    style: AppTextStyles.display.copyWith(
                      fontSize: 20,
                      color: isToday ? AppColors.primary : palette.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (title, isDone) in lines)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            isDue
                                ? Icons.star_rounded
                                : isDone
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 16,
                            color: isDue
                                ? AppColors.selected
                                : isDone
                                ? palette.success
                                : palette.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.label.copyWith(
                                color: palette.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
