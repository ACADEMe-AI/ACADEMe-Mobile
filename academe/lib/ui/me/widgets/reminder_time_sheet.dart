import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/number_wheel.dart';
import 'picker_sheet.dart';

class ReminderTimeSheet extends StatefulWidget {
  const ReminderTimeSheet({
    super.key,
    required this.hour,
    required this.minute,
  });

  final int hour;
  final int minute;

  static Future<(int, int)?> show(
    BuildContext context, {
    required int hour,
    required int minute,
  }) => PickerSheet.show<(int, int)>(
    context,
    builder: (_) => ReminderTimeSheet(hour: hour, minute: minute),
  );

  @override
  State<ReminderTimeSheet> createState() => _ReminderTimeSheetState();
}

class _ReminderTimeSheetState extends State<ReminderTimeSheet> {
  static final _hours = [for (var h = 1; h <= 12; h++) h];
  static final _minutes = [for (var m = 0; m < 60; m += 5) m];

  late int _hour12 = widget.hour % 12 == 0 ? 12 : widget.hour % 12;
  late int _minute = widget.minute - widget.minute % 5;
  late bool _isPm = widget.hour >= 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PickerSheet(
      title: l10n.reminderTimeTitle,
      onDone: () =>
          Navigator.of(context).pop((_hour12 % 12 + (_isPm ? 12 : 0), _minute)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumberWheel(
            values: _hours,
            value: _hour12,
            width: 80,
            semanticsLabel: l10n.reminderHour,
            label: (h) => '$h',
            onChanged: (h) => setState(() => _hour12 = h),
          ),
          Text(
            ':',
            style: AppTextStyles.display.copyWith(
              fontSize: 32,
              color: context.palette.text,
            ),
          ),
          NumberWheel(
            values: _minutes,
            value: _minute,
            width: 80,
            semanticsLabel: l10n.reminderMinute,
            label: (m) => m.toString().padLeft(2, '0'),
            onChanged: (m) => setState(() => _minute = m),
          ),
          NumberWheel(
            values: const [false, true],
            value: _isPm,
            width: 72,
            semanticsLabel: l10n.reminderAmPm,
            label: (pm) => pm ? l10n.reminderPm : l10n.reminderAm,
            onChanged: (pm) => setState(() => _isPm = pm),
          ),
        ],
      ),
    );
  }
}
