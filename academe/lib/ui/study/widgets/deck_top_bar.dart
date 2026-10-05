import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/report_button.dart';

class DeckTopBar extends StatelessWidget {
  const DeckTopBar({
    super.key,
    required this.title,
    required this.total,
    required this.current,
    required this.onClose,
    this.onReport,
  });

  final String title;
  final int total;
  final int current;
  final VoidCallback onClose;
  final ReportAnswer? onReport;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onClose,
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded),
                color: palette.text,
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelStrong.copyWith(
                    color: palette.text,
                  ),
                ),
              ),
              if (onReport case final report?)
                ReportButton(
                  title: 'Report this lesson',
                  thanks: 'Thanks. We’ll review this lesson.',
                  onReport: report,
                  iconSize: 20,
                ),
              Text(
                '${current + 1} / $total',
                style: AppTextStyles.caption.copyWith(color: palette.textMuted),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                for (var i = 0; i < total; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i < current
                            ? AppColors.primary
                            : i == current
                            ? AppColors.selected
                            : palette.border,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeckLoading extends StatelessWidget {
  const DeckLoading({
    super.key,
    required this.hasError,
    required this.onRetry,
    required this.onClose,
  });

  final bool hasError;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: hasError
              ? TextButton(
                  onPressed: onRetry,
                  child: const Text('Couldn’t load this lesson. Retry'),
                )
              : const CircularProgressIndicator(color: AppColors.primary),
        ),
        Positioned(
          left: 8,
          top: 4,
          child: IconButton(
            onPressed: onClose,
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            color: context.palette.text,
          ),
        ),
      ],
    );
  }
}
