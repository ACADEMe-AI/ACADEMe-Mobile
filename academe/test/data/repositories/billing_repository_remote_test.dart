import 'dart:convert';

import 'package:academe/data/repositories/authorizer.dart';
import 'package:academe/data/repositories/billing_repository.dart';
import 'package:academe/data/repositories/billing_repository_remote.dart';
import 'package:academe/data/repositories/chat_repository_remote.dart';
import 'package:academe/data/repositories/scan_repository_remote.dart';
import 'package:academe/data/services/api_client.dart';
import 'package:academe/data/services/billing_api_service.dart';
import 'package:academe/data/services/chat_api_service.dart';
import 'package:academe/data/services/scan_api_service.dart';
import 'package:academe/domain/models/chat.dart';
import 'package:academe/domain/models/pro.dart';
import 'package:academe/domain/models/scan.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../../testing/fakes/fake_folder_repository.dart';
import '../../../testing/fakes/fake_purchases_service.dart';

class _Authorizer implements Authorizer {
  @override
  Future<Result<T>> authorized<T>(
    Future<Result<T>> Function(String accessToken) call,
  ) => call('token-1');
}

Map<String, Object?> _plan({required bool isPro}) => {
  'plan': isPro ? 'pro' : 'free',
  'expiresAt': isPro ? '2026-10-25T10:00:00Z' : null,
  'autoRenew': isPro,
  'productId': isPro ? 'academe_pro' : null,
  'basePlanId': isPro ? 'annual' : null,
  'platform': isPro ? 'play_store' : null,
  'state': isPro ? 'active' : null,
  'limits': isPro
      ? {'askme': null, 'scan': null, 'check': null, 'lessons': null}
      : {'askme': 10, 'scan': 3, 'check': 1, 'lessons': 0},
  'usedToday': {'askme': 4, 'scan': 0, 'check': 1, 'lessons': 0},
  'resetsAt': '2026-09-25T18:30:00Z',
};

http.Response _limit(String code, String feature) => http.Response(
  jsonEncode({
    'error': {
      'code': code,
      'message': 'Limit',
      'requestId': 'r1',
      'details': {
        'feature': feature,
        'limit': 1,
        'resetsAt': '2026-09-25T18:30:00Z',
      },
    },
  }),
  402,
);

