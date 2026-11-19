import 'package:flutter/material.dart';

import '../../../domain/models/study_preferences.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/ui/number_wheel.dart';
import 'picker_sheet.dart';

class DailyGoalSheet extends StatefulWidget {
  const DailyGoalSheet({super.key, required this.minutes});

  final int minutes;

  static Future<int?> show(BuildContext context, {required int minutes}) =>
      PickerSheet.show<int>(
        context,
        builder: (_) => DailyGoalSheet(minutes: minutes),
      );

  @override
  State<DailyGoalSheet> createState() => _DailyGoalSheetState();
}

class _DailyGoalSheetState extends State<DailyGoalSheet> {
  late int _minutes = widget.minutes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PickerSheet(
      title: l10n.dailyGoalTitle,
      note: l10n.dailyGoalNote(_minutes),
      onDone: () => Navigator.of(context).pop(_minutes),
      child: NumberWheel(
        values: StudyPreferences.dailyGoalChoices,
        value: _minutes,
        width: 200,
        semanticsLabel: l10n.dailyGoalSemantics,
        label: l10n.dailyGoalMinutesLabel,
        onChanged: (m) => setState(() => _minutes = m),
      ),
    );
  }
}
