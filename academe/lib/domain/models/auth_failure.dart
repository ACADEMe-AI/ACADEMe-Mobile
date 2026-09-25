enum AuthFailure {
  emailTaken,
  wrongCredentials,
  invalidInput,
  signedOut,
  network,
  canceled,
  providerUnavailable,
  wrongCode,
  tooManyAttempts,
  codeExpired,
  resetExpired,
  tooManyRequests,
  wrongPassword,
  googleTaken,
  passwordRequired,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.failure, {this.field});

  final AuthFailure failure;
  final String? field;

  @override
  String toString() =>
      'AuthException($failure${field == null ? '' : ', $field'})';
}
