import 'package:academe/domain/models/progress_summary.dart';
import 'package:academe/ui/progress/view_models/progress_view_model.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_billing_repository.dart';
import '../../helpers/test_repositories.dart';

void main() {
  test('ensureLoaded stores weekly summary for Pro', () async {
    final repo = FakeProgressRepository();
    final vm = ProgressViewModel(
      progress: repo,
      billing: FakeBillingRepository(plan: FakeBillingRepository.proPlan),
    );
    addTearDown(vm.dispose);
    await vm.ensureLoaded();
    expect(vm.summary?.lessonsFinishedThisWeek, 5);
    expect(vm.load.result, isA<Ok<ProgressSummary>>());
  });

  test('ensureLoaded skips when free', () async {
    final repo = FakeProgressRepository();
    final vm = ProgressViewModel(
      progress: repo,
      billing: FakeBillingRepository(),
    );
    addTearDown(vm.dispose);
    await vm.ensureLoaded();
    expect(vm.load.result, isNull);
    expect(vm.summary, isNull);
  });

  test('ensureLoaded force runs again after a failed load', () async {
    final repo = FakeProgressRepository()
      ..next = Result.error(Exception('offline'));
    final vm = ProgressViewModel(
      progress: repo,
      billing: FakeBillingRepository(plan: FakeBillingRepository.proPlan),
    );
    addTearDown(vm.dispose);
    await vm.ensureLoaded();
    expect(vm.load.result, isA<Error<ProgressSummary>>());
    expect(vm.summary, isNull);
    repo.next = null;
    await vm.ensureLoaded(force: true);
    expect(vm.summary?.lessonsFinishedThisWeek, 5);
  });

  test('ensureLoaded syncs and retries once after pro_required', () async {
    final billing = FakeBillingRepository(plan: FakeBillingRepository.freePlan)
      ..storeSaysPro = true;
    final repo = FakeProgressRepository()..failProRequiredOnce = true;
    final vm = ProgressViewModel(progress: repo, billing: billing);
    addTearDown(vm.dispose);
    await vm.ensureLoaded();
    expect(billing.syncCalls, 2);
    expect(repo.loadCalls, 2);
    expect(vm.summary?.lessonsFinishedThisWeek, 5);
  });
}
