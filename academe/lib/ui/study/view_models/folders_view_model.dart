import 'package:flutter/foundation.dart';

import '../../../data/repositories/folder_repository.dart';
import '../../../domain/models/folder.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

typedef NewFolder = ({String name, DateTime? dueOn});

class FoldersViewModel extends ChangeNotifier {
  FoldersViewModel({required FolderRepository folderRepository})
    : _repository = folderRepository {
    load = Command0(_load)..addListener(notifyListeners);
    create = Command1(_create)..addListener(notifyListeners);
    _repository.addListener(_onChanged);
  }

  final FolderRepository _repository;

  late final Command0<void> load;
  late final Command1<FolderSummary, NewFolder> create;

  List<FolderSummary> _folders = const [];

  List<FolderSummary> get folders => _folders;

  void _onChanged() => load.execute();

  Future<Result<void>> _load() async {
    final result = await _repository.folders();
    if (result case Ok(:final value)) _folders = value;
    return result;
  }

  Future<Result<FolderSummary>> _create(NewFolder folder) =>
      _repository.create(name: folder.name.trim(), dueOn: folder.dueOn);

  @override
  void dispose() {
    _repository.removeListener(_onChanged);
    for (final command in <Command<Object?>>[load, create]) {
      command
        ..removeListener(notifyListeners)
        ..dispose();
    }
    super.dispose();
  }
}
