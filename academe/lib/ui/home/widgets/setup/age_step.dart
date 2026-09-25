import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/ui/number_wheel.dart';
import 'setup_step_frame.dart';

class AgeStep extends StatefulWidget {
  const AgeStep({
    super.key,
    required this.initial,
    required this.isSaving,
    required this.onSubmit,
    this.now,
  });

  final int? initial;
  final bool isSaving;
  final ValueChanged<int> onSubmit;
  final DateTime? now;

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  static const _youngest = 9;
  static const _oldest = 20;
  static const _typical = 15;

  late final int _thisYear = (widget.now ?? DateTime.now()).year;
  late final List<int> _years = [
    for (var year = _thisYear - _oldest; year <= _thisYear - _youngest; year++)
      year,
  ];
  late int _year = widget.initial ?? _thisYear - _typical;
  @override
  Widget build(BuildContext context) {
    return SetupStepFrame(
      title: 'When were you born?',
      subtitle: 'So we keep things right for your age.',
      buttonLabel: 'Continue',
      isSaving: widget.isSaving,
      onSubmit: () => widget.onSubmit(_year),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NumberWheel(
            values: _years,
            value: _year,
            label: (year) => '$year',
            semanticsLabel: 'Birth year',
            onChanged: (year) => setState(() => _year = year),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.palette.tintLavender,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'You’re ${_thisYear - _year}.',
                style: AppTextStyles.labelStrong.copyWith(
                  color: context.palette.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
