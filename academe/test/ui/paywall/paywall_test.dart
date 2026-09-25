import 'dart:async';

import 'package:academe/domain/models/chat.dart';
import 'package:academe/domain/models/pro.dart';
import 'package:academe/domain/models/scan.dart';
import 'package:academe/routing/routes.dart';
import 'package:academe/ui/askme/view_models/askme_view_model.dart';
import 'package:academe/ui/askme/widgets/askme_screen.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/paywall/view_models/pro_view_model.dart';
import 'package:academe/ui/paywall/widgets/limit_sheet.dart';
import 'package:academe/ui/paywall/widgets/paywall_screen.dart';
import 'package:academe/ui/paywall/widgets/pro_card.dart';
import 'package:academe/ui/paywall/widgets/pro_manage_screen.dart';
import 'package:academe/ui/scan/widgets/scan_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_billing_repository.dart';
import '../../../testing/fakes/fake_chat_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeBillingRepository billing;

  ProViewModel viewModel() => ProViewModel(billingRepository: billing);

  Route<Object?> route(RouteSettings settings, Widget home) =>
      switch (settings.name) {
        Routes.paywall => MaterialPageRoute<bool>(
          settings: settings,
          builder: (_) => PaywallScreen(viewModel: viewModel()),
        ),
        Routes.proManage => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProManageScreen(viewModel: viewModel()),
        ),
        Routes.proLimit => ModalBottomSheetRoute<void>(
          settings: settings,
          isScrollControlled: true,
          builder: (_) => LimitSheet(
            viewModel: viewModel(),
            feature: settings.arguments! as ProFeature,
          ),
        ),
        _ => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(body: home),
        ),
      };

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          theme: AppTheme.dark(),
          onGenerateRoute: (settings) => route(settings, home),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openPaywall(WidgetTester tester) async {
    await pump(tester, const SizedBox());
    unawaited(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed(Routes.paywall),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => billing = FakeBillingRepository());

  testWidgets('paywall shows both plans, annual first choice', (tester) async {
    await openPaywall(tester);

    expect(find.text('ACADEMe Pro'), findsOneWidget);
    expect(find.text('Unlimited ASKMe questions'), findsOneWidget);
    expect(
      find.text('₹100 for the first month, then ₹200/month'),
      findsOneWidget,
    );
    expect(find.text('Renews automatically'), findsOneWidget);
    expect(find.text('₹1,999/year'), findsOneWidget);
    expect(
      find.text('About ₹167/month · save 17% · renews automatically'),
      findsOneWidget,
    );
    expect(find.text('Best value'), findsOneWidget);
    expect(find.text('Restore purchases'), findsOneWidget);
    expect(
      find.text('Renews automatically. Cancel anytime in Google Play.'),
      findsOneWidget,
    );
    expect(find.text('Terms'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expectOnlyAppFonts(tester);

    await tester.tap(find.text('Monthly'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(billing.purchased, [ProPeriod.monthly]);
    expect(find.byType(PaywallScreen), findsNothing);
    expect(find.text('Welcome to ACADEMe Pro'), findsOneWidget);
  });

  testWidgets('store prices replace the defaults', (tester) async {
    billing.offerList = const [
      ProOffer(period: ProPeriod.monthly, price: '₹210', introPrice: '₹99'),
      ProOffer(period: ProPeriod.annual, price: '₹2,099'),
    ];
    await openPaywall(tester);

    expect(
      find.text('₹99 for the first month, then ₹210/month'),
      findsOneWidget,
    );
    expect(find.text('₹2,099/year'), findsOneWidget);
    expect(find.text('Save 17% · renews automatically'), findsOneWidget);
  });

  testWidgets('without the store the paywall says so', (tester) async {
    billing = FakeBillingRepository(isAvailable: false);
    await openPaywall(tester);

    expect(
      find.text('Purchases aren’t available on this device'),
      findsOneWidget,
    );
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Monthly'), findsNothing);
  });

  testWidgets('pending, cancelled and nothing to restore', (tester) async {
    await openPaywall(tester);

    billing.outcome = PurchaseOutcome.pending;
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your payment is pending'), findsOneWidget);

    billing.outcome = PurchaseOutcome.cancelled;
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('pending'), findsNothing);
    expect(find.byType(PaywallScreen), findsOneWidget);

    await tester.tap(find.text('Restore purchases'));
    await tester.pumpAndSettle();
    expect(
      find.text('No ACADEMe Pro purchase was found on this Google account.'),
      findsOneWidget,
    );

    billing.failure = BillingFailure.network;
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.text('No connection. Check your internet and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('the Pro card opens the paywall, then Manage', (tester) async {
    final card = viewModel();
    addTearDown(card.dispose);
    await pump(tester, ProCard(viewModel: card));

    expect(find.text('Go Pro'), findsOneWidget);
    await tester.tap(find.byType(ProCard));
    await tester.pumpAndSettle();
    expect(find.byType(PaywallScreen), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Manage'), findsOneWidget);
    expect(find.text('Pro · annual'), findsNothing);

    await tester.tap(find.byType(ProCard));
    await tester.pumpAndSettle();
    expect(find.text('You’re on Pro'), findsOneWidget);
    expect(find.text('Monthly plan'), findsOneWidget);
    expect(find.textContaining('Renews on'), findsOneWidget);
    expect(find.text('Manage in Google Play'), findsOneWidget);
  });

  testWidgets('the limit sheet explains the limit and goes Pro', (
    tester,
  ) async {
    await pump(tester, const SizedBox());
    final context = tester.element(find.byType(SizedBox).first);
    unawaited(LimitSheet.show(context, ProFeature.askme));
    await tester.pumpAndSettle();

    expect(find.text('That’s today’s free questions'), findsOneWidget);
    expect(find.textContaining('10 ASKMe questions a day'), findsOneWidget);
    expect(find.textContaining('midnight'), findsOneWidget);

    await tester.tap(find.text('Go Pro'));
    await tester.pumpAndSettle();
    expect(find.byType(LimitSheet), findsNothing);
    expect(find.byType(PaywallScreen), findsOneWidget);
  });

  testWidgets('lessons from notes say they are Pro', (tester) async {
    await pump(tester, const SizedBox());
    unawaited(
      LimitSheet.show(
        tester.element(find.byType(SizedBox).first),
        ProFeature.lessons,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lessons from notes are Pro'), findsOneWidget);
    await tester.tap(find.text('Maybe later'));
    await tester.pumpAndSettle();
    expect(find.byType(LimitSheet), findsNothing);
  });

  testWidgets('ASKMe over the limit opens the sheet', (tester) async {
    final chats = FakeChatRepository();
    final askMe = AskMeViewModel(chatRepository: chats);
    addTearDown(askMe.dispose);
    await pump(
      tester,
      AskMeScreen(
        viewModel: askMe,
        name: 'Riya',
        syllabus: null,
        onBack: () {},
        onHistory: () {},
        onMakeFlashcards: () {},
      ),
    );

    chats.nextFailure = ChatFailure.limitReached;
    await askMe.send.execute('Hello');
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(LimitSheet), findsOneWidget);
    await tester.tap(find.text('Maybe later'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('free questions for today'), findsOneWidget);
    expect(find.text('Go Pro'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('Scan over the limit offers Pro or just the notes', (
    tester,
  ) async {
    var kept = 0;
    var wentPro = 0;
    await pump(
      tester,
      ScanProblem(
        failure: ScanFailure.proOnly,
        onRetry: () => kept++,
        onRetake: () {},
        onGoPro: () => wentPro++,
      ),
    );

    expect(find.text('Lessons from notes are Pro'), findsOneWidget);
    await tester.tap(find.text('Just keep the notes'));
    await tester.tap(find.text('Go Pro'));
    expect((kept, wentPro), (1, 1));
    expect(find.text('Retake'), findsNothing);
  });
}
