import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/result.dart';

enum PhotoSource { camera, gallery }

abstract class PhotoRepository {
  Future<Result<List<String>>> pick(PhotoSource source, {int limit = 1});
}

class DevicePhotoRepository implements PhotoRepository {
  DevicePhotoRepository({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _maxSide = 2000.0;
  static const _quality = 85;

  @override
  Future<Result<List<String>>> pick(PhotoSource source, {int limit = 1}) async {
    try {
      if (source == PhotoSource.gallery && limit > 1) {
        final files = await _picker.pickMultiImage(
          maxWidth: _maxSide,
          maxHeight: _maxSide,
          imageQuality: _quality,
          limit: limit,
        );
        return Result.ok([for (final f in files.take(limit)) f.path]);
      }
      final file = await _picker.pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
      return Result.ok([?file?.path]);
    } on PlatformException catch (error) {
      return Result.error(error);
    }
  }
}
