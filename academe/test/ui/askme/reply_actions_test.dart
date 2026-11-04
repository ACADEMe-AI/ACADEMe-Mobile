import 'package:academe/domain/models/chat.dart';
import 'package:academe/ui/askme/widgets/reply_actions.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      MaterialApp(
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
    for (final reason in ReportReason.values) {
      expect(find.text(reason.label), findsOneWidget);
    }

    await tester.tap(find.text(ReportReason.offensive.label));
    await tester.pumpAndSettle();
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
    await tester.tap(find.text(ReportReason.wrong.label));
    await tester.pumpAndSettle();
    expect(reports, [ReportReason.wrong]);
    expect(find.text('Couldn’t send the report. Try again.'), findsOneWidget);
  });
}
