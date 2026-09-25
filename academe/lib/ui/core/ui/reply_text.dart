import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class ReplyText extends StatelessWidget {
  const ReplyText(this.text, {super.key, this.color, this.fontSize});

  final String text;
  final Color? color;
  final double? fontSize;

  static final _numbered = RegExp(r'^(\d+)[.)]\s+(.*)$');
  static final _bullet = RegExp(r'^[-*•]\s+(.*)$');
  static final _heading = RegExp(r'^#{1,6}\s+(.*)$');

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.label.copyWith(
      color: color ?? context.palette.text,
      fontSize: fontSize,
      height: 1.45,
    );
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final raw in lines)
          if (raw.trim().isEmpty)
            const SizedBox(height: 4)
          else if (_numbered.firstMatch(raw.trim()) case final m?)
            _ListLine(marker: '${m[1]}.', text: m[2]!, style: style)
          else if (_bullet.firstMatch(raw.trim()) case final m?)
            _ListLine(marker: '•', text: m[1]!, style: style)
          else if (_heading.firstMatch(raw.trim()) case final m?)
            _Rich(m[1]!, style: style.copyWith(fontWeight: FontWeight.w600))
          else
            _Rich(raw.trim(), style: style),
      ],
    );
  }
}

class _ListLine extends StatelessWidget {
  const _ListLine({
    required this.marker,
    required this.text,
    required this.style,
  });

  final String marker;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20, child: Text(marker, style: style)),
          Expanded(child: _Rich(text, style: style)),
        ],
      ),
    );
  }
}

class _Rich extends StatelessWidget {
  const _Rich(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i].replaceAll('`', ''),
              style: i.isOdd
                  ? const TextStyle(fontWeight: FontWeight.w600)
                  : null,
            ),
        ],
      ),
    );
  }
}
