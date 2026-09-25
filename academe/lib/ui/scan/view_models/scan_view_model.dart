import 'package:flutter/foundation.dart';

import '../../../data/repositories/scan_repository.dart';
import '../../../domain/models/scan.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class ScanViewModel extends ChangeNotifier {
  ScanViewModel({required ScanRepository scanRepository})
    : _repository = scanRepository {
    load = Command0(_load)..addListener(notifyListeners);
    _repository.addListener(load.execute);
  }

  final ScanRepository _repository;

  late final Command0<List<Scan>> load;

  List<Scan> _recent = const [];

  List<Scan> get recent => _recent;

  Future<Result<List<Scan>>> _load() async {
    final result = await _repository.scans();
    if (result case Ok(:final value)) _recent = value;
    return result;
  }

  @override
  void dispose() {
    _repository.removeListener(load.execute);
    load
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
