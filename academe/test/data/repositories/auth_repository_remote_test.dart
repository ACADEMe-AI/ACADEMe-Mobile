import 'dart:convert';

import 'package:academe/data/repositories/auth_repository_remote.dart';
import 'package:academe/data/services/api_client.dart';
import 'package:academe/data/services/auth_api_service.dart';
import 'package:academe/data/services/session_store.dart';
import 'package:academe/domain/models/account.dart';
import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../../testing/fakes/fake_google_auth_service.dart';
import '../../../testing/fakes/fake_session_store.dart';

typedef Reply = (int, Map<String, Object?>?);

const maya = {
  'id': 'account-1',
  'firstName': 'Maya',
  'lastName': 'Rao',
  'email': 'maya@example.com',
};

Map<String, Object?> tokens(String n) => {
  'accessToken': 'access-$n',
  'refreshToken': 'refresh-$n',
  'expiresIn': 900,
};

Map<String, Object?> failure(String code) => {
  'error': {'code': code, 'message': code, 'requestId': 'r'},
};

class FakeServer {
  final requests = <http.Request>[];
  final replies = <String, List<Reply>>{};
  var offline = false;

  void reply(String route, int status, [Map<String, Object?>? body]) =>
      replies.putIfAbsent(route, () => []).add((status, body));

  late final client = MockClient((request) async {
    if (offline) throw http.ClientException('offline');
    requests.add(request);
    final queue = replies['${request.method} ${request.url.path}'];
    if (queue == null || queue.isEmpty) return http.Response('', 404);
    final (status, body) = queue.length == 1 ? queue.first : queue.removeAt(0);
    return http.Response(body == null ? '' : jsonEncode(body), status);
  });

  Map<String, Object?> bodyOf(int index) =>
      jsonDecode(requests[index].body) as Map<String, Object?>;
}

