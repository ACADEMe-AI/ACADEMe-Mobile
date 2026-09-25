import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/auth_failure.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import 'auth_failure_of.dart';
import 'sign_up_view_model.dart';

class NewPasswordViewModel extends ChangeNotifier {
  NewPasswordViewModel({
    required AuthRepository authRepository,
    required this.resetToken,
  }) : _authRepository = authRepository {
    save = Command0(_save)..addListener(notifyListeners);
  }

  final AuthRepository _authRepository;
  final String resetToken;

  late final Command0<Account> save;

  String _password = '';

  bool get isPasswordLongEnough =>
      _password.length >= SignUpViewModel.minPasswordLength;

  bool get hasExpired => failure == AuthFailure.resetExpired;

  bool get canSave =>
      isPasswordLongEnough &&
      !save.isRunning &&
      !save.isCompleted &&
      !hasExpired;

  AuthFailure? get failure => authFailureOf(save);

  void setPassword(String value) {
    if (value == _password) return;
    _password = value;
    if (save.hasError && !hasExpired) {
      save.clearResult();
    } else {
      notifyListeners();
    }
  }

  Future<Result<Account>> _save() => _authRepository.completePasswordReset(
    resetToken: resetToken,
    password: _password,
  );

  @override
  void dispose() {
    save
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
