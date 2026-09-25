import 'package:flutter/foundation.dart';

import '../../../data/repositories/photo_repository.dart';
import '../../../data/repositories/scan_repository.dart';
import '../../../domain/models/scan.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

typedef NotesTarget = ({String folderId, bool makeLesson});

class ScanFlowViewModel extends ChangeNotifier {
  ScanFlowViewModel({
    required ScanRepository scanRepository,
    required PhotoRepository photoRepository,
    required this.mode,
    List<String> pages = const [],
    Scan? scan,
  }) : _repository = scanRepository,
       _photos = photoRepository,
       _pages = pages,
       _scan = scan {
    addPages = Command1(_addPages)..addListener(notifyListeners);
    read = Command0(_read)..addListener(notifyListeners);
    check = Command1(_check)..addListener(notifyListeners);
    saveNotes = Command1(_saveNotes)..addListener(notifyListeners);
  }

  final ScanRepository _repository;
  final PhotoRepository _photos;
  final ScanMode mode;

  static const maxPages = 10;

  late final Command1<List<String>, PhotoSource> addPages;
  late final Command0<Scan> read;
  late final Command1<Marking, String> check;
  late final Command1<String?, NotesTarget> saveNotes;

  List<String> _pages;
  Scan? _scan;

  List<String> get pages => _pages;
  Scan? get scan => _scan;
  bool get isFull => _pages.length >= maxPages;
  bool get hasManyPages => mode == ScanMode.notes;

  ScanFailure? get failure {
    for (final Command<Object?> command in [read, check, saveNotes]) {
      if (command.result case Error(:final error)) {
        return error is ScanException ? error.failure : ScanFailure.unknown;
      }
    }
    return null;
  }

  void removePage(int index) {
    _pages = [..._pages]..removeAt(index);
    notifyListeners();
  }

  Future<Result<List<String>>> _addPages(PhotoSource source) async {
    final result = await _photos.pick(
      source,
      limit: hasManyPages ? maxPages - _pages.length : 1,
    );
    if (result case Ok(:final value)) {
      _pages = hasManyPages
          ? [..._pages, ...value].take(maxPages).toList()
          : value;
    }
    return result;
  }

  Future<Result<Scan>> _read() async {
    if (_pages.isEmpty) {
      return Result.error(const ScanException(ScanFailure.noText));
    }
    final result = await _repository.read(mode, _pages);
    if (result case Ok(:final value)) _scan = value;
    return result;
  }

  Future<Result<Marking>> _check(String question) async {
    final scan = _scan;
    if (scan == null) {
      return Result.error(const ScanException(ScanFailure.unknown));
    }
    return _repository.check(scan.id, question.trim());
  }

  Future<Result<String?>> _saveNotes(NotesTarget target) async {
    final scan = _scan;
    if (scan == null) {
      return Result.error(const ScanException(ScanFailure.unknown));
    }
    return _repository.saveNotes(
      scan.id,
      folderId: target.folderId,
      makeLesson: target.makeLesson,
    );
  }

  Future<void> linkThread(String threadId) async {
    final scan = _scan;
    if (scan != null) await _repository.linkThread(scan.id, threadId);
  }

  @override
  void dispose() {
    for (final command in [addPages, read, check, saveNotes]) {
      command
        ..removeListener(notifyListeners)
        ..dispose();
    }
    super.dispose();
  }
}
