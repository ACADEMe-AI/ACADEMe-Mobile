import 'package:flutter/material.dart';

import '../../../domain/models/board.dart';
import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/board_picker.dart';
import '../../core/ui/class_dial.dart';
import '../view_models/me_view_model.dart';
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
        ).pop('Now showing Class $_classLevel · ${_board.code} subjects');
      case Error(:final error):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failureMessage(error))));
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel.saveSyllabus,
      builder: (context, _) => SettingsPage(
        title: 'Class and board',
        bottom: AppButton(
          label: widget.viewModel.saveSyllabus.isRunning
              ? 'Saving…'
              : 'Save · Class $_classLevel · ${_board.code}',
          isPrimary: true,
          isEnabled: _isChanged && !widget.viewModel.saveSyllabus.isRunning,
          onTap: _save,
        ),
        children: [
          const SizedBox(height: 8),
          Text(
            'Your class',
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
            'Your board',
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          BoardPicker(
            value: _board,
            onChanged: (board) => setState(() => _board = board),
          ),
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
                  'Your subjects and plan will switch to Class $_classLevel · '
                  '${_board.code}. Everything you’ve done so far stays saved.',
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
