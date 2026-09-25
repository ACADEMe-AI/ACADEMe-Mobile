import 'package:flutter/material.dart';

import '../data/repositories/appearance_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/billing_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/folder_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/repositories/study_repository.dart';
import '../data/services/hint_store.dart';
import '../data/services/preferences_store.dart';
import '../domain/models/account.dart';
import '../domain/models/auth_failure.dart';
import '../domain/models/auth_method.dart';
import '../domain/models/pro.dart';
import '../ui/askme/view_models/askme_view_model.dart';
import '../ui/auth/view_models/forgot_password_view_model.dart';
import '../ui/auth/view_models/login_view_model.dart';
import '../ui/auth/view_models/new_password_view_model.dart';
import '../ui/auth/view_models/reset_code_view_model.dart';
import '../ui/auth/view_models/sign_up_view_model.dart';
import '../ui/auth/widgets/auth_failure_text.dart';
import '../ui/auth/widgets/login_email_screen.dart';
import '../ui/auth/widgets/sign_up_screen.dart';
import '../ui/auth/widgets/welcome_screen.dart';
import '../ui/core/themes/app_theme.dart';
import '../ui/home/view_models/home_view_model.dart';
import '../ui/home/view_models/today_view_model.dart';
import '../ui/me/view_models/me_view_model.dart';
import '../ui/notifications/view_models/notification_primer_view_model.dart';
import '../ui/notifications/widgets/notification_primer_host.dart';
import '../ui/paywall/view_models/pro_view_model.dart';
import '../ui/paywall/widgets/limit_sheet.dart';
import '../ui/paywall/widgets/paywall_screen.dart';
import '../ui/paywall/widgets/pro_manage_screen.dart';
import '../ui/scan/scan_factory.dart';
import '../ui/scan/view_models/scan_view_model.dart';
import '../ui/shell/widgets/app_shell.dart';
import '../ui/splash/widgets/splash_screen.dart';
import '../ui/study/study_factory.dart';
import '../ui/study/view_models/folders_view_model.dart';
import '../ui/study/view_models/study_view_model.dart';
import '../utils/result.dart';
import 'password_reset_pages.dart';
import 'routes.dart';

RouteFactory appRouter({
  required AppearanceRepository appearance,
  required AuthRepository authRepository,
  required ProfileRepository profileRepository,
  required ChatRepository chatRepository,
  required BillingRepository billingRepository,
  required StudyRepository studyRepository,
  required FolderRepository folderRepository,
  required ScanFactory scans,
  required ReminderRepository reminders,
  required HintStore hintStore,
  required PreferencesStore preferencesStore,
  required Future<Result<Account>> restoredSession,
}) {
  return (settings) => _route(
    settings,
    _Dependencies(
      appearance,
      authRepository,
      profileRepository,
      chatRepository,
      billingRepository,
      studyRepository,
      folderRepository,
      scans,
      reminders,
      hintStore,
      preferencesStore,
    ),
    restoredSession,
  );
}

class _Dependencies {
  const _Dependencies(
    this.appearance,
    this.authRepository,
    this.profileRepository,
    this.chatRepository,
    this.billingRepository,
    this.studyRepository,
    this.folderRepository,
    this.scans,
    this.reminders,
    this.hintStore,
    this.preferencesStore,
  );

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
}

void _goHome(BuildContext context, {bool opensSetup = false}) => Navigator.of(
  context,
).pushNamedAndRemoveUntil(Routes.home, (_) => false, arguments: opensSetup);

Future<bool> _logIn(
  BuildContext context,
  AuthRepository authRepository,
  AuthMethod method,
) async {
  if (method == AuthMethod.email) {
    final wantsSignUp = await Navigator.of(
      context,
    ).pushNamed<bool>(Routes.loginEmail);
    return wantsSignUp ?? false;
  }
  final result = method == AuthMethod.google
      ? await authRepository.continueWithGoogle()
      : Result<ProviderSignIn>.error(
          const AuthException(AuthFailure.providerUnavailable),
        );
  if (!context.mounted) return false;
  switch (result) {
    case Ok(:final value):
      _goHome(context, opensSetup: value.isNew);
    case Error(error: AuthException(failure: AuthFailure.canceled)):
      break;
    case Error(:final error):
      final failure = error is AuthException
          ? error.failure
          : AuthFailure.unknown;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
  }
  return false;
}

