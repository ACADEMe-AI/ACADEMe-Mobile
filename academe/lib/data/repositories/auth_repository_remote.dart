import '../../domain/models/account.dart';
import '../../domain/models/auth_failure.dart';
import '../../utils/result.dart';
import '../model/api_models.dart';
import '../services/auth_api_service.dart';
import '../services/google_auth_service.dart';
import '../services/session_store.dart';
import 'auth_repository.dart';
import 'authorizer.dart';

class AuthRepositoryRemote implements AuthRepository, Authorizer {
  AuthRepositoryRemote({
    required AuthApiService api,
    required SessionStore sessionStore,
    required GoogleAuthService google,
  }) : _api = api,
       _sessionStore = sessionStore,
       _google = google;

  final AuthApiService _api;
  final SessionStore _sessionStore;
  final GoogleAuthService _google;

  Account? _account;
  String? _accessToken;
  String? _refreshToken;
  Future<Result<void>>? _refreshing;

  @override
  Account? get account => _account;

  @override
  Future<Result<Account>> restoreSession() async {
    final stored = await _sessionStore.read();
    if (stored == null) return _signedOut();
    _account = stored.account;
    _refreshToken = stored.refreshToken;

    final me = await authorized(_api.me);
    switch (me) {
      case Ok(:final value):
        await _save(value);
        return Result.ok(value);
      case Error(error: ApiException(code: ApiException.network)):
        return Result.ok(stored.account);
      case Error(:final error):
        return Result.error(_authError(error));
    }
  }

  @override
  Future<Result<Account>> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async => _start(
    await _api.signUp(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    ),
  );

  @override
  Future<Result<Account>> logInWithEmail({
    required String email,
    required String password,
  }) async => _start(await _api.logIn(email: email, password: password));

  @override
  Future<Result<ProviderSignIn>> continueWithGoogle() async {
    final idToken = await _google.idToken();
    if (idToken case Error(:final error)) return Result.error(error);
    final session = await _api.google((idToken as Ok<String>).value);
    final started = await _start(session);
    return switch (started) {
      Ok(:final value) => Result.ok((
        account: value,
        isNew: (session as Ok<ApiSession>).value.isNew,
      )),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<void>> requestPasswordReset({required String email}) async =>
      switch (await _api.requestPasswordReset(email)) {
        Ok() => Result.ok(null),
        Error(:final error) => Result.error(_authError(error)),
      };

  @override
  Future<Result<String>> verifyResetCode({
    required String email,
    required String code,
  }) async => switch (await _api.verifyResetCode(email: email, code: code)) {
    Ok(:final value) => Result.ok(value),
    Error(:final error) => Result.error(_authError(error)),
  };

  @override
  Future<Result<Account>> completePasswordReset({
    required String resetToken,
    required String password,
  }) async => _start(
    await _api.completePasswordReset(
      resetToken: resetToken,
      password: password,
    ),
  );

  @override
  Future<Result<Account>> updateName({
    required String firstName,
    required String lastName,
  }) async {
    final updated = await authorized(
      (token) =>
          _api.updateName(token, firstName: firstName, lastName: lastName),
    );
    switch (updated) {
      case Ok(:final value):
        await _save(value);
        return Result.ok(value);
      case Error(:final error):
        return Result.error(_authError(error));
    }
  }

  @override
  Future<Result<void>> logOut() async {
    final refreshToken = _refreshToken;
    await _clear();
    await _google.signOut();
    if (refreshToken != null) await _api.logOut(refreshToken);
    return Result.ok(null);
  }

  @override
  Future<Result<DateTime>> deleteAccount({String? reason}) async {
    final deleted = await authorized(
      (token) => _api.deleteAccount(token, reason: reason),
    );
    switch (deleted) {
      case Ok(:final value):
        await _clear();
        await _google.signOut();
        return Result.ok(value);
      case Error(:final error):
        return Result.error(_authError(error));
    }
  }

  Future<Result<Account>> _start(Result<ApiSession> session) async {
    switch (session) {
      case Ok(:final value):
        _accessToken = value.tokens.accessToken;
        _refreshToken = value.tokens.refreshToken;
        await _save(value.account);
        return Result.ok(value.account);
      case Error(:final error):
        return Result.error(_authError(error));
    }
  }

  @override
  Future<Result<T>> authorized<T>(
    Future<Result<T>> Function(String accessToken) call,
  ) async {
    if (_accessToken == null) {
      final refreshed = await _refresh();
      if (refreshed case Error(:final error)) return Result.error(error);
    }
    final result = await call(_accessToken!);
    if (result case Error(error: ApiException(statusCode: 401))) {
      final refreshed = await _refresh();
      if (refreshed case Error(:final error)) return Result.error(error);
      return call(_accessToken!);
    }
    return result;
  }

  Future<Result<void>> _refresh() =>
      _refreshing ??= _rotate().whenComplete(() => _refreshing = null);

  Future<Result<void>> _rotate() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null) return _signedOut();
    final tokens = await _api.refresh(refreshToken);
    switch (tokens) {
      case Ok(:final value):
        _accessToken = value.accessToken;
        _refreshToken = value.refreshToken;
        final account = _account;
        if (account != null) await _save(account);
        return Result.ok(null);
      case Error(error: ApiException(statusCode: 401)):
        await _clear();
        return _signedOut();
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<void> _save(Account account) async {
    _account = account;
    await _sessionStore.write(
      StoredSession(refreshToken: _refreshToken!, account: account),
    );
  }

  Future<void> _clear() async {
    _account = null;
    _accessToken = null;
    _refreshToken = null;
    await _sessionStore.clear();
  }

  static Result<T> _signedOut<T>() =>
      Result.error(const AuthException(AuthFailure.signedOut));

  static AuthException _authError(Exception error) {
    if (error is AuthException) return error;
    if (error is! ApiException) return const AuthException(AuthFailure.unknown);
    return switch (error.code) {
      'email_taken' => const AuthException(AuthFailure.emailTaken),
      'wrong_credentials' => const AuthException(AuthFailure.wrongCredentials),
      'invalid_token' => const AuthException(AuthFailure.signedOut),
      'google_unavailable' => const AuthException(
        AuthFailure.providerUnavailable,
      ),
      'wrong_code' => const AuthException(AuthFailure.wrongCode),
      'too_many_attempts' => const AuthException(AuthFailure.tooManyAttempts),
      'code_expired' => const AuthException(AuthFailure.codeExpired),
      'reset_expired' => const AuthException(AuthFailure.resetExpired),
      'too_many_requests' => const AuthException(AuthFailure.tooManyRequests),
      ApiException.network => const AuthException(AuthFailure.network),
      final code
          when code.startsWith('invalid_') &&
              code != 'invalid_json' &&
              code != 'invalid_google_token' =>
        AuthException(
          AuthFailure.invalidInput,
          field: code.substring('invalid_'.length),
        ),
      _ => const AuthException(AuthFailure.unknown),
    };
  }
}
