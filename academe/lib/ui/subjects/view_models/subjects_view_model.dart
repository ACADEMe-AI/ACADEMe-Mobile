import 'package:flutter/foundation.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/profile.dart';
import '../../../domain/models/study_stream.dart';
import '../../../domain/models/subject.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

enum SubjectsStage { stream, subjects }

class SubjectsViewModel extends ChangeNotifier {
  SubjectsViewModel({required ProfileRepository profileRepository})
    : _profiles = profileRepository {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
    _profiles.addListener(_onProfile);
  }

  static const offByDefault = {'sanskrit', 'computer'};

  final ProfileRepository _profiles;

  late final Command0<void> load;
  late final Command0<Profile> save;

  List<Subject> _subjects = const [];
  List<StudyStream> _streams = const [];
  StudyStream? _stream;
  int _streamIndex = 0;
  Set<String> _picked = {};
  SubjectsStage _stage = SubjectsStage.subjects;
  String? _syllabus;

  Profile get profile => _profiles.profile ?? const Profile();
  bool get isSenior => profile.isSenior;
  String get syllabusLabel => profile.syllabusLabel ?? '';
  List<Subject> get subjects => _subjects;
  List<StudyStream> get streams => _streams;
  StudyStream? get stream => _stream;
  int get streamIndex => _streamIndex;
  StudyStream? get focusedStream =>
      _streams.isEmpty ? null : _streams[_streamIndex];
  SubjectsStage get stage => _stage;
  bool get isReady =>
      _subjects.isNotEmpty && (!isSenior || _streams.isNotEmpty);

  List<Subject> get main => switch (_stream) {
    final stream? when isSenior => stream.main,
    _ => [
      ..._subjects.where((s) => s.isLocked),
      ..._subjects.where((s) => !s.isLocked),
    ],
  };

  List<Subject> get optional => isSenior ? _stream?.optional ?? const [] : [];

  List<String> get picks => [
    for (final s in _subjects)
      if (_picked.contains(s.id)) s.id,
  ];

  List<Subject>? get savedSubjects => switch (profile.subjects) {
    final saved? => [
      for (final s in _subjects)
        if (saved.contains(s.id)) s,
    ],
    null => null,
  };

  StudyStream? get savedStream {
    final saved = profile.subjects;
    if (saved == null) return null;
    return _streams.where((s) => s.fits(saved)).firstOrNull;
  }

  bool isPicked(String id) => _picked.contains(id);

  void toggle(String id) {
    if (id == Subject.english) return;
    _picked.contains(id) ? _picked.remove(id) : _picked.add(id);
    notifyListeners();
  }

  void chooseStream(StudyStream stream) {
    _picked = {
      for (final s in stream.main) s.id,
      for (final s in stream.optional)
        if (_picked.contains(s.id)) s.id,
    };
    _stream = stream;
    _stage = SubjectsStage.subjects;
    notifyListeners();
  }

  void focusStream(int index) {
    _streamIndex = index;
    notifyListeners();
  }

  void showStreams() {
    _stage = SubjectsStage.stream;
    notifyListeners();
  }

  void reset({SubjectsStage? start}) {
    final saved = profile.subjects;
    _stream = savedStream;
    _streamIndex = _stream == null ? 0 : _streams.indexOf(_stream!);
    _picked = saved != null
        ? {...saved}
        : isSenior
        ? {for (final s in _stream?.main ?? const <Subject>[]) s.id}
        : {
            for (final s in _subjects)
              if (!offByDefault.contains(s.id)) s.id,
          };
    _picked.add(Subject.english);
    _stage = isSenior && (start == SubjectsStage.stream || _stream == null)
        ? SubjectsStage.stream
        : SubjectsStage.subjects;
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    final current = profile;
    final classLevel = current.classLevel;
    final board = current.board;
    _syllabus = current.syllabusLabel;
    if (classLevel == null || board == null) {
      return Result.error(Exception('Set your class and board first.'));
    }
    final (subjects, streams) = await (
      _profiles.subjects(classLevel: classLevel, board: board),
      current.isSenior
          ? _profiles.streams(classLevel: classLevel, board: board)
          : Future.value(Result<List<StudyStream>>.ok(const [])),
    ).wait;
    switch ((subjects, streams)) {
      case (Ok(value: final subjectList), Ok(value: final streamList)):
        _subjects = subjectList;
        _streams = streamList;
        reset();
        return const Ok(null);
      case (Error(:final error), _) || (_, Error(:final error)):
        return Result.error(error);
    }
  }

  void _onProfile() {
    if (profile.syllabusLabel != _syllabus) {
      load.execute();
    } else {
      notifyListeners();
    }
  }

  Future<Result<Profile>> _save() =>
      _profiles.update(ProfileUpdate(subjects: picks));

  @override
  void dispose() {
    _profiles.removeListener(_onProfile);
    load
      ..removeListener(notifyListeners)
      ..dispose();
    save
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
