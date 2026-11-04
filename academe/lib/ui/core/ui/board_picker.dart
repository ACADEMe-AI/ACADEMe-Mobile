import 'package:flutter/material.dart';

import '../../../domain/models/board.dart';
import '../themes/app_theme.dart';
import 'keycap.dart';

class BoardPicker extends StatelessWidget {
  const BoardPicker({super.key, required this.value, required this.onChanged});

  final Board value;
  final ValueChanged<Board> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, board) in Board.values.indexed) ...[
          if (index > 0) const SizedBox(width: 12),
          Expanded(
            child: Keycap(
              face: board == value
                  ? AppColors.selected
                  : context.palette.surface,
              depth: AppKeycap.optionDepth,
              height: 128,
              isLatched: board == value,
              onTap: () => onChanged(board),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      board.code,
                      style: AppTextStyles.display.copyWith(
                        fontSize: 28,
                        color: context.palette.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      board.fullName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: board == value
                            ? AppColors.selectedInk
                            : context.palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
