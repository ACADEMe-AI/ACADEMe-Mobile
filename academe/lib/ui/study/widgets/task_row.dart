import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../core/themes/app_theme.dart';

class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.onOpen,
    required this.onToggle,
    this.showFolder = false,
  });

  final StudyTask task;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final bool showFolder;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isTodo = task.kind == TaskKind.todo;
    final subtitle = showFolder && task.folderName != null
        ? task.folderName!
        : task.subtitle;
    return Semantics(
      button: true,
      checked: task.isDone,
      child: InkWell(
        onTap: isTodo ? onToggle : onOpen,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _Lead(task: task),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelStrong.copyWith(
                        color: task.isDone ? palette.textMuted : palette.text,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
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
              if (task.minutes > 0 && !task.isDone)
                Text(
                  '${task.minutes} min',
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              if (!isTodo && !task.isDone)
                Icon(Icons.chevron_right_rounded, color: palette.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Lead extends StatelessWidget {
  const _Lead({required this.task});

  final StudyTask task;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isTodo = task.kind == TaskKind.todo;
    final icon = task.isDone
        ? Icons.check_rounded
        : switch (task.kind) {
            TaskKind.lesson => Icons.menu_book_rounded,
            TaskKind.test => Icons.quiz_outlined,
            TaskKind.review => Icons.replay_rounded,
            TaskKind.todo => null,
          };
    return SizedBox.square(
      dimension: isTodo ? 28 : 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: task.isDone
              ? palette.success
              : isTodo
              ? palette.surface
              : palette.tintLavender,
          borderRadius: BorderRadius.circular(isTodo ? 8 : AppRadius.md),
          border: Border.all(
            color: task.isDone ? palette.success : palette.edge,
            width: AppKeycap.borderWidth,
          ),
        ),
        child: icon == null
            ? null
            : Icon(
                icon,
                size: 18,
                color: task.isDone ? AppColors.onPrimary : AppColors.primary,
              ),
      ),
    );
  }
}
