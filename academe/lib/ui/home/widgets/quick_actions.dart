import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class QuickAction {
  const QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
      columnWidths: {
        for (var index = 1; index < actions.length * 2 - 1; index += 2)
          index: const FixedColumnWidth(8),
      },
      children: [
        TableRow(
          children: [
            for (final action in actions) ...[
              _ActionTile(action: action),
              if (action != actions.last) const SizedBox.shrink(),
            ],
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.surfaceRaised,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, size: 24, color: context.palette.text),
              const SizedBox(height: 4),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: context.palette.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
