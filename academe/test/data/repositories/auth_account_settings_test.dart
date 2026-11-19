import 'package:academe/data/repositories/auth_repository_remote.dart';
import 'package:academe/data/services/api_client.dart';
import 'package:academe/data/services/auth_api_service.dart';
import 'package:academe/domain/models/account.dart';
import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_google_auth_service.dart';
import '../../../testing/fakes/fake_session_store.dart';
import 'auth_repository_remote_test.dart'
    show FakeServer, failure, maya, tokens;

void main() {
  late FakeServer server;
  late FakeSessionStore store;
  late FakeGoogleAuthService google;
  late AuthRepositoryRemote repository;

  setUp(() async {
    server = FakeServer()
      ..reply('POST /auth/log-in', 200, {
        'account': {...maya, 'hasPassword': true},
        'tokens': tokens('1'),
      });
    store = FakeSessionStore();
    google = FakeGoogleAuthService(Result.ok('google-id-token'));
    repository = AuthRepositoryRemote(
      api: AuthApiService(
        ApiClient(baseUrl: Uri.parse('http://api.test'), client: server.client),
      ),
      sessionStore: store,
      google: google,
    );
    await repository.logInWithEmail(
      email: 'maya@example.com',
      password: 'sunflower',
    );
  });

  AuthFailure? failureOf(Result<Object?> result) => switch (result) {
    Error(error: AuthException(:final failure)) => failure,
    _ => null,
  };

  test('changing the password swaps in the fresh tokens', () async {
    server
      ..reply('POST /me/password', 200, {
        'account': maya,
        'tokens': tokens('2'),
      })
      ..reply('GET /me', 200, maya);

    final result = await repository.changePassword(
      currentPassword: 'sunflower',
      newPassword: 'marigold1',
    );

    expect(result, isA<Ok<Account>>());
    expect(server.bodyOf(1), {
      'currentPassword': 'sunflower',
      'newPassword': 'marigold1',
    });
    expect(server.requests[1].headers['Authorization'], 'Bearer access-1');
    expect(store.session?.refreshToken, 'refresh-2');
    await repository.restoreSession();
    expect(server.requests.last.url.path, '/me');
    expect(server.requests.last.headers['Authorization'], 'Bearer access-2');
  });

  test('setting a first password sends no current password', () async {
    server.reply('POST /me/password', 200, {
      'account': maya,
      'tokens': tokens('2'),
    });
    await repository.changePassword(newPassword: 'marigold1');
    expect(server.bodyOf(1), {'newPassword': 'marigold1'});
  });

  test('a wrong current password is not retried as an expired token', () async {
    server.reply('POST /me/password', 403, failure('wrong_password'));
    final result = await repository.changePassword(
      currentPassword: 'guess',
      newPassword: 'marigold1',
    );
    expect(failureOf(result), AuthFailure.wrongPassword);
    expect(server.requests, hasLength(2));
    expect(store.session?.refreshToken, 'refresh-1');
  });

  test(
    'linking Google sends the ID token and saves the Google email',
    () async {
      server.reply('POST /me/google', 200, {
        ...maya,
        'hasPassword': true,
        'googleEmail': 'maya.rao@gmail.com',
      });

      final result = await repository.linkGoogle();

      expect((result as Ok<Account>).value.googleEmail, 'maya.rao@gmail.com');
      expect(server.bodyOf(1), {'idToken': 'google-id-token'});
      expect(repository.account?.hasGoogle, isTrue);
      expect(store.session?.account.googleEmail, 'maya.rao@gmail.com');
    },
  );

  test('a canceled Google picker never reaches the server', () async {
    google.answer = Result.error(const AuthException(AuthFailure.canceled));
    expect(failureOf(await repository.linkGoogle()), AuthFailure.canceled);
    expect(server.requests, hasLength(1));
  });

  test('link and unlink errors become auth failures', () async {
    server
      ..reply('POST /me/google', 409, failure('google_taken'))
      ..reply('DELETE /me/google', 409, failure('password_required'));
    expect(failureOf(await repository.linkGoogle()), AuthFailure.googleTaken);
    expect(
      failureOf(await repository.unlinkGoogle()),
      AuthFailure.passwordRequired,
    );
    expect(google.signOuts, 0);
  });

  test('unlinking Google clears it and signs the Google picker out', () async {
    server.reply('DELETE /me/google', 200, {...maya, 'hasPassword': true});
    final result = await repository.unlinkGoogle();
    expect((result as Ok<Account>).value.hasGoogle, isFalse);
    expect(google.signOuts, 1);
  });

  test('an account without the new fields reads as a password account', () {
    expect(repository.account?.hasPassword, isTrue);
    expect(repository.account?.googleEmail, isNull);
  });
}
