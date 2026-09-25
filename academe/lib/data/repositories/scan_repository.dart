import 'package:flutter/foundation.dart';

import '../../domain/models/scan.dart';
import '../../utils/result.dart';

abstract class ScanRepository extends ChangeNotifier {
  Future<Result<Scan>> read(ScanMode mode, List<String> pages);

  Future<Result<List<Scan>>> scans();

  Future<Result<void>> linkThread(String id, String threadId);

  Future<Result<Marking>> check(String id, String question);

  Future<Result<String?>> saveNotes(
    String id, {
    required String folderId,
    required bool makeLesson,
  });
}
