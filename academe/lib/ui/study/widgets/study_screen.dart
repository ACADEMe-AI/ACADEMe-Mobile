import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/screen_scale.dart';
import '../study_actions.dart';
import '../view_models/folders_view_model.dart';
import '../view_models/study_view_model.dart';
import 'courses_view.dart';
import 'folders_view.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({
    super.key,
    required this.viewModel,
    required this.folders,
    required this.actions,
    required this.onNewFolder,
  });

  final StudyViewModel viewModel;
  final FoldersViewModel folders;
  final StudyActions actions;
  final VoidCallback onNewFolder;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  bool _showsFolders = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load.execute();
    widget.folders.load.execute();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(padding, 12, padding, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Study',
                style: AppTextStyles.display.copyWith(
                  fontSize: 28,
                  color: context.palette.text,
                ),
              ),
              const SizedBox(height: 8),
              _Tabs(
                showsFolders: _showsFolders,
                onSelect: (v) => setState(() => _showsFolders = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: _showsFolders
              ? FoldersView(
                  viewModel: widget.folders,
                  onOpen: widget.actions.openFolder,
                  onNew: widget.onNewFolder,
                )
              : CoursesView(
                  viewModel: widget.viewModel,
                  actions: widget.actions,
                ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.showsFolders, required this.onSelect});

  final bool showsFolders;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final (value, label, icon) in [
              (false, 'Courses', Icons.menu_book_rounded),
              (true, 'Folders', Icons.folder_rounded),
            ])
              Expanded(
                child: Semantics(
                  button: true,
                  selected: value == showsFolders,
                  child: GestureDetector(
                    onTap: () => onSelect(value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 40,
                      decoration: BoxDecoration(
                        color: value == showsFolders
                            ? palette.surface
                            : palette.surfaceRaised,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: value == showsFolders
                                ? AppColors.primary
                                : palette.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: AppTextStyles.labelStrong.copyWith(
                              color: value == showsFolders
                                  ? AppColors.primary
                                  : palette.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
