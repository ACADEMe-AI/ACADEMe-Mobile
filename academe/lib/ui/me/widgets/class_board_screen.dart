import 'package:flutter/material.dart';

import '../../../domain/models/board.dart';
import '../../../domain/models/subject.dart';
import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/board_picker.dart';
import '../../core/ui/class_dial.dart';
import '../../core/ui/top_notice.dart';
import '../../subjects/view_models/subjects_view_model.dart';
import '../../subjects/widgets/subjects_sheet.dart';
import '../view_models/me_view_model.dart';
import 'settings_list.dart';
import 'settings_page.dart';

class ClassBoardScreen extends StatefulWidget {
  const ClassBoardScreen({super.key, required this.viewModel});

  final MeViewModel viewModel;

  @override
  State<ClassBoardScreen> createState() => _ClassBoardScreenState();
}

class _ClassBoardScreenState extends State<ClassBoardScreen> {
  late int _classLevel = widget.viewModel.profile.classLevel ?? 10;
  late Board _board = widget.viewModel.profile.board ?? Board.cbse;
  late final _picker = widget.viewModel.subjectsPicker();

  @override
  void initState() {
    super.initState();
    if (widget.viewModel.profile.hasSyllabus) _picker.load.execute();
  }

  @override
  void dispose() {
    _picker.dispose();
    super.dispose();
  }

  bool get _isChanged =>
      _classLevel != widget.viewModel.profile.classLevel ||
      _board != widget.viewModel.profile.board;

  Future<void> _save() async {
    final command = widget.viewModel.saveSyllabus;
    await command.execute((classLevel: _classLevel, board: _board));
    if (!mounted) return;
    switch (command.result) {
      case Ok():
        Navigator.of(
          context,
        ).pop(context.l10n.classBoardSavedSnack(_classLevel, _board.code));
      case Error(:final error):
        context.showTopNotice(
          failureMessage(error, context.l10n),
          kind: TopNoticeKind.error,
        );
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: widget.viewModel.saveSyllabus,
      builder: (context, _) => SettingsPage(
        title: l10n.meClassAndBoard,
        bottom: AppButton(
          label: widget.viewModel.saveSyllabus.isRunning
              ? l10n.authSaving
              : l10n.classBoardSave(_classLevel, _board.code),
          isPrimary: true,
          isEnabled: _isChanged && !widget.viewModel.saveSyllabus.isRunning,
          onTap: _save,
        ),
        children: [
          const SizedBox(height: 8),
          Text(
            l10n.classBoardYourClass,
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ClassDial(
              value: _classLevel,
              onChanged: (value) => setState(() => _classLevel = value),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.classBoardYourBoard,
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          BoardPicker(
            value: _board,
            onChanged: (board) => setState(() => _board = board),
          ),
          if (!_isChanged && widget.viewModel.profile.hasSyllabus)
            _SubjectSettings(picker: _picker),
          if (_isChanged) ...[
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.palette.tintCream,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.classBoardSwitchNote(_classLevel, _board.code),
                  style: AppTextStyles.label.copyWith(
                    color: context.palette.text,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubjectSettings extends StatelessWidget {
  const _SubjectSettings({required this.picker});

  final SubjectsViewModel picker;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: picker,
      builder: (context, _) {
        final picked = picker.savedSubjects;
        final names = [for (final s in picked ?? const <Subject>[]) s.name];
        return SettingsGroup(
          title: l10n.classBoardSubjects,
          children: [
            if (picker.isSenior)
              SettingsRow(
                label: l10n.classBoardStream,
                value: picker.savedStream?.name ?? l10n.meNotSet,
                onTap: () => SubjectsSheet.show(
                  context,
                  viewModel: picker,
                  onlyStream: true,
                ),
              ),
            SettingsRow(
              label: l10n.classBoardSubjects,
              value: picked == null
                  ? l10n.classBoardAllSubjects
                  : l10n.classBoardSubjectCount(names.length, names.join(', ')),
              onTap: () => SubjectsSheet.show(context, viewModel: picker),
            ),
          ],
        );
      },
    );
  }
}
