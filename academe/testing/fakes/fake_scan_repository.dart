import 'package:academe/data/repositories/scan_repository.dart';
import 'package:academe/domain/models/scan.dart';
import 'package:academe/utils/result.dart';

class FakeScanRepository extends ScanRepository {
  static const marking = Marking(
    question: 'State the laws of reflection.',
    marks: 3,
    awarded: 2,
    points: [
      MarkPoint(text: 'First law stated', marks: 1, awarded: 1),
      MarkPoint(text: 'Mentions the normal', marks: 1, awarded: 1),
      MarkPoint(text: 'All three in one plane', marks: 1, awarded: 0),
    ],
    fullMarks: 'Say the rays and the normal lie in one plane.',
    modelAnswer: 'The angle of incidence equals the angle of reflection.',
  );

  ScanFailure? failure;
  String text = 'Solve 2x + 3y = 11 and x - 2y = -12';
  final List<Scan> saved = [];
  final List<(String, String)> threads = [];
  final List<(String, String, bool)> notes = [];
  List<String>? lastPages;
  String? lastQuestion;

  Result<T> _fail<T>() => Result.error(ScanException(failure!));

  @override
  Future<Result<Scan>> read(ScanMode mode, List<String> pages) async {
    lastPages = pages;
    if (failure != null) return _fail();
    final scan = Scan(
      id: 's${saved.length + 1}',
      mode: mode,
      title: text.split('\n').first,
      text: text,
      chapter: 'Maths · Ch 3 · Linear equations',
      createdAt: DateTime(2026, 9, 25),
    );
    saved.insert(0, scan);
    notifyListeners();
    return Result.ok(scan);
  }

  @override
  Future<Result<List<Scan>>> scans() async => Result.ok(List.of(saved));

  @override
  Future<Result<void>> linkThread(String id, String threadId) async {
    threads.add((id, threadId));
    return Result.ok(null);
  }

  @override
  Future<Result<Marking>> check(String id, String question) async {
    lastQuestion = question;
    if (failure != null) return _fail();
    return Result.ok(marking);
  }

  @override
  Future<Result<String?>> saveNotes(
    String id, {
    required String folderId,
    required bool makeLesson,
  }) async {
    if (failure != null) return _fail();
    notes.add((id, folderId, makeLesson));
    return Result.ok(makeLesson ? 'u-lesson' : null);
  }
}
