import 'package:flutter/material.dart';

import '../../../../domain/models/board.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/ui/board_picker.dart';
import 'setup_step_frame.dart';

class BoardStep extends StatefulWidget {
  const BoardStep({
    super.key,
    required this.initial,
    required this.isLast,
    required this.isSaving,
    required this.onSubmit,
  });

  final Board? initial;
  final bool isLast;
  final bool isSaving;
  final ValueChanged<Board> onSubmit;

  @override
  State<BoardStep> createState() => _BoardStepState();
}

class _BoardStepState extends State<BoardStep> {
  late Board _board = widget.initial ?? Board.cbse;

  @override
  Widget build(BuildContext context) {
    return SetupStepFrame(
      title: 'Which board?',
      subtitle: 'We follow your board’s syllabus.',
      buttonLabel: widget.isLast ? 'Finish setup' : 'Continue',
      isSaving: widget.isSaving,
      onSubmit: () => widget.onSubmit(_board),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BoardPicker(
            value: _board,
            onChanged: (board) => setState(() => _board = board),
          ),
          const SizedBox(height: 16),
          Text(
            'State boards are coming soon.',
            style: AppTextStyles.caption.copyWith(
              color: context.palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
