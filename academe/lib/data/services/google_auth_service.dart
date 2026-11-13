import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/models/auth_failure.dart';
import '../../utils/result.dart';

abstract class GoogleAuthService {
  Future<Result<String>> idToken();

  Future<void> signOut();
}

class GoogleSignInPluginService implements GoogleAuthService {
  GoogleSignInPluginService({required this.serverClientId});

  final String serverClientId;
  Future<void>? _initialized;

  @override
  Future<Result<String>> idToken() async {
    if (serverClientId.isEmpty) {
      return Result.error(const AuthException(AuthFailure.providerUnavailable));
    }
    try {
      await (_initialized ??= GoogleSignIn.instance.initialize(
        serverClientId: serverClientId,
      ));
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null) {
        return Result.error(const AuthException(AuthFailure.unknown));
      }
      return Result.ok(token);
    } on GoogleSignInException catch (e) {
      return Result.error(AuthException(_failureFor(e.code)));
    }
  }

  @override
  Future<void> signOut() async {
    if (_initialized == null) return;
    await GoogleSignIn.instance.signOut();
  }

  static AuthFailure _failureFor(GoogleSignInExceptionCode code) =>
      switch (code) {
        GoogleSignInExceptionCode.canceled ||
        GoogleSignInExceptionCode.interrupted => AuthFailure.canceled,
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError ||
        GoogleSignInExceptionCode.uiUnavailable =>
          AuthFailure.providerUnavailable,
        _ => AuthFailure.unknown,
      };
}
