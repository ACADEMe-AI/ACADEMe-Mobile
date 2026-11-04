import '../../domain/models/progress_summary.dart';
import '../../utils/result.dart';

abstract class ProgressRepository {
  Future<Result<ProgressSummary>> load();
}
