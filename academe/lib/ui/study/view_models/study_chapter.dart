import 'dart:math' as math;

import '../../../domain/models/deck.dart';

typedef ChapterLesson = ({int position, String title, DeckSummary? lesson});

enum ChapterFilter {
  all('All'),
  inProgress('In progress'),
  done('Done');

  const ChapterFilter(this.label);

  final String label;
}

class StudyChapter {
  const StudyChapter({
    required this.id,
    required this.subject,
    required this.number,
    required this.title,
    required this.lessons,
    required this.result,
    this.unit = '',
    this.plan = const [],
    this.isFormativeOnly = false,
    this.marks = 0,
    this.revisionDue = 0,
    this.lastStudiedAt,
  });

  final String id;
  final String subject;
  final int number;
  final String title;
  final String unit;
  final List<DeckSummary> lessons;
  final List<PlannedLesson> plan;
  final ChapterResult? result;
  final bool isFormativeOnly;
  final int marks;
  final int revisionDue;
  final DateTime? lastStudiedAt;

  int get lessonsDone => lessons.where((l) => l.isDone).length;
  int get kept => lessons.fold(0, (sum, l) => sum + l.kept);
  int get quizzes => lessons.fold(0, (sum, l) => sum + l.quizzes);
  bool get isComingSoon => lessons.isEmpty;
  int get lessonsPlanned => math.max(outline.length, lessons.length);
  int get lessonsComing => lessonsPlanned - lessons.length;
  bool get isDone => !isComingSoon && lessonsDone == lessons.length;
  bool get isStarted => lessons.any((l) => l.isStarted);
  double get progress => lessons.isEmpty ? 0 : lessonsDone / lessons.length;

  List<ChapterLesson> get outline {
    final byId = {for (final l in lessons) l.id: l};
    final byPosition = {for (final l in lessons) l.position: l};
    final out = [
      for (final p in plan)
        (
          position: p.position,
          title: byId[p.id]?.title ?? byPosition[p.position]?.title ?? p.title,
          lesson: byId[p.id] ?? byPosition[p.position],
        ),
    ];
    final shown = {for (final o in out) o.lesson?.id};
    for (final l in lessons) {
      if (!shown.contains(l.id)) {
        out.add((position: l.position, title: l.title, lesson: l));
      }
    }
    return out..sort((a, b) => a.position.compareTo(b.position));
  }

  DeckSummary get resume =>
      lessons.where((l) => l.isStarted && !l.isDone).firstOrNull ??
      lessons.where((l) => !l.isDone).firstOrNull ??
      lessons.first;
}
