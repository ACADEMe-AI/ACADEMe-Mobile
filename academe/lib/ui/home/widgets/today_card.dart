import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../core/themes/app_theme.dart';
import '../../study/widgets/task_row.dart';
import '../view_models/today_view_model.dart';

class TodayCard extends StatelessWidget {
  const TodayCard({super.key, required this.viewModel, required this.onOpen});

  final TodayViewModel viewModel;
  final ValueChanged<StudyTask> onOpen;

  static const shown = 5;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final plan = viewModel.plan;
        if (plan.tasks.isEmpty) return const SizedBox(width: double.infinity);
        final palette = context.palette;
        final folders = {
          for (final t in plan.tasks)
            if (t.folderId != null) t.folderId,
        }.length;
        final minutes = plan.minutesLeft;
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.tintCream,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: palette.edge,
                width: AppKeycap.borderWidth,
              ),
              boxShadow: [
                BoxShadow(color: palette.edge, offset: const Offset(0, 3)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        minutes > 0
                            ? 'Today · $minutes min'
                            : 'Today · all done',
                        style: AppTextStyles.display.copyWith(
                          fontSize: 19,
                          color: palette.text,
                        ),
                      ),
                      const Spacer(),
                      if (folders > 0)
                        Text(
                          folders == 1
                              ? 'from 1 folder'
                              : 'from $folders folders',
                          style: AppTextStyles.caption.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                    ],
                  ),
                  for (final task in plan.tasks.take(TodayCard.shown))
                    TaskRow(
                      task: task,
                      showFolder: true,
                      onOpen: () => onOpen(task),
                      onToggle: () => viewModel.toggleTodo(task),
                    ),
                  if (plan.tasks.length > TodayCard.shown)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'and ${plan.tasks.length - TodayCard.shown} more in your folders',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
