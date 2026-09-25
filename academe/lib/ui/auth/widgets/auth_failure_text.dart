import '../../../domain/models/auth_failure.dart';

extension AuthFailureText on AuthFailure {
  String get message => switch (this) {
    AuthFailure.emailTaken =>
      'An account already uses this email. Log in instead.',
    AuthFailure.wrongCredentials => "That email and password don't match.",
    AuthFailure.invalidInput => 'Check your details and try again.',
    AuthFailure.signedOut => 'Your session ended. Log in again.',
    AuthFailure.network =>
      "Can't reach ACADEMe. Check your connection and try again.",
    AuthFailure.canceled => 'Sign-in was canceled.',
    AuthFailure.providerUnavailable =>
      "This sign-in option isn't ready yet. Use email for now.",
    AuthFailure.wrongCode =>
      "That code isn't right. Check the email and try "
          'again.',
    AuthFailure.tooManyAttempts =>
      'Too many wrong tries. Send yourself a new code.',
    AuthFailure.codeExpired =>
      'That code has expired. Send yourself a new one.',
    AuthFailure.resetExpired =>
      'This reset link timed out. Start again from Forgot password.',
    AuthFailure.tooManyRequests =>
      "That's a lot of tries. Wait a little and try again.",
    AuthFailure.wrongPassword => "That isn't your current password.",
    AuthFailure.googleTaken =>
      'That Google account is linked to another ACADEMe account.',
    AuthFailure.passwordRequired =>
      'Set a password first, so you can still log in without Google.',
    AuthFailure.unknown => 'Something went wrong. Try again.',
  };
}

String failureMessage(Exception error) => switch (error) {
  AuthException(:final failure) => failure.message,
  _ => AuthFailure.unknown.message,
};
