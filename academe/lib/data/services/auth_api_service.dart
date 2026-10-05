import '../../domain/models/account.dart';
import '../../utils/result.dart';
import '../model/api_models.dart';
import 'api_client.dart';

class AuthApiService {
  AuthApiService(this._api);

  final ApiClient _api;

  Future<Result<ApiSession>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) => _api.send(
    'POST',
    '/auth/sign-up',
    body: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    },
    parse: ApiSession.fromJson,
  );

  Future<Result<ApiSession>> logIn({
    required String email,
    required String password,
  }) => _api.send(
    'POST',
    '/auth/log-in',
    body: {'email': email, 'password': password},
    parse: ApiSession.fromJson,
  );

  Future<Result<ApiSession>> google(String idToken) => _api.send(
    'POST',
    '/auth/google',
    body: {'idToken': idToken},
    parse: ApiSession.fromJson,
  );

  Future<Result<void>> requestPasswordReset(String email) => _api.send(
    'POST',
    '/auth/password-reset',
    body: {'email': email},
    parse: (_) {},
  );

  Future<Result<String>> verifyResetCode({
    required String email,
    required String code,
  }) => _api.send(
    'POST',
    '/auth/password-reset/verify',
    body: {'email': email, 'code': code},
    parse: (json) => json['resetToken']! as String,
  );

  Future<Result<String>> redeemResetLink(String linkToken) => _api.send(
    'POST',
    '/auth/password-reset/link',
    body: {'linkToken': linkToken},
    parse: (json) => json['resetToken']! as String,
  );

  Future<Result<ApiSession>> completePasswordReset({
    required String resetToken,
    required String password,
  }) => _api.send(
    'POST',
    '/auth/password-reset/complete',
    body: {'resetToken': resetToken, 'password': password},
    parse: ApiSession.fromJson,
  );

  Future<Result<ApiTokens>> refresh(String refreshToken) => _api.send(
    'POST',
    '/auth/refresh',
    body: {'refreshToken': refreshToken},
    parse: ApiTokens.fromJson,
  );

  Future<Result<void>> logOut(String refreshToken) => _api.send(
    'POST',
    '/auth/log-out',
    body: {'refreshToken': refreshToken},
    parse: (_) {},
  );

  Future<Result<Account>> me(String accessToken) =>
      _api.send('GET', '/me', accessToken: accessToken, parse: accountFromJson);

  Future<Result<Account>> updateName(
    String accessToken, {
    required String firstName,
    required String lastName,
  }) => _api.send(
    'PATCH',
    '/me',
    accessToken: accessToken,
    body: {'firstName': firstName, 'lastName': lastName},
    parse: accountFromJson,
  );

  Future<Result<ApiSession>> changePassword(
    String accessToken, {
    String? currentPassword,
    required String newPassword,
  }) => _api.send(
    'POST',
    '/me/password',
    accessToken: accessToken,
    body: {'currentPassword': ?currentPassword, 'newPassword': newPassword},
    parse: ApiSession.fromJson,
  );

  Future<Result<Account>> linkGoogle(String accessToken, String idToken) =>
      _api.send(
        'POST',
        '/me/google',
        accessToken: accessToken,
        body: {'idToken': idToken},
        parse: accountFromJson,
      );

  Future<Result<Account>> unlinkGoogle(String accessToken) => _api.send(
    'DELETE',
    '/me/google',
    accessToken: accessToken,
    parse: accountFromJson,
  );

  Future<Result<DateTime>> deleteAccount(
    String accessToken, {
    String? reason,
  }) => _api.send(
    'DELETE',
    '/me',
    accessToken: accessToken,
    body: {'reason': ?reason},
    parse: (json) => DateTime.parse(json['deletesAt']! as String),
  );
}
