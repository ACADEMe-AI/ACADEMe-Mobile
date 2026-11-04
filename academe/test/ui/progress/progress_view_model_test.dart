import 'package:academe/domain/models/progress_summary.dart';
import 'package:academe/ui/progress/view_models/progress_view_model.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_billing_repository.dart';
import '../../helpers/test_repositories.dart';

void main() {
  test('load stores weekly summary', () async {
    final repo = FakeProgressRepository();
    final vm = ProgressViewModel(
      progress: repo,
      billing: FakeBillingRepository(plan: FakeBillingRepository.proPlan),
    );
    addTearDown(vm.dispose);
    vm.loadIfPro(true);
    await Future<void>.delayed(Duration.zero);
    expect(vm.summary?.lessonsFinishedThisWeek, 5);
    expect(vm.load.result, isA<Ok<ProgressSummary>>());
  });
}
