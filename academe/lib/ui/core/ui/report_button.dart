import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../../../utils/result.dart';
import '../themes/app_theme.dart';
import 'report_sheet.dart';

typedef ReportAnswer = Future<Result<void>> Function(ReportReason reason);

class ReportButton extends StatelessWidget {
  const ReportButton({
    super.key,
    required this.title,
    required this.thanks,
    required this.onReport,
    this.iconSize = 24,
  });

  final String title;
  final String thanks;
  final ReportAnswer onReport;
  final double iconSize;

  Future<void> _report(BuildContext context) async {
    final reason = await ReportSheet.show(context, title);
    if (reason == null) return;
    final result = await onReport(reason);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result is Ok ? thanks : 'Couldn’t send the report. Try again.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _report(context),
      tooltip: 'Report',
      visualDensity: VisualDensity.compact,
      iconSize: iconSize,
      color: context.palette.textMuted,
      icon: const Icon(Icons.flag_outlined),
    );
  }
}
