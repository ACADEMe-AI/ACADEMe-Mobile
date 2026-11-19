import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.dart') &&
            !f.path.endsWith('app_theme.dart') &&
            !f.path.endsWith('academe_wordmark.dart'),
      );

  test('no screen names a font family', () {
    final hits = [
      for (final f in files)
        for (final (i, line) in f.readAsLinesSync().indexed)
          if (line.contains('fontFamily')) '${f.path}:${i + 1}',
    ];
    expect(hits, isEmpty, reason: 'use the theme or Ac.display instead');
  });

  test('only bundled weights are used', () {
    final bad = RegExp(r'FontWeight\.w(100|200|300|500|700|900)\b');
    final hits = [
      for (final f in files)
        for (final (i, line) in f.readAsLinesSync().indexed)
          if (bad.hasMatch(line)) '${f.path}:${i + 1}',
    ];
    expect(hits, isEmpty, reason: 'bundled: w400/w600 body, w800 display');
  });
}
