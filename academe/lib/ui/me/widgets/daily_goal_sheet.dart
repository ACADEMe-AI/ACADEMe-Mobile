import 'package:flutter/material.dart';

import '../../../domain/models/study_preferences.dart';
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
    return PickerSheet(
      title: 'Daily goal',
      note: 'Today’s steps on Home will add up to about $_minutes minutes.',
      onDone: () => Navigator.of(context).pop(_minutes),
      child: NumberWheel(
        values: StudyPreferences.dailyGoalChoices,
        value: _minutes,
        width: 200,
        semanticsLabel: 'Daily goal in minutes',
        label: (m) => '$m min',
        onChanged: (m) => setState(() => _minutes = m),
      ),
    );
  }
}
