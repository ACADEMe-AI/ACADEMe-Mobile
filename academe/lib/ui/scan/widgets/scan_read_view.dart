import 'package:flutter/material.dart';

import '../../../domain/models/scan.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/light_field.dart';
import '../../core/ui/screen_scale.dart';
import '../../study/widgets/pill_choices.dart';

class ScanReadView extends StatefulWidget {
  const ScanReadView({
    super.key,
    required this.scan,
    required this.onSolve,
    required this.onAsk,
    required this.onMark,
  });

  final Scan scan;
  final ValueChanged<String> onSolve;
  final ValueChanged<String> onAsk;
  final ValueChanged<String> onMark;

  @override
  State<ScanReadView> createState() => _ScanReadViewState();
}

class _ScanReadViewState extends State<ScanReadView> {
  late final _text = TextEditingController(text: widget.scan.text);
  final _extra = TextEditingController();

  static const _suggestions = [
    'Explain this simply',
    'Summarise it',
    'What are the key terms?',
  ];

  ScanMode get _mode => widget.scan.mode;

  @override
  void dispose() {
    _text.dispose();
    _extra.dispose();
    super.dispose();
  }

  void _go() {
    final text = _text.text.trim();
    switch (_mode) {
      case ScanMode.solve:
        widget.onSolve(text);
      case ScanMode.ask:
        final question = _extra.text.trim();
        widget.onAsk(
          [
            question.isEmpty ? _suggestions.first : question,
            'From my photo:',
            text,
          ].join('\n\n'),
        );
      case ScanMode.check:
        widget.onMark(_extra.text);
      case ScanMode.notes:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final padding = ScreenScale.of(context).pagePadding;
    final chapter = widget.scan.chapter;
    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, 32),
      children: [
        Text(
          switch (_mode) {
            ScanMode.check => 'Pebby read your answer',
            _ => 'Pebby read this',
          },
          style: AppTextStyles.display.copyWith(
            fontSize: 24,
            color: palette.text,
          ),
        ),
        Text(
          chapter.isEmpty
              ? 'Fix anything that’s wrong.'
              : '$chapter · fix anything that’s wrong.',
          style: AppTextStyles.label.copyWith(color: palette.textMuted),
        ),
        const SizedBox(height: 16),
        LightField(label: 'From your photo', controller: _text, maxLines: 10),
        if (_mode == ScanMode.check) ...[
          const SizedBox(height: 12),
          LightField(
            label: 'The question',
            hint: 'Only if it isn’t in the photo',
            controller: _extra,
            maxLines: 3,
          ),
        ],
        if (_mode == ScanMode.ask) ...[
          const SizedBox(height: 12),
          LightField(
            label: 'What do you want to know?',
            controller: _extra,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          PillChoices<String>(
            choices: [for (final s in _suggestions) (s, s)],
            selected: null,
            onSelect: (s) => _extra.text = s,
          ),
        ],
        const SizedBox(height: 20),
        ListenableBuilder(
          listenable: _text,
          builder: (context, _) => AppButton(
            label: switch (_mode) {
              ScanMode.solve => 'Solve this',
              ScanMode.check => 'Mark it',
              _ => 'Ask Pebby',
            },
            isPrimary: true,
            isEnabled: _text.text.trim().isNotEmpty,
            onTap: _go,
          ),
        ),
        if (_mode == ScanMode.solve) ...[
          const SizedBox(height: 8),
          Text(
            'Pebby gives you a hint first, then the steps.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: palette.textMuted),
          ),
        ],
      ],
    );
  }
}
