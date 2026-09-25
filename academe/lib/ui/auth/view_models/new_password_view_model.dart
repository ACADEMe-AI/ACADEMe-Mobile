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
    String? resetToken,
    this.linkToken,
  }) : _authRepository = authRepository,
       _resetToken = resetToken {
    save = Command0(_save)..addListener(notifyListeners);
  }

  final AuthRepository _authRepository;
  final String? linkToken;
  String? _resetToken;

  late final Command0<Account> save;

  String _password = '';

  bool get isPasswordLongEnough => SignUpViewModel.isLongEnough(_password);

  bool get hasExpired =>
      failure == AuthFailure.resetExpired ||
      failure == AuthFailure.tooManyAttempts;

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

  Future<Result<Account>> _save() async {
    var resetToken = _resetToken;
    if (resetToken == null) {
      switch (await _authRepository.redeemResetLink(linkToken ?? '')) {
        case Ok(:final value):
          resetToken = _resetToken = value;
        case Error(:final error):
          return Result.error(error);
      }
    }
    return _authRepository.completePasswordReset(
      resetToken: resetToken,
      password: _password,
    );
  }

  @override
  void dispose() {
    save
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
