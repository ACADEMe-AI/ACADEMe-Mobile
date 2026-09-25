import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A argument);

abstract class Command<T> extends ChangeNotifier {
  bool _isRunning = false;
  Result<T>? _result;

  bool get isRunning => _isRunning;
  bool get hasError => _result is Error;
  bool get isCompleted => _result is Ok;
  Result<T>? get result => _result;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    if (_isRunning) return;
    _isRunning = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } finally {
      _isRunning = false;
      notifyListeners();
    }
  }
}

final class Command0<T> extends Command<T> {
  Command0(this._action);

  final CommandAction0<T> _action;

  Future<void> execute() => _execute(_action);
}

final class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) => _execute(() => _action(argument));
}
