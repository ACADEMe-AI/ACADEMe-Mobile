import 'package:academe/data/model/api_models.dart';
import 'package:academe/data/repositories/feedback_repository.dart';
import 'package:academe/l10n/generated/app_localizations.dart';
import 'package:academe/l10n/generated/app_localizations_en.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/me/view_models/help_view_model.dart';
import 'package:academe/ui/me/widgets/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_auth_repository.dart';
import '../../helpers/test_repositories.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('feedbackFailureMessage maps IST rate limits', () {
    expect(
      feedbackFailureMessage(
        const ApiException('too_many_requests', details: {'scope': 'day'}),
        l10n,
      ),
      l10n.feedbackFailDay,
    );
    expect(
      feedbackFailureMessage(
        const ApiException('too_many_requests', details: {'scope': 'week'}),
        l10n,
      ),
      l10n.feedbackFailWeek,
    );
    expect(
      feedbackFailureMessage(const ApiException('invalid_feedback'), l10n),
      l10n.feedbackFailTooShort,
    );
  });

  testWidgets('Help lists feedback categories and email', (tester) async {
    final auth = FakeAuthRepository(signedIn: FakeAuthRepository.ada);
    final vm = HelpViewModel(feedback: testFeedbackRepository(auth));
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(),
          home: HelpScreen(viewModel: vm),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.feedbackWrongAnswer), findsOneWidget);
    expect(find.text(l10n.feedbackBug), findsOneWidget);
    expect(find.text(l10n.feedbackFeature), findsOneWidget);
    expect(find.text(l10n.helpEmailUs), findsOneWidget);
  });
}
