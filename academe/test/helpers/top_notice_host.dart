import 'package:academe/ui/core/ui/top_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrapWithTopNotice({
  required Widget home,
  Locale locale = const Locale('en'),
  ThemeData? theme,
  List<LocalizationsDelegate<dynamic>>? localizationsDelegates,
  Iterable<Locale>? supportedLocales,
}) {
  final notices = TopNoticeController();
  return TopNoticeScope(
    controller: notices,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales ?? const [Locale('en')],
      theme: theme,
      home: home,
      builder: (context, child) => Stack(
        children: [child ?? const SizedBox.shrink(), const TopNoticeHost()],
      ),
    ),
  );
}

Future<void> pumpUntilNoticeVisible(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
