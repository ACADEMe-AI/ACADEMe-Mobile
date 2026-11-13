import 'package:academe/data/model/api_models.dart';
import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/l10n/generated/app_localizations.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/me/view_models/me_view_model.dart';
import 'package:academe/ui/progress/view_models/progress_view_model.dart';
import 'package:academe/ui/progress/widgets/progress_screen.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_appearance_store.dart';
import '../../../testing/fakes/fake_auth_repository.dart';
import '../../../testing/fakes/fake_billing_repository.dart';
import '../../../testing/fakes/fake_preferences_store.dart';
import '../../../testing/fakes/fake_profile_repository.dart';
import '../../helpers/test_repositories.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required FakeBillingRepository billing,
    FakeProgressRepository? progressRepo,
  }) async {
    final me = MeViewModel(
      authRepository: FakeAuthRepository(signedIn: FakeAuthRepository.ada),
      profileRepository: FakeProfileRepository(),
      preferencesStore: FakePreferencesStore(),
      appearance: AppearanceRepository(store: FakeAppearanceStore()),
      billing: billing,
    );
    final progress = ProgressViewModel(
      progress: progressRepo ?? testProgressRepository(),
      billing: billing,
    );
    addTearDown(me.dispose);
    addTearDown(progress.dispose);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(),
          home: ProgressScreen(me: me, progress: progress, onGoPro: () {}),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('free user sees the Pro hold on My Progress', (tester) async {
    await pump(tester, billing: FakeBillingRepository());
    expect(find.text('My Progress is part of Pro'), findsOneWidget);
    expect(find.bySemanticsLabel('Pebby'), findsOneWidget);
    expect(find.text('Study days'), findsOneWidget);
  });

  testWidgets('Pro user sees Board summary and study days', (tester) async {
    await pump(
      tester,
      billing: FakeBillingRepository(plan: FakeBillingRepository.proPlan),
    );
    expect(find.text('My Progress is part of Pro'), findsNothing);
    expect(find.text('Study days'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Overall grade'), findsOneWidget);
    expect(find.text('72.50'), findsOneWidget);
    expect(find.text('Subjects this week'), findsOneWidget);
    expect(find.text('Keep your momentum going'), findsOneWidget);
    expect(find.text('See what to do next'), findsOneWidget);
  });

  testWidgets('Pro user keeps the board when the week summary fails', (
    tester,
  ) async {
    final repo = FakeProgressRepository()
      ..next = Result.error(const ApiException(ApiException.network));
    await pump(
      tester,
      billing: FakeBillingRepository(plan: FakeBillingRepository.proPlan),
      progressRepo: repo,
    );
    expect(find.text('My Progress is part of Pro'), findsNothing);
    expect(find.text('Couldn’t load this week’s summary.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Study days'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Overall grade'), findsOneWidget);
  });
}
