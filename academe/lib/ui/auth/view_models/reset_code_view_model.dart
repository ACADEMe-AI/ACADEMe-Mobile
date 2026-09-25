import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/auth_failure.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import 'auth_failure_of.dart';

class ResetCodeViewModel extends ChangeNotifier {
  ResetCodeViewModel({
    required AuthRepository authRepository,
    required this.email,
  }) : _authRepository = authRepository {
    verify = Command0(_verify)..addListener(notifyListeners);
    resend = Command0(_resend)..addListener(_onResent);
    _startCountdown();
  }

  final AuthRepository _authRepository;
  final String email;

  static const codeLength = 6;
  static const resendDelay = Duration(seconds: 30);
  static final _notDigit = RegExp(r'\D');

  late final Command0<String> verify;
  late final Command0<void> resend;

  String _code = '';
  String get code => _code;

  Duration _resendIn = resendDelay;
  Duration get resendIn => _resendIn;
  Timer? _countdown;

  bool get canResend =>
      (_resendIn == Duration.zero || isCodeUsedUp) && !resend.isRunning;

  bool get isCodeUsedUp => switch (authFailureOf(verify)) {
    AuthFailure.tooManyAttempts || AuthFailure.codeExpired => true,
    _ => false,
  };

  bool get canVerify =>
      _code.length == codeLength && !verify.isRunning && !isCodeUsedUp;

  AuthFailure? get failure => authFailureOf(resend) ?? authFailureOf(verify);

  String? get resetToken => switch (verify.result) {
    Ok(:final value) => value,
    _ => null,
  };

  void setCode(String value) {
    final digits = value.replaceAll(_notDigit, '');
    final next = digits.length > codeLength
        ? digits.substring(0, codeLength)
        : digits;
    if (next == _code) return;
    _code = next;
    if (verify.hasError && !isCodeUsedUp) {
      verify.clearResult();
    } else {
      notifyListeners();
    }
    if (canVerify) verify.execute();
  }

  Future<Result<String>> _verify() =>
      _authRepository.verifyResetCode(email: email, code: _code);

  Future<Result<void>> _resend() =>
      _authRepository.requestPasswordReset(email: email);

  void _onResent() {
    if (resend.isCompleted) {
      _code = '';
      verify.clearResult();
      _startCountdown();
    }
    notifyListeners();
  }

  void _startCountdown() {
    _countdown?.cancel();
    _resendIn = resendDelay;
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      _resendIn -= const Duration(seconds: 1);
      if (_resendIn <= Duration.zero) {
        _resendIn = Duration.zero;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    verify
      ..removeListener(notifyListeners)
      ..dispose();
    resend
      ..removeListener(_onResent)
      ..dispose();
    super.dispose();
  }
}
