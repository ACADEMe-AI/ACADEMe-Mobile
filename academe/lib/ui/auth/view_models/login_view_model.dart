import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/auth_failure.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    logIn = Command0(_logIn)..addListener(notifyListeners);
  }

  final AuthRepository _authRepository;

  late final Command0<Account> logIn;

  String _email = '';
  String _password = '';

  String get email => _email.trim();

  bool get canLogIn =>
      _email.contains('@') && _password.isNotEmpty && !logIn.isRunning;

  AuthFailure? get failure => switch (logIn.result) {
    Error(error: final AuthException error) => error.failure,
    Error() => AuthFailure.unknown,
    _ => null,
  };

  void setEmail(String value) => _edit(value, _email, (v) => _email = v);

  void setPassword(String value) =>
      _edit(value, _password, (v) => _password = v);

  void _edit(String value, String current, ValueSetter<String> apply) {
    if (value == current) return;
    apply(value);
    if (logIn.hasError) {
      logIn.clearResult();
    } else {
      notifyListeners();
    }
  }

  Future<Result<Account>> _logIn() =>
      _authRepository.logInWithEmail(email: _email.trim(), password: _password);

  @override
  void dispose() {
    logIn
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
