import 'package:flutter/foundation.dart';

import '../../../data/repositories/folder_repository.dart';
import '../../../domain/models/folder.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class TodayViewModel extends ChangeNotifier {
  TodayViewModel({required FolderRepository folderRepository})
    : _repository = folderRepository {
    load = Command0(_load)..addListener(notifyListeners);
    _repository.addListener(_onChanged);
  }

  final FolderRepository _repository;

  late final Command0<void> load;

  TodayPlan _plan = TodayPlan.empty;

  TodayPlan get plan => _plan;

  void _onChanged() => load.execute();

  Future<void> toggleTodo(StudyTask task) async {
    final folderId = task.folderId;
    final todoId = task.todoId;
    if (folderId == null || todoId == null) return;
    await _repository.setTodoDone(folderId, todoId, !task.isDone);
  }

  Future<Result<void>> _load() async {
    final result = await _repository.today();
    if (result case Ok(:final value)) _plan = value;
    return result;
  }

  @override
  void dispose() {
    _repository.removeListener(_onChanged);
    load
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
