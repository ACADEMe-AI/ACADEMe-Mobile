import 'package:flutter/material.dart';

import '../../../data/model/api_models.dart';
import '../../../data/repositories/billing_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../domain/models/progress_summary.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class ProgressViewModel extends ChangeNotifier {
  ProgressViewModel({
    required ProgressRepository progress,
    required BillingRepository billing,
  }) : _progress = progress,
       _billing = billing {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final ProgressRepository _progress;
  final BillingRepository _billing;
  late final Command0<ProgressSummary> load;

  Future<void> ensureLoaded({bool force = false}) async {
    if (!_billing.isPro || load.isRunning) return;
    if (!force && load.isCompleted) return;
    await load.execute();
  }

  ProgressSummary? get summary {
    if (load.result case Ok(value: final value)) return value;
    return null;
  }

  Future<Result<ProgressSummary>> _load() async {
    if (_billing.isPro && !_billing.plan.isPro) {
      await _billing.sync();
    }
    var result = await _progress.load();
    if (result case Error(
      error: ApiException(:final code),
    ) when code == 'pro_required' && _billing.isPro) {
      await _billing.sync();
      result = await _progress.load();
    }
    return result;
  }

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }
}
