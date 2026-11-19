import 'package:flutter/material.dart';

import '../../../domain/models/scan.dart';
import '../../core/l10n/app_l10n.dart';
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

  ScanMode get _mode => widget.scan.mode;

  List<(String, String)> _suggestions(AppLocalizations l10n) => [
    (l10n.scanSuggestExplain, l10n.scanSuggestExplain),
    (l10n.scanSuggestSummarise, l10n.scanSuggestSummarise),
    (l10n.scanSuggestKeyTerms, l10n.scanSuggestKeyTerms),
  ];

  @override
  void dispose() {
    _text.dispose();
    _extra.dispose();
    super.dispose();
  }

  void _go() {
    final l10n = context.l10n;
    final text = _text.text.trim();
    switch (_mode) {
      case ScanMode.solve:
        widget.onSolve(text);
      case ScanMode.ask:
        final question = _extra.text.trim();
        widget.onAsk(
          [
            question.isEmpty ? l10n.scanSuggestExplain : question,
            l10n.scanFromMyPhoto,
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
    final l10n = context.l10n;
    final padding = ScreenScale.of(context).pagePadding;
    final chapter = widget.scan.chapter;
    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, 32),
      children: [
        Text(
          switch (_mode) {
            ScanMode.check => l10n.checkPebbyReadAnswer,
            _ => l10n.scanPebbyReadThis,
          },
          style: AppTextStyles.display.copyWith(
            fontSize: 24,
            color: palette.text,
          ),
        ),
        Text(
          chapter.isEmpty ? l10n.scanFixAnything : l10n.scanChapterFix(chapter),
          style: AppTextStyles.label.copyWith(color: palette.textMuted),
        ),
        const SizedBox(height: 16),
        LightField(
          label: l10n.scanFromYourPhoto,
          controller: _text,
          maxLines: 10,
        ),
        if (_mode == ScanMode.check) ...[
          const SizedBox(height: 12),
          LightField(
            label: l10n.checkTheQuestion,
            hint: l10n.checkQuestionHint,
            controller: _extra,
            maxLines: 3,
          ),
        ],
        if (_mode == ScanMode.ask) ...[
          const SizedBox(height: 12),
          LightField(
            label: l10n.scanWhatDoYouWant,
            controller: _extra,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          PillChoices<String>(
            choices: _suggestions(l10n),
            selected: null,
            onSelect: (s) => _extra.text = s,
          ),
        ],
        const SizedBox(height: 20),
        ListenableBuilder(
          listenable: _text,
          builder: (context, _) => AppButton(
            label: switch (_mode) {
              ScanMode.solve => l10n.scanSolveThis,
              ScanMode.check => l10n.checkMarkIt,
              _ => l10n.scanAskPebby,
            },
            isPrimary: true,
            isEnabled: _text.text.trim().isNotEmpty,
            onTap: _go,
          ),
        ),
        if (_mode == ScanMode.solve) ...[
          const SizedBox(height: 8),
          Text(
            l10n.scanHintFirst,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: palette.textMuted),
          ),
        ],
      ],
    );
  }
}
