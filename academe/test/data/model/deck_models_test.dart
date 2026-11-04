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
          'formativeOnly': true,
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
    expect(chapter.isFormativeOnly, isTrue);
    expect(chapter.lessons.single.isAvailable, isFalse);
    expect(studyCatalogueFromJson({'decks': <Object?>[]}).chapters, isEmpty);
  });

  test('the catalogue reads subject counts, minutes and revision due', () {
    final catalogue = studyCatalogueFromJson({
      'decks': [
        {
          'id': 'd1',
          'chapterId': 'cbse-10-science-9',
          'subject': 'science',
          'subjectName': 'Science',
          'chapterNumber': 9,
          'chapterTitle': 'Light',
          'position': 1,
          'title': 'Reflection',
          'cards': 7,
          'quizzes': 2,
          'minutes': 5,
          'done': false,
          'correct': 0,
        },
      ],
      'chapters': [
        {
          'id': 'cbse-10-science-9',
          'subject': 'science',
          'number': 9,
          'title': 'Light',
          'marks': 7,
          'revisionDue': 3,
          'lastStudiedAt': '2026-10-03T09:00:00Z',
          'lessons': [
            {
              'id': 'd1',
              'position': 1,
              'title': 'Reflection',
              'available': true,
              'minutes': 5,
            },
          ],
        },
      ],
      'subjects': [
        {
          'id': 'science',
          'name': 'Science',
          'chapters': 14,
          'lessonsAvailable': 4,
          'lessonsDone': 1,
        },
      ],
    });
    final chapter = catalogue.chapters.single;
    expect(catalogue.decks.single.minutes, 5);
    expect(chapter.lessons.single.minutes, 5);
    expect(chapter.marks, 7);
    expect(chapter.revisionDue, 3);
    expect(chapter.lastStudiedAt, DateTime.utc(2026, 10, 3, 9));
    final science = catalogue.subjects.single;
    expect(science.chapters, 14);
    expect(science.progress, .25);
    expect(studyCatalogueFromJson({'decks': <Object?>[]}).subjects, isEmpty);
  });
}
