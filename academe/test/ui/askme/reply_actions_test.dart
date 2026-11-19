import 'package:academe/domain/models/chat.dart';
import 'package:academe/l10n/generated/app_localizations.dart';
import 'package:academe/l10n/generated/app_localizations_en.dart';
import 'package:academe/ui/askme/widgets/reply_actions.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/top_notice_host.dart';

void main() {
  const answer = ChatMessage(id: 7, role: ChatRole.pebby, body: 'Light bends');

  Future<List<ReportReason>> pump(
    WidgetTester tester,
    Result<void> outcome,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final reports = <ReportReason>[];
    await tester.pumpWidget(
      PebbyStandIn(
        child: wrapWithTopNotice(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(),
          home: Scaffold(
            body: ReplyActions(
              message: answer,
              onRate: (_) {},
              onRetry: null,
              onReport: (reason) async {
                reports.add(reason);
                return outcome;
              },
            ),
          ),
        ),
      ),
    );
    return reports;
  }

  testWidgets('report asks why, sends it and thanks the student', (
    tester,
  ) async {
    final reports = await pump(tester, Result.ok(null));

    await tester.tap(find.byTooltip('Report'));
    await tester.pumpAndSettle();
    expect(find.text('Report this answer'), findsOneWidget);
    final en = AppLocalizationsEn();
    expect(find.text(en.reportReasonWrong), findsOneWidget);
    expect(find.text(en.reportReasonHarmful), findsOneWidget);
    expect(find.text(en.reportReasonOffensive), findsOneWidget);
    expect(find.text(en.reportReasonOther), findsOneWidget);

    await tester.tap(find.text(en.reportReasonOffensive));
    await pumpUntilNoticeVisible(tester);
    expect(reports, [ReportReason.offensive]);
    expect(find.text('Thanks. We’ll review this answer.'), findsOneWidget);
  });

  testWidgets('closing the sheet sends nothing; a failure says so', (
    tester,
  ) async {
    final reports = await pump(tester, Result.error(Exception('offline')));

    await tester.tap(find.byTooltip('Report'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(reports, isEmpty);

    await tester.tap(find.byTooltip('Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLocalizationsEn().reportReasonWrong));
    await pumpUntilNoticeVisible(tester);
    expect(reports, [ReportReason.wrong]);
    expect(find.text('Couldn’t send the report. Try again.'), findsOneWidget);
  });
}
