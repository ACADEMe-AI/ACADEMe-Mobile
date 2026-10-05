import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _germanWords = [
  'hol',
  'dir',
  'dein',
  'deine',
  'deinen',
  'deinem',
  'quellen',
  'ordner',
  'umbenennen',
  'verbessern',
  'verloren',
  'nochmal',
  'versuch',
  'wochenende',
  'schaffst',
  'komm',
  'woche',
  'deutschland',
  'diesem',
  'dieser',
  'keine',
  'noch',
  'fuer',
  'nicht',
  'mehr',
  'lernen',
  'fragen',
  'antwort',
  'einstellungen',
  'sprache',
  'abmelden',
  'speichern',
  'loeschen',
];

final _stringLiteral = RegExp(r"""(?:'([^'\n]{3,120})'|"([^"\n]{3,120})")""");

void main() {
  test('no German copy in lib/', () {
    final lib = Directory('lib');
    final offenders = <String>[];

    for (final f
        in lib
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (line.contains('import ') || line.contains('export ')) continue;
        for (final m in _stringLiteral.allMatches(line)) {
          final text = (m.group(1) ?? m.group(2))!;
          if (text.contains('/') || text.contains('assets')) continue;
          final copy = text
              .replaceAll(RegExp(r'\$\{[^}]*\}'), ' ')
              .replaceAll(RegExp(r'\$\w+'), ' ');
          final words = copy
              .toLowerCase()
              .split(RegExp(r'[^a-zäöüß]+'))
              .where((w) => w.isNotEmpty);
          final hits = words.where(_germanWords.contains).toList();
          if (hits.isEmpty) continue;
          offenders.add('${f.path}:${i + 1}  "$text"  <- ${hits.join(", ")}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'German copy found; the app ships in English:\n'
          '${offenders.join('\n')}',
    );
  });

  test('umlauts only appear in proper nouns', () {
    final allowed = {'Türkiye'};
    final offenders = <String>[];
    for (final f
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (!RegExp(r'[äöüÄÖÜß]').hasMatch(lines[i])) continue;
        if (allowed.any(lines[i].contains)) continue;
        offenders.add('${f.path}:${i + 1}  ${lines[i].trim()}');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
