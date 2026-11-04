import 'package:academe/data/model/api_models.dart';
import 'package:academe/data/repositories/feedback_repository.dart';
import 'package:academe/domain/models/feedback.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/me/view_models/help_view_model.dart';
import 'package:academe/ui/me/widgets/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_auth_repository.dart';
import '../../helpers/test_repositories.dart';

void main() {
  test('feedbackFailureMessage maps IST rate limits', () {
    expect(
      feedbackFailureMessage(
        const ApiException('too_many_requests', details: {'scope': 'day'}),
      ),
      contains('today'),
    );
    expect(
      feedbackFailureMessage(
        const ApiException('too_many_requests', details: {'scope': 'week'}),
      ),
      contains('week'),
    );
    expect(
      feedbackFailureMessage(const ApiException('invalid_feedback')),
      contains('10 characters'),
    );
  });

  testWidgets('Help lists feedback categories and email', (tester) async {
    final auth = FakeAuthRepository(signedIn: FakeAuthRepository.ada);
    final vm = HelpViewModel(feedback: testFeedbackRepository(auth));
    addTearDown(vm.dispose);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: HelpScreen(viewModel: vm),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(FeedbackCategory.wrongAnswer.label), findsOneWidget);
    expect(find.text(FeedbackCategory.bug.label), findsOneWidget);
    expect(find.text(FeedbackCategory.feature.label), findsOneWidget);
    expect(find.text('Email us'), findsOneWidget);
  });
}