void main() {
  final requests = <String>[];
  var synced = false;
  var syncStatus = 200;
  late FakePurchasesService purchases;
  late BillingRepositoryRemote repository;

  ApiClient client() => ApiClient(
    baseUrl: Uri.parse('http://api.test'),
    client: MockClient((request) async {
      requests.add('${request.method} ${request.url.path}');
      return switch ('${request.method} ${request.url.path}') {
        'GET /me/plan' => http.Response(jsonEncode(_plan(isPro: false)), 200),
        'POST /billing/sync' when syncStatus == 429 => http.Response(
          jsonEncode({
            'error': {
              'code': 'too_many_requests',
              'message': 'Wait',
              'requestId': 'r1',
            },
          }),
          429,
        ),
        'POST /billing/sync' => http.Response(
          jsonEncode(_plan(isPro: synced)),
          200,
        ),
        'POST /chat/messages' ||
        'POST /chat/threads/t1/retry' => _limit('limit_reached', 'askme'),
        'POST /scans/s1/check' => _limit('limit_reached', 'check'),
        'POST /scans/s1/notes' => _limit('pro_only', 'lessons'),
        _ => http.Response('{}', 404),
      };
    }),
  );

  setUp(() {
    requests.clear();
    synced = true;
    syncStatus = 200;
    purchases = FakePurchasesService();
    repository = BillingRepositoryRemote(
      api: BillingApiService(client()),
      authorizer: _Authorizer(),
      purchases: purchases,
    );
  });

  test('refresh reads the plan and its limits', () async {
    final result = await repository.refresh();
    final plan = (result as Ok<ProPlan>).value;
    expect(plan.isPro, isFalse);
    expect(plan.limitOf(ProFeature.askme), 10);
    expect(plan.limitOf(ProFeature.lessons), 0);
    expect(plan.usedToday[ProFeature.askme], 4);
    expect(plan.resetsAt, DateTime.utc(2026, 9, 25, 18, 30));
    expect(repository.isPro, isFalse);
  });

  test('a purchase syncs with the server and turns Pro on', () async {
    var notified = 0;
    repository.addListener(() => notified++);
    final result = await repository.purchase(ProPeriod.annual);
    expect((result as Ok<PurchaseOutcome>).value, PurchaseOutcome.purchased);
    expect(requests, ['POST /billing/sync']);
    expect(repository.isPro, isTrue);
    expect(repository.plan.period, ProPeriod.annual);
    expect(repository.plan.limitOf(ProFeature.askme), isNull);
    expect(repository.manageUrl, contains('play.google.com'));
    expect(notified, greaterThan(0));
  });

  test('a throttled sync still leaves the store\'s Pro on', () async {
    syncStatus = 429;
    final result = await repository.purchase(ProPeriod.monthly);
    expect((result as Ok<PurchaseOutcome>).value, PurchaseOutcome.purchased);
    expect(repository.isPro, isTrue);
    final restored = await repository.restore();
    expect((restored as Ok<bool>).value, isTrue);
  });

  test('cancelled and pending purchases do not sync', () async {
    for (final outcome in [
      PurchaseOutcome.cancelled,
      PurchaseOutcome.pending,
    ]) {
      purchases.outcome = outcome;
      final result = await repository.purchase(ProPeriod.monthly);
      expect((result as Ok<PurchaseOutcome>).value, outcome);
    }
    expect(requests, isEmpty);
    expect(repository.isPro, isFalse);
  });

  test('store errors come back as billing failures', () async {
    purchases.failure = BillingFailure.network;
    final result = await repository.purchase(ProPeriod.monthly);
    expect(
      ((result as Error).error as BillingException).failure,
      BillingFailure.network,
    );
  });

  test('restore finds nothing when the store has no Pro', () async {
    synced = false;
    purchases.customer = StoreCustomer.none;
    final result = await repository.restore();
    expect((result as Ok<bool>).value, isFalse);
    expect(requests, ['POST /billing/sync']);
  });

  test('the store listener turns Pro on without the server', () {
    purchases.listener!(const StoreCustomer(isPro: true));
    expect(repository.isPro, isTrue);
    expect(repository.manageUrl, BillingRepository.playSubscriptionsUrl);
  });

  test('identify logs in and out of the store', () async {
    await repository.identify('acct-1');
    expect(purchases.loggedIn, ['acct-1']);
    expect(requests, ['GET /me/plan']);
    await repository.identify(null);
    expect(purchases.logOuts, 1);
    expect(repository.plan.isPro, isFalse);
  });

  test('switching accounts drops the last account\'s Pro', () async {
    await repository.identify('acct-1');
    purchases.listener!(const StoreCustomer(isPro: true));
    expect(repository.isPro, isTrue);
    purchases.failure = BillingFailure.network;
    await repository.identify('acct-2');
    expect(purchases.loggedIn, ['acct-1', 'acct-2']);
    expect(repository.isPro, isFalse);
  });

  test('limit errors map to the ASKMe and Scan failures', () async {
    final chats = ChatRepositoryRemote(
      api: ChatApiService(client()),
      authorizer: _Authorizer(),
    );
    final sent = await chats.send(
      threadId: null,
      mode: ChatMode.explain,
      text: 'hi',
    );
    expect(
      ((sent as Error).error as ChatException).failure,
      ChatFailure.limitReached,
    );
    final retried = await chats.regenerate('t1', ChatMode.explain);
    expect(
      ((retried as Error).error as ChatException).failure,
      ChatFailure.limitReached,
    );
    final scans = ScanRepositoryRemote(
      api: ScanApiService(client()),
      authorizer: _Authorizer(),
      folders: FakeFolderRepository(),
    );
    final checked = await scans.check('s1', '');
    expect(
      ((checked as Error).error as ScanException).failure,
      ScanFailure.checkLimit,
    );
    final saved = await scans.saveNotes('s1', folderId: 'f1', makeLesson: true);
    expect(
      ((saved as Error).error as ScanException).failure,
      ScanFailure.proOnly,
    );
  });
}
