import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/environment.dart';
import 'data/repositories/appearance_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_remote.dart';
import 'data/repositories/billing_repository.dart';
import 'data/repositories/billing_repository_remote.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/chat_repository_remote.dart';
import 'data/repositories/folder_repository.dart';
import 'data/repositories/folder_repository_remote.dart';
import 'data/repositories/photo_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/profile_repository_remote.dart';
import 'data/repositories/reminder_repository.dart';
import 'data/repositories/scan_repository_remote.dart';
import 'data/repositories/study_repository.dart';
import 'data/repositories/study_repository_remote.dart';
import 'data/services/api_client.dart';
import 'data/services/appearance_store.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/billing_api_service.dart';
import 'data/services/chat_api_service.dart';
import 'data/services/folder_api_service.dart';
import 'data/services/google_auth_service.dart';
import 'data/services/hint_store.dart';
import 'data/services/notification_service.dart';
import 'data/services/preferences_store.dart';
import 'data/services/profile_api_service.dart';
import 'data/services/purchases_service.dart';
import 'data/services/scan_api_service.dart';
import 'data/services/session_store.dart';
import 'data/services/study_api_service.dart';
import 'domain/models/account.dart';
import 'routing/deep_links.dart';
import 'routing/router.dart';
import 'ui/core/themes/app_theme.dart';
import 'ui/scan/scan_factory.dart';
import 'utils/result.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized().addObserver(DeepLinkFilter());
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final api = ApiClient(baseUrl: Environment.apiBaseUrl);
  final authRepository = AuthRepositoryRemote(
    api: AuthApiService(api),
    sessionStore: SecureSessionStore(),
    google: GoogleSignInPluginService(
      serverClientId: Environment.googleServerClientId,
    ),
  );
  final appearance = await AppearanceRepository.load(
    SharedPreferencesAppearanceStore(),
  );
  final folderRepository = FolderRepositoryRemote(
    api: FolderApiService(api),
    authorizer: authRepository,
  );
  final scans = ScanFactory(
    scanRepository: ScanRepositoryRemote(
      api: ScanApiService(api),
      authorizer: authRepository,
      folders: folderRepository,
    ),
    photoRepository: DevicePhotoRepository(),
  );
  final hintStore = SharedPreferencesHintStore();
  final preferencesStore = SharedPreferencesStore();
  runApp(
    AcademeApp(
      folderRepository: folderRepository,
      scans: scans,
      reminders: ReminderRepository(
        notifications: LocalNotificationService(),
        folderRepository: folderRepository,
        preferencesStore: preferencesStore,
        hintStore: hintStore,
      ),
      appearance: appearance,
      authRepository: authRepository,
      profileRepository: ProfileRepositoryRemote(
        api: ProfileApiService(api),
        authorizer: authRepository,
      ),
      billingRepository: BillingRepositoryRemote(
        api: BillingApiService(api),
        authorizer: authRepository,
        purchases: RevenueCatPurchasesService(
          apiKey: Environment.revenueCatApiKey,
        ),
      ),
      chatRepository: ChatRepositoryRemote(
        api: ChatApiService(api),
        authorizer: authRepository,
      ),
      studyRepository: StudyRepositoryRemote(
        api: StudyApiService(api),
        authorizer: authRepository,
      ),
      hintStore: hintStore,
      preferencesStore: preferencesStore,
      restoredSession: authRepository.restoreSession(),
    ),
  );
}

class AcademeApp extends StatelessWidget {
  const AcademeApp({
    super.key,
    required this.appearance,
    required this.authRepository,
    required this.profileRepository,
    required this.chatRepository,
    required this.billingRepository,
    required this.studyRepository,
    required this.folderRepository,
    required this.scans,
    required this.reminders,
    required this.hintStore,
    required this.preferencesStore,
    required this.restoredSession,
  });

  final AppearanceRepository appearance;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final ChatRepository chatRepository;
  final BillingRepository billingRepository;
  final StudyRepository studyRepository;
  final FolderRepository folderRepository;
  final ScanFactory scans;
  final ReminderRepository reminders;
  final HintStore hintStore;
  final PreferencesStore preferencesStore;
  final Future<Result<Account>> restoredSession;

  @override
  Widget build(BuildContext context) {
    final router = appRouter(
      appearance: appearance,
      authRepository: authRepository,
      profileRepository: profileRepository,
      chatRepository: chatRepository,
      billingRepository: billingRepository,
      studyRepository: studyRepository,
      folderRepository: folderRepository,
      scans: scans,
      reminders: reminders,
      hintStore: hintStore,
      preferencesStore: preferencesStore,
      restoredSession: restoredSession,
    );
    return ListenableBuilder(
      listenable: appearance,
      builder: (context, _) => MaterialApp(
        title: 'ACADEMe',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(
          palette: appearance.isDark ? AppPalette.dark : AppPalette.light,
        ),
        onGenerateRoute: router,
      ),
    );
  }
}