void main() {
  late FakeServer server;
  late FakeSessionStore store;
  late FakeGoogleAuthService google;
  late AuthRepositoryRemote repository;

  setUp(() {
    server = FakeServer();
    store = FakeSessionStore();
    google = FakeGoogleAuthService(Result.ok('google-id-token'));
    repository = AuthRepositoryRemote(
      api: AuthApiService(
        ApiClient(baseUrl: Uri.parse('http://api.test'), client: server.client),
      ),
      sessionStore: store,
      google: google,
    );
  });

  AuthException? failureOf(Result<Object?> result) => switch (result) {
    Error(error: final AuthException error) => error,
    _ => null,
  };

  Future<Result<Account>> signUp() => repository.signUpWithEmail(
    firstName: 'Maya',
    lastName: 'Rao',
    email: 'maya@example.com',
    password: 'sunflower',
  );

  test('sign-up keeps the session in secure storage', () async {
    server.reply('POST /auth/sign-up', 201, {
      'account': maya,
      'tokens': tokens('1'),
    });

    final result = await signUp();

    expect((result as Ok<Account>).value.firstName, 'Maya');
    expect(repository.account?.id, 'account-1');
    expect(store.session?.refreshToken, 'refresh-1');
    expect(server.bodyOf(0), {
      'firstName': 'Maya',
      'lastName': 'Rao',
      'email': 'maya@example.com',
      'password': 'sunflower',
    });
  });

  test('server errors become auth failures', () async {
    server
      ..reply('POST /auth/sign-up', 409, failure('email_taken'))
      ..reply('POST /auth/log-in', 401, failure('wrong_credentials'))
      ..reply('POST /auth/google', 503, failure('google_unavailable'));

    expect(failureOf(await signUp())?.failure, AuthFailure.emailTaken);
    expect(
      failureOf(
        await repository.logInWithEmail(email: 'a@b.co', password: 'nope'),
      )?.failure,
      AuthFailure.wrongCredentials,
    );
    expect(
      failureOf(await repository.continueWithGoogle())?.failure,
      AuthFailure.providerUnavailable,
    );
    expect(store.session, isNull);
  });

  test('invalid input names the field', () async {
    server.reply('POST /auth/sign-up', 422, failure('invalid_email'));

    final error = failureOf(await signUp());

    expect(error?.failure, AuthFailure.invalidInput);
    expect(error?.field, 'email');
  });

  test('no connection is a network failure', () async {
    server.offline = true;
    expect(failureOf(await signUp())?.failure, AuthFailure.network);
  });

  group('restoreSession', () {
    const cached = Account(
      id: 'account-1',
      firstName: 'Old',
      lastName: 'Name',
      email: 'maya@example.com',
    );

    setUp(() {
      store.session = const StoredSession(
        refreshToken: 'refresh-0',
        account: cached,
      );
    });

    test('is signed out with nothing stored', () async {
      store.session = null;
      final result = await repository.restoreSession();
      expect(failureOf(result)?.failure, AuthFailure.signedOut);
      expect(server.requests, isEmpty);
    });

    test('rotates the refresh token and loads the account', () async {
      server
        ..reply('POST /auth/refresh', 200, tokens('1'))
        ..reply('GET /me', 200, maya);

      final result = await repository.restoreSession();

      expect((result as Ok<Account>).value.firstName, 'Maya');
      expect(server.bodyOf(0), {'refreshToken': 'refresh-0'});
      expect(server.requests[1].headers['Authorization'], 'Bearer access-1');
      expect(store.session?.refreshToken, 'refresh-1');
      expect(store.session?.account.firstName, 'Maya');
    });

    test('keeps the cached account while offline', () async {
      server.offline = true;
      final result = await repository.restoreSession();
      expect((result as Ok<Account>).value, same(cached));
      expect(store.session, isNotNull);
    });

    test('signs out when the refresh token is rejected', () async {
      server.reply('POST /auth/refresh', 401, failure('invalid_token'));

      final result = await repository.restoreSession();

      expect(failureOf(result)?.failure, AuthFailure.signedOut);
      expect(store.session, isNull);
      expect(repository.account, isNull);
    });
  });

  test('an expired access token is refreshed once and retried', () async {
    server
      ..reply('POST /auth/sign-up', 201, {
        'account': maya,
        'tokens': tokens('1'),
      })
      ..reply('PATCH /me', 401, failure('invalid_token'))
      ..reply('PATCH /me', 200, {...maya, 'firstName': 'Maya-Lin'})
      ..reply('POST /auth/refresh', 200, tokens('2'));
    await signUp();

    final result = await repository.updateName(
      firstName: 'Maya-Lin',
      lastName: 'Rao',
    );

    expect((result as Ok<Account>).value.firstName, 'Maya-Lin');
    final paths = [
      for (final r in server.requests) '${r.method} ${r.url.path}',
    ];
    expect(paths, [
      'POST /auth/sign-up',
      'PATCH /me',
      'POST /auth/refresh',
      'PATCH /me',
    ]);
    expect(server.requests.last.headers['Authorization'], 'Bearer access-2');
    expect(store.session?.account.firstName, 'Maya-Lin');
  });

  test('Google sends the ID token and reports a new account', () async {
    server.reply('POST /auth/google', 200, {
      'account': maya,
      'tokens': tokens('1'),
      'created': true,
    });

    final result = await repository.continueWithGoogle();

    expect((result as Ok).value.isNew, isTrue);
    expect(server.bodyOf(0), {'idToken': 'google-id-token'});
    expect(store.session?.refreshToken, 'refresh-1');
  });

  test('a canceled Google picker never reaches the server', () async {
    google.answer = Result.error(const AuthException(AuthFailure.canceled));
    final result = await repository.continueWithGoogle();
    expect(failureOf(result)?.failure, AuthFailure.canceled);
    expect(server.requests, isEmpty);
  });

  test('log-out forgets the session and tells the server', () async {
    server
      ..reply('POST /auth/sign-up', 201, {
        'account': maya,
        'tokens': tokens('1'),
      })
      ..reply('POST /auth/log-out', 204);
    await signUp();

    await repository.logOut();

    expect(store.session, isNull);
    expect(repository.account, isNull);
    expect(server.bodyOf(1), {'refreshToken': 'refresh-1'});
    expect(google.signOuts, 1);
  });

  group('password reset', () {
    test('asks for a code, checks it and lands signed in', () async {
      server
        ..reply('POST /auth/password-reset', 202, {'expiresIn': 900})
        ..reply('POST /auth/password-reset/verify', 200, {
          'resetToken': 'reset-1',
          'expiresIn': 900,
        })
        ..reply('POST /auth/password-reset/complete', 200, {
          'account': maya,
          'tokens': tokens('1'),
        });

      final requested = await repository.requestPasswordReset(
        email: 'maya@example.com',
      );
      final verified = await repository.verifyResetCode(
        email: 'maya@example.com',
        code: '482913',
      );
      final completed = await repository.completePasswordReset(
        resetToken: 'reset-1',
        password: 'moonflower',
      );

      expect(requested, isA<Ok<void>>());
      expect((verified as Ok<String>).value, 'reset-1');
      expect((completed as Ok<Account>).value.firstName, 'Maya');
      expect(server.bodyOf(0), {'email': 'maya@example.com'});
      expect(server.bodyOf(1), {'email': 'maya@example.com', 'code': '482913'});
      expect(server.bodyOf(2), {
        'resetToken': 'reset-1',
        'password': 'moonflower',
      });
      expect(repository.account?.id, 'account-1');
      expect(store.session?.refreshToken, 'refresh-1');
    });

    test('error codes become reset failures', () async {
      for (final (status, code, want) in [
        (422, 'wrong_code', AuthFailure.wrongCode),
        (429, 'too_many_attempts', AuthFailure.tooManyAttempts),
        (410, 'code_expired', AuthFailure.codeExpired),
        (429, 'too_many_requests', AuthFailure.tooManyRequests),
      ]) {
        server.replies.clear();
        server.reply('POST /auth/password-reset/verify', status, failure(code));
        final result = await repository.verifyResetCode(
          email: 'maya@example.com',
          code: '000000',
        );
        expect(failureOf(result)?.failure, want, reason: code);
      }

      server.reply(
        'POST /auth/password-reset/complete',
        410,
        failure('reset_expired'),
      );
      final expired = await repository.completePasswordReset(
        resetToken: 'reset-1',
        password: 'moonflower',
      );
      expect(failureOf(expired)?.failure, AuthFailure.resetExpired);

      server.replies.clear();
      server.reply(
        'POST /auth/password-reset/complete',
        422,
        failure('invalid_password'),
      );
      final short = failureOf(
        await repository.completePasswordReset(
          resetToken: 'reset-1',
          password: 'short',
        ),
      );
      expect(short?.failure, AuthFailure.invalidInput);
      expect(short?.field, 'password');
      expect(store.session, isNull);
    });
  });
}
