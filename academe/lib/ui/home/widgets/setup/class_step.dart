import 'package:flutter/material.dart';

import '../../../core/ui/class_dial.dart';
import 'setup_step_frame.dart';

class ClassStep extends StatefulWidget {
  const ClassStep({
    super.key,
    required this.initial,
    required this.isSaving,
    required this.onSubmit,
  });

  final int? initial;
  final bool isSaving;
  final ValueChanged<int> onSubmit;

  @override
  State<ClassStep> createState() => _ClassStepState();
}

class _ClassStepState extends State<ClassStep> {
  static const _typical = 9;

  late int _classLevel = widget.initial ?? _typical;

  @override
  Widget build(BuildContext context) {
    return SetupStepFrame(
      title: 'Spin to your class',
      subtitle: 'Turn the dial or tap a number.',
      buttonLabel: 'I’m in Class $_classLevel',
      isSaving: widget.isSaving,
      onSubmit: () => widget.onSubmit(_classLevel),
      body: ClassDial(
        value: _classLevel,
        onChanged: (value) => setState(() => _classLevel = value),
      ),
    );
  }
}
