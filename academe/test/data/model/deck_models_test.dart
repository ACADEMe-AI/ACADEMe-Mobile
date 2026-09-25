import 'dart:convert';
import 'dart:io';

import 'package:academe/data/model/deck_models.dart';
import 'package:academe/domain/models/deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every approved server deck parses into a playable lesson', () {
    final files = Directory('server/internal/study/decks')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) => f.path.endsWith('.json') && !f.path.endsWith('.review.json'),
        )
        .toList();
    expect(files, isNotEmpty);
    for (final file in files) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final status = json['status'] as String? ?? 'approved';
      if (status != 'approved') continue;
      final deck = deckFromJson(json);
      expect(deck.cards.first, isA<StartCard>(), reason: file.path);
      expect(deck.cards.last, isA<SummaryCard>(), reason: file.path);
      for (final quiz in deck.cards.whereType<QuizCard>()) {
        expect(quiz.answer, inInclusiveRange(0, quiz.options.length - 1));
      }
    }
  });

  test('the catalogue reads chapters and tolerates an older server', () {
    final catalogue = studyCatalogueFromJson({
      'decks': <Object?>[],
      'chapters': [
        {
          'id': 'cbse-10-maths-1',
          'subject': 'maths',
          'subjectName': 'Maths',
          'number': 1,
          'title': 'Real Numbers',
          'unit': 'Number Systems',
          'lessons': [
            {
              'id': 'cbse-10-maths-1-1',
              'position': 1,
              'title': 'Prime factorisation',
              'available': false,
            },
          ],
        },
      ],
    });
    final chapter = catalogue.chapters.single;
    expect(chapter.unit, 'Number Systems');
    expect(chapter.lessons.single.isAvailable, isFalse);
    expect(studyCatalogueFromJson({'decks': <Object?>[]}).chapters, isEmpty);
  });
}