Route<Object?> _route(
  RouteSettings settings,
  _Dependencies dependencies,
  Future<Result<Account>> restoredSession,
) {
  final authRepository = dependencies.authRepository;
  return switch (settings.name) {
    Routes.welcome => PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration.zero,
      pageBuilder: (context, _, _) => _Light(
        child: WelcomeScreen(
          onSignUp: (method) =>
              Navigator.of(context).pushNamed(Routes.signUp, arguments: method),
          onLogIn: (method) => _logIn(context, authRepository, method),
        ),
      ),
    ),
    Routes.signUp => _RiseRoute<void>(
      settings: settings,
      page: _Light(
        child: _SignUpPage(
          viewModel: SignUpViewModel(
            authRepository: authRepository,
            method: settings.arguments! as AuthMethod,
          ),
        ),
      ),
    ),
    Routes.loginEmail => _RiseRoute<bool>(
      settings: settings,
      page: _Light(
        child: _LoginPage(
          viewModel: LoginViewModel(authRepository: authRepository),
        ),
      ),
    ),
    Routes.forgotPassword => _RiseRoute<void>(
      settings: settings,
      page: _Light(
        child: ForgotPasswordPage(
          viewModel: ForgotPasswordViewModel(
            authRepository: authRepository,
            email: settings.arguments as String? ?? '',
          ),
        ),
      ),
    ),
    Routes.resetCode => _RiseRoute<void>(
      settings: settings,
      page: _Light(
        child: ResetCodePage(
          viewModel: ResetCodeViewModel(
            authRepository: authRepository,
            email: settings.arguments! as String,
          ),
        ),
      ),
    ),
    Routes.newPassword => _RiseRoute<void>(
      settings: settings,
      page: _Light(
        child: NewPasswordPage(
          viewModel: NewPasswordViewModel(
            authRepository: authRepository,
            resetToken: settings.arguments! as String,
          ),
        ),
      ),
    ),
    Routes.paywall => _RiseRoute<bool>(
      settings: settings,
      page: PaywallScreen(
        viewModel: ProViewModel(
          billingRepository: dependencies.billingRepository,
        ),
      ),
    ),
    Routes.proManage => _RiseRoute<void>(
      settings: settings,
      page: ProManageScreen(
        viewModel: ProViewModel(
          billingRepository: dependencies.billingRepository,
        ),
      ),
    ),
    Routes.proLimit => ModalBottomSheetRoute<void>(
      settings: settings,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      barrierLabel: 'Close',
      modalBarrierColor: AppColors.keycapEdge.withValues(alpha: .35),
      backgroundColor: dependencies.appearance.isDark
          ? AppPalette.dark.surface
          : AppPalette.light.surface,
      builder: (context) => LimitSheet(
        viewModel: ProViewModel(
          billingRepository: dependencies.billingRepository,
        ),
        feature: settings.arguments as ProFeature? ?? ProFeature.askme,
      ),
    ),
    Routes.home => PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration.zero,
      pageBuilder: (context, _, _) => _HomePage(
        dependencies: dependencies,
        opensSetup: settings.arguments == true,
      ),
    ),
    _ => PageRouteBuilder<void>(
      settings: settings,
      pageBuilder: (context, _, _) => SplashScreen(
        onDone: () async {
          final session = await restoredSession;
          if (!context.mounted) return;
          await Navigator.of(
            context,
          ).pushReplacementNamed(session is Ok ? Routes.home : Routes.welcome);
        },
      ),
    ),
  };
}

class _HomePage extends StatefulWidget {
  const _HomePage({required this.dependencies, required this.opensSetup});

  final _Dependencies dependencies;
  final bool opensSetup;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  late final _Dependencies _dependencies = widget.dependencies;
  late final _home = HomeViewModel(
    authRepository: _dependencies.authRepository,
    profileRepository: _dependencies.profileRepository,
    hintStore: _dependencies.hintStore,
  );
  late final _askMe = AskMeViewModel(
    chatRepository: _dependencies.chatRepository,
  );
  late final _me = MeViewModel(
    authRepository: _dependencies.authRepository,
    profileRepository: _dependencies.profileRepository,
    preferencesStore: _dependencies.preferencesStore,
    appearance: _dependencies.appearance,
    reminders: _dependencies.reminders,
  );
  late final _pro = ProViewModel(
    billingRepository: _dependencies.billingRepository,
  );
  late final _primer = NotificationPrimerViewModel(
    reminders: _dependencies.reminders,
  );
  late final _study = StudyViewModel(
    studyRepository: _dependencies.studyRepository,
    profileRepository: _dependencies.profileRepository,
  );

  late final _folders = FoldersViewModel(
    folderRepository: _dependencies.folderRepository,
  );
  late final _today = TodayViewModel(
    folderRepository: _dependencies.folderRepository,
  );
  late final _scan = ScanViewModel(
    scanRepository: _dependencies.scans.scanRepository,
  );
  late final _factory = StudyFactory(
    studyRepository: _dependencies.studyRepository,
    profileRepository: _dependencies.profileRepository,
    folderRepository: _dependencies.folderRepository,
  );

  @override
  void initState() {
    super.initState();
    _dependencies.reminders
      ..start()
      ..refreshSoon();
    _dependencies.billingRepository.identify(
      _dependencies.authRepository.account?.id,
    );
  }

  @override
  void dispose() {
    _dependencies.reminders.stop();
    _primer.dispose();
    _pro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationPrimerHost(
      viewModel: _primer,
      child: AppShell(
        viewModel: _home,
        askMe: _askMe,
        me: _me,
        study: _study,
        folders: _folders,
        today: _today,
        factory: _factory,
        scan: _scan,
        scans: _dependencies.scans,
        pro: _pro,
        onRemindersWanted: _dependencies.reminders.refreshSoon,
        opensSetup: widget.opensSetup,
        onLoggedOut: () {
          _dependencies.billingRepository.identify(null);
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.welcome, (_) => false);
        },
      ),
    );
  }
}

class _Light extends StatelessWidget {
  const _Light({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Theme(data: AppTheme.dark(), child: child);
}

class _SignUpPage extends StatelessWidget {
  const _SignUpPage({required this.viewModel});

  final SignUpViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SignUpScreen(
      viewModel: viewModel,
      onFinished: () => _goHome(context, opensSetup: true),
    );
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage({required this.viewModel});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LoginEmailScreen(
      viewModel: viewModel,
      onLoggedIn: () => _goHome(context),
      onSignUp: () => Navigator.of(context).pop(true),
      onForgotPassword: () => Navigator.of(
        context,
      ).pushNamed(Routes.forgotPassword, arguments: viewModel.email),
    );
  }
}

class _RiseRoute<T> extends PageRouteBuilder<T> {
  _RiseRoute({required Widget page, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, _, _) => page,
        transitionsBuilder: (context, animation, _, child) {
          final eased = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: eased,
            child: SlideTransition(
              position: eased.drive(
                Tween(begin: const Offset(0, .06), end: Offset.zero),
              ),
              child: child,
            ),
          );
        },
      );
}
