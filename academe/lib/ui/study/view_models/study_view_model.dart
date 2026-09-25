import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/study_repository.dart';
import '../../../domain/models/deck.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

typedef StudySubject = ({String id, String name});

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
  });

  final String id;
  final String subject;
  final int number;
  final String title;
  final String unit;
  final List<DeckSummary> lessons;
  final List<PlannedLesson> plan;
  final ChapterResult? result;

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

class StudyViewModel extends ChangeNotifier {
  StudyViewModel({
    required StudyRepository studyRepository,
    required ProfileRepository profileRepository,
  }) : _repository = studyRepository,
       _profiles = profileRepository {
    load = Command0(_load)..addListener(notifyListeners);
    _profiles.addListener(_onProfile);
    _syllabus = _syllabusKey;
  }

  final StudyRepository _repository;
  final ProfileRepository _profiles;

  late final Command0<void> load;

  List<DeckSummary> _decks = const [];
  List<PlannedChapter> _catalogue = const [];
  Map<String, ChapterResult> _results = const {};
  String? _subject;
  String? _syllabus;
  ChapterFilter _filter = ChapterFilter.all;

  bool get hasSyllabus => _profiles.profile?.hasSyllabus ?? false;
  ChapterFilter get filter => _filter;

  String get syllabusLabel {
    final profile = _profiles.profile;
    if (profile == null || !profile.hasSyllabus) return '';
    return 'Class ${profile.classLevel} · ${profile.board!.code}';
  }

  List<StudySubject> get subjects {
    final seen = <String>{};
    return [
      for (final c in _catalogue)
        if (seen.add(c.subject)) (id: c.subject, name: c.subjectName),
      for (final d in _decks)
        if (seen.add(d.subject)) (id: d.subject, name: d.subjectName),
    ];
  }

  String? get subject =>
      _subject ?? _decks.firstOrNull?.subject ?? subjects.firstOrNull?.id;

  List<StudyChapter> get allChapters {
    final byId = <String, StudyChapter>{};
    for (final c in _catalogue) {
      byId[c.id] = StudyChapter(
        id: c.id,
        subject: c.subject,
        number: c.number,
        title: c.title,
        unit: c.unit,
        plan: c.lessons,
        lessons: [],
        result: _results[c.id],
      );
    }
    for (final d in _decks) {
      byId
          .putIfAbsent(
            d.chapterId,
            () => StudyChapter(
              id: d.chapterId,
              subject: d.subject,
              number: d.chapterNumber,
              title: d.chapterTitle,
              lessons: [],
              result: _results[d.chapterId],
            ),
          )
          .lessons
          .add(d);
    }
    final order = [for (final s in subjects) s.id];
    return byId.values.toList()..sort(
      (a, b) => a.subject == b.subject
          ? a.number.compareTo(b.number)
          : order.indexOf(a.subject).compareTo(order.indexOf(b.subject)),
    );
  }

  List<StudyChapter> get chapters => [
    for (final c in allChapters)
      if (c.subject == subject &&
          switch (_filter) {
            ChapterFilter.all => true,
            ChapterFilter.inProgress => c.isStarted && !c.isDone,
            ChapterFilter.done => c.isDone,
          })
        c,
  ];

  StudyChapter? chapter(String id) =>
      allChapters.where((c) => c.id == id).firstOrNull;

  DeckSummary? lesson(String id) => _decks.where((d) => d.id == id).firstOrNull;

  DeckSummary? get continueLesson {
    final inSubject = [
      for (final d in _decks)
        if (d.subject == subject) d,
    ];
    return inSubject.where((d) => d.isStarted && !d.isDone).firstOrNull ??
        inSubject.where((d) => !d.isDone).firstOrNull ??
        inSubject.firstOrNull;
  }

  DeckSummary? nextAfter(String deckId) {
    final i = _decks.indexWhere((d) => d.id == deckId);
    if (i < 0 || i + 1 >= _decks.length) return null;
    final next = _decks[i + 1];
    return next.chapterId == _decks[i].chapterId ? next : null;
  }

  void selectSubject(String id) {
    if (_subject == id) return;
    _subject = id;
    notifyListeners();
  }

  void selectFilter(ChapterFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  String? get _syllabusKey {
    final profile = _profiles.profile;
    return profile == null || !profile.hasSyllabus
        ? null
        : '${profile.classLevel}-${profile.board!.code}';
  }

  void _onProfile() {
    final key = _syllabusKey;
    if (key == _syllabus) return;
    _syllabus = key;
    _subject = null;
    load.execute();
  }

  Future<Result<void>> _load() async {
    final (catalogue, results) = await (
      _repository.catalogue(),
      _repository.chapterResults(),
    ).wait;
    if (catalogue case Ok(:final value)) {
      _decks = value.decks;
      _catalogue = value.chapters;
    }
    if (results case Ok(:final value)) {
      _results = {for (final r in value) r.chapterId: r};
    }
    return catalogue;
  }

  @override
  void dispose() {
    _profiles.removeListener(_onProfile);
    load
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
