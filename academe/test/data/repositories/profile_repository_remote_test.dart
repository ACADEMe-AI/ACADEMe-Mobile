import 'dart:convert';

import 'package:academe/data/repositories/authorizer.dart';
import 'package:academe/data/repositories/profile_repository_remote.dart';
import 'package:academe/data/services/api_client.dart';
import 'package:academe/data/services/profile_api_service.dart';
import 'package:academe/domain/models/app_language.dart';
import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/domain/models/subject.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _Authorizer implements Authorizer {
  @override
  Future<Result<T>> authorized<T>(
    Future<Result<T>> Function(String accessToken) call,
  ) => call('token-1');
}

void main() {
  final requests = <http.Request>[];
  var offline = false;
  late ProfileRepositoryRemote repository;

  setUp(() {
    requests.clear();
    offline = false;
    final client = MockClient((request) async {
      if (offline) throw http.ClientException('offline');
      requests.add(request);
      return switch ('${request.method} ${request.url.path}') {
        'GET /me/profile' => http.Response(
          jsonEncode({
            'language': 'te',
            'birthYear': null,
            'class': 9,
            'board': 'ICSE',
            'setupDone': false,
            'xp': 0,
          }),
          200,
        ),
        'PATCH /me/profile' => http.Response(
          jsonEncode({
            'language': 'te',
            'birthYear': 2011,
            'class': 9,
            'board': 'ICSE',
            'setupDone': true,
            'xp': 100,
          }),
          200,
        ),
        'GET /catalog/subjects' => http.Response(
          jsonEncode({
            'subjects': [
              {'id': 'maths', 'name': 'Maths'},
            ],
          }),
          200,
        ),
        _ => http.Response('', 404),
      };
    });
    repository = ProfileRepositoryRemote(
      api: ProfileApiService(
        ApiClient(baseUrl: Uri.parse('http://api.test'), client: client),
      ),
      authorizer: _Authorizer(),
    );
  });

  test('load parses the profile and sends the access token', () async {
    final result = await repository.load();

    final profile = (result as Ok<Profile>).value;
    expect(profile.language, AppLanguage.telugu);
    expect(profile.birthYear, isNull);
    expect(profile.classLevel, 9);
    expect(profile.board, Board.icse);
    expect(requests.single.headers['Authorization'], 'Bearer token-1');
    expect(repository.profile, same(profile));
  });

  test('update sends only the fields given', () async {
    final result = await repository.update(
      const ProfileUpdate(birthYear: 2011),
    );

    expect(jsonDecode(requests.single.body), {'birthYear': 2011});
    expect((result as Ok<Profile>).value.setupDone, isTrue);
    expect(repository.profile?.xp, 100);
  });

  test('subjects are fetched once per class and board', () async {
    for (var i = 0; i < 2; i++) {
      final result = await repository.subjects(
        classLevel: 9,
        board: Board.cbse,
      );
      expect((result as Ok<List<Subject>>).value.single.name, 'Maths');
    }
    expect(requests.single.url.query, 'class=9&board=CBSE');
  });

  test('no connection is a network failure', () async {
    offline = true;
    final result = await repository.load();
    expect(
      (result as Error<Profile>).error,
      isA<AuthException>().having(
        (e) => e.failure,
        'failure',
        AuthFailure.network,
      ),
    );
  });
}
