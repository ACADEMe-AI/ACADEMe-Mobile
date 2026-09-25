import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../../utils/dates.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/screen_scale.dart';
import '../view_models/folders_view_model.dart';
import 'study_note.dart';

class FoldersView extends StatelessWidget {
  const FoldersView({
    super.key,
    required this.viewModel,
    required this.onOpen,
    required this.onNew,
  });

  final FoldersViewModel viewModel;
  final ValueChanged<String> onOpen;
  final VoidCallback onNew;

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
          children: [
            if (viewModel.folders.isEmpty && viewModel.load.isRunning)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else if (viewModel.folders.isEmpty)
              const StudyNote(
                'Make a folder for a test, your homework, or anything you’re '
                'preparing. Add a date and it plans your days.',
              ),
            for (final folder in viewModel.folders)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FolderTile(
                  folder: folder,
                  onTap: () => onOpen(folder.id),
                ),
              ),
            const SizedBox(height: 4),
            AppButton(
              label: 'New folder',
              icon: Icon(
                Icons.create_new_folder_outlined,
                color: context.palette.text,
              ),
              onTap: onNew,
            ),
          ],
        ),
      ),
    );
  }
}

class FolderIcon extends StatelessWidget {
  const FolderIcon({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.tintLavender,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          Icons.folder_rounded,
          size: size * .56,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class FolderTile extends StatelessWidget {
  const FolderTile({super.key, required this.folder, required this.onTap});

  final FolderSummary folder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final due = folder.dueOn;
    final subtitle = folder.todayLeft > 0
        ? '${folder.todayLeft} to do today'
        : folder.items == 0
        ? 'Empty'
        : 'Nothing left today';
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surface,
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const FolderIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelStrong.copyWith(
                          color: palette.text,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (due != null) DueTag(due: due),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DueTag extends StatelessWidget {
  const DueTag({super.key, required this.due});

  final DateTime due;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final days = dateOnly(due).difference(dateOnly(DateTime.now())).inDays;
    final isSoon = days <= 1;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSoon ? palette.tintRose : palette.tintAmber,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          dueLabel(due),
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w800,
            color: isSoon ? palette.errorInk : palette.text,
          ),
        ),
      ),
    );
  }
}
