import 'package:academe/data/repositories/photo_repository.dart';
import 'package:academe/utils/result.dart';

class FakePhotoRepository implements PhotoRepository {
  List<String> photos = ['/tmp/page-1.jpg'];
  final List<(PhotoSource, int)> picks = [];

  @override
  Future<Result<List<String>>> pick(PhotoSource source, {int limit = 1}) async {
    picks.add((source, limit));
    return Result.ok(photos.take(limit).toList());
  }
}
