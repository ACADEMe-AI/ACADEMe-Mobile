import 'package:flutter/foundation.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/study_repository.dart';
import '../../../domain/models/deck.dart';
import '../../../domain/models/profile.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import 'chapter_filters.dart';
import 'study_chapter.dart';

export 'chapter_filters.dart';
export 'study_chapter.dart';

typedef StudySubject = ({String id, String name});

typedef SubjectRow = ({
  String id,
  String name,
  int tint,
  bool hasLessons,
  double progress,
  DeckSummary? next,
});

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
  List<SubjectProgress> _progress = const [];
  Map<String, ChapterResult> _results = const {};
  String? _subject;
  String? _syllabus;
  ChapterFilter _filter = ChapterFilter.all;
  ChapterFilters _filters = const ChapterFilters();
  bool _showsFolders = false;

  Profile get _profile => _profiles.profile ?? const Profile();
  bool get hasSyllabus => _profile.hasSyllabus;
  ChapterFilter get filter => _filter;
  ChapterFilters get filters => _filters;
  bool get showsFolders => _showsFolders;
  String get syllabusLabel => hasSyllabus ? _profile.syllabusLabel! : '';

  List<StudySubject> get allSubjects {
    final seen = <String>{};
    return [
      for (final s in _progress)
        if (seen.add(s.id)) (id: s.id, name: s.name),
      for (final c in _catalogue)
        if (seen.add(c.subject)) (id: c.subject, name: c.subjectName),
      for (final d in _decks)
        if (seen.add(d.subject)) (id: d.subject, name: d.subjectName),
    ];
  }

  List<StudySubject> get subjects {
    final withChapters = {
      for (final c in _catalogue) c.subject,
      for (final d in _decks) d.subject,
    };
    return [
      for (final s in allSubjects)
        if (withChapters.contains(s.id) && _profile.studies(s.id)) s,
    ];
  }

  String? get subject {
    final ids = [for (final s in subjects) s.id];
    if (ids.contains(_subject)) return _subject;
    return _decks.map((d) => d.subject).where(ids.contains).firstOrNull ??
        ids.firstOrNull;
  }

  List<SubjectRow> get subjectRows {
    final all = allSubjects;
    final progress = {for (final p in _progress) p.id: p};
    return [
      for (final (index, s) in all.indexed)
        if (_profile.studies(s.id))
          (
            id: s.id,
            name: s.name,
            tint: index,
            hasLessons: _decks.any((d) => d.subject == s.id),
            progress: progress[s.id]?.progress ?? 0,
            next: _nextIn(s.id),
          ),
    ];
  }

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
        isFormativeOnly: c.isFormativeOnly,
        marks: c.marks,
        revisionDue: c.revisionDue,
        lastStudiedAt: c.lastStudiedAt,
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
    final order = [for (final s in allSubjects) s.id];
    return byId.values.toList()..sort(
      (a, b) => a.subject == b.subject
          ? a.number.compareTo(b.number)
          : order.indexOf(a.subject).compareTo(order.indexOf(b.subject)),
    );
  }

  List<StudyChapter> chaptersFor(
    String? subject,
    ChapterFilter status,
    ChapterFilters filters,
  ) => filters.apply([
    for (final c in allChapters)
      if (c.subject == subject &&
          switch (status) {
            ChapterFilter.all => true,
            ChapterFilter.inProgress => c.isStarted && !c.isDone,
            ChapterFilter.done => c.isDone,
          })
        c,
  ]);

  List<StudyChapter> get chapters => chaptersFor(subject, _filter, _filters);

  int countWith(ChapterFilters filters) =>
      chaptersFor(subject, _filter, filters).length;

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

  DeckSummary? _nextIn(String subject) {
    final inSubject = _decks.where((d) => d.subject == subject);
    return inSubject.where((d) => d.isStarted && !d.isDone).firstOrNull ??
        inSubject.where((d) => !d.isDone).firstOrNull;
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

  void openSubject(String id) {
    _subject = id;
    _showsFolders = false;
    notifyListeners();
  }

  void showFolders(bool shows) {
    if (_showsFolders == shows) return;
    _showsFolders = shows;
    notifyListeners();
  }

  void selectFilter(ChapterFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setFilters(ChapterFilters filters) {
    _filters = filters;
    notifyListeners();
  }

  String? get _syllabusKey => _profile.syllabusLabel;

  void _onProfile() {
    final key = _syllabusKey;
    if (key == _syllabus) {
      notifyListeners();
      return;
    }
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
      _progress = value.subjects;
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
