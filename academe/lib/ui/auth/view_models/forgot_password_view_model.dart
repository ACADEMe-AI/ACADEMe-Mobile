import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/auth_failure.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import 'auth_failure_of.dart';
import 'sign_up_view_model.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({
    required AuthRepository authRepository,
    String email = '',
  }) : _authRepository = authRepository,
       _email = email {
    sendCode = Command0(_sendCode)..addListener(notifyListeners);
  }

  final AuthRepository _authRepository;

  late final Command0<void> sendCode;

  String _email;
  String get email => _email.trim();

  bool get isEmailValid => SignUpViewModel.emailShape.hasMatch(email);
  bool get canSend => isEmailValid && !sendCode.isRunning;

  AuthFailure? get failure => authFailureOf(sendCode);

  void setEmail(String value) {
    if (value == _email) return;
    _email = value;
    if (sendCode.result != null) {
      sendCode.clearResult();
    } else {
      notifyListeners();
    }
  }

  Future<Result<void>> _sendCode() =>
      _authRepository.requestPasswordReset(email: email);

  @override
  void dispose() {
    sendCode
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
