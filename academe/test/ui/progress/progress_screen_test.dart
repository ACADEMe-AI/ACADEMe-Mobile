import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/me/view_models/me_view_model.dart';
import 'package:academe/ui/progress/widgets/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_appearance_store.dart';
import '../../../testing/fakes/fake_auth_repository.dart';
import '../../../testing/fakes/fake_billing_repository.dart';
import '../../../testing/fakes/fake_preferences_store.dart';
import '../../../testing/fakes/fake_profile_repository.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required FakeBillingRepository billing,
  }) async {
    final me = MeViewModel(
      authRepository: FakeAuthRepository(signedIn: FakeAuthRepository.ada),
      profileRepository: FakeProfileRepository(),
      preferencesStore: FakePreferencesStore(),
      appearance: AppearanceRepository(store: FakeAppearanceStore()),
      billing: billing,
    );
    addTearDown(me.dispose);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: ProgressScreen(me: me, onGoPro: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('free user sees the Pro hold on My Progress', (tester) async {
    await pump(tester, billing: FakeBillingRepository());
    expect(find.text('My Progress is part of Pro'), findsOneWidget);
  });

  testWidgets('Pro user sees progress stats', (tester) async {
    await pump(
      tester,
      billing: FakeBillingRepository(plan: FakeBillingRepository.proPlan),
    );
    expect(find.text('My Progress is part of Pro'), findsNothing);
    expect(find.textContaining('Your streak, level and XP'), findsOneWidget);
  });
}
