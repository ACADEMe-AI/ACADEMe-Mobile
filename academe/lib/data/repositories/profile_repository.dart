import 'package:flutter/foundation.dart';

import '../../domain/models/board.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/subject.dart';
import '../../utils/result.dart';

abstract class ProfileRepository extends ChangeNotifier {
  Profile? get profile;

  Future<Result<Profile>> load();

  Future<Result<Profile>> update(ProfileUpdate update);

  Future<Result<List<Subject>>> subjects({
    required int classLevel,
    required Board board,
  });
}
