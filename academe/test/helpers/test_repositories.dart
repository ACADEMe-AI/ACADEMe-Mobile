import 'package:academe/data/model/api_models.dart';
import 'package:academe/data/repositories/app_config_repository.dart';
import 'package:academe/data/repositories/feedback_repository.dart';
import 'package:academe/data/repositories/progress_repository.dart';
import 'package:academe/data/services/api_client.dart';
import 'package:academe/data/services/app_config_api_service.dart';
import 'package:academe/data/services/feedback_api_service.dart';
import 'package:academe/domain/models/app_config.dart';
import 'package:academe/domain/models/progress_summary.dart';
import 'package:academe/utils/result.dart';

import '../../testing/fakes/fake_auth_repository.dart';
import '../../testing/fakes/fake_preferences_store.dart';

final _testApi = ApiClient(baseUrl: Uri.parse('http://127.0.0.1:1'));

class _TestAppConfigRepository extends AppConfigRepository {
  _TestAppConfigRepository()
    : super(
        api: AppConfigApiService(_testApi),
        preferences: FakePreferencesStore(),
      );

  @override
  Future<bool> shouldShowSoftBanner(AppConfig config) async => false;

  @override
  Future<void> dismissSoftBanner(AppConfig config) async {}
}

AppConfigRepository testAppConfigRepository() => _TestAppConfigRepository();

FeedbackRepository testFeedbackRepository(FakeAuthRepository authorizer) =>
    FeedbackRepositoryRemote(
      api: FeedbackApiService(_testApi),
      authorizer: authorizer,
    );

class FakeProgressRepository extends ProgressRepository {
  FakeProgressRepository({this.summary = _sample});

  static const _sample = ProgressSummary(
    weekStartsOn: '2026-11-02',
    daysActiveThisWeek: 2,
    lessonsFinishedThisWeek: 5,
    chapterTestsThisWeek: 1,
    xpThisWeek: 30,
    activeDays: [true, false, true, false, false, false, false],
    overallGrade: 72.5,
    bySubject: [
      ProgressSubjectSummary(id: 'science', name: 'Science', lessonsDone: 3),
    ],
  );

  ProgressSummary summary;
  Result<ProgressSummary>? next;
  bool failProRequiredOnce = false;
  int loadCalls = 0;

  @override
  Future<Result<ProgressSummary>> load() async {
    loadCalls++;
    if (failProRequiredOnce && loadCalls == 1) {
      return Result.error(const ApiException('pro_required'));
    }
    return next ?? Result.ok(summary);
  }
}

ProgressRepository testProgressRepository() => FakeProgressRepository();
