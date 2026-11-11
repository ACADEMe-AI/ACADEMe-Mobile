import '../../../domain/models/auth_failure.dart';
import '../../../l10n/generated/app_localizations.dart';

extension AuthFailureText on AuthFailure {
  String message(AppLocalizations l10n) => switch (this) {
    AuthFailure.emailTaken => l10n.authFailureEmailTaken,
    AuthFailure.wrongCredentials => l10n.authFailureWrongCredentials,
    AuthFailure.invalidInput => l10n.authFailureInvalidInput,
    AuthFailure.signedOut => l10n.authFailureSignedOut,
    AuthFailure.network => l10n.authFailureNetwork,
    AuthFailure.canceled => l10n.authFailureCanceled,
    AuthFailure.providerUnavailable => l10n.authFailureProviderUnavailable,
    AuthFailure.wrongCode => l10n.authFailureWrongCode,
    AuthFailure.tooManyAttempts => l10n.authFailureTooManyAttempts,
    AuthFailure.codeExpired => l10n.authFailureCodeExpired,
    AuthFailure.resetExpired => l10n.authFailureResetExpired,
    AuthFailure.tooManyRequests => l10n.authFailureTooManyRequests,
    AuthFailure.wrongPassword => l10n.authFailureWrongPassword,
    AuthFailure.googleTaken => l10n.authFailureGoogleTaken,
    AuthFailure.passwordRequired => l10n.authFailurePasswordRequired,
    AuthFailure.unknown => l10n.authFailureUnknown,
  };
}

String failureMessage(Exception error, AppLocalizations l10n) =>
    switch (error) {
      AuthException(:final failure) => failure.message(l10n),
      _ => AuthFailure.unknown.message(l10n),
    };
