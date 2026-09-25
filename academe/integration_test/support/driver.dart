import 'package:academe/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const password = 'uitest-pass-1234';

void setUpJourney() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
}

String uniqueEmail(String journey) =>
    'uitest+$journey${DateTime.now().millisecondsSinceEpoch}@academe.test';

Future<void> launchFresh(WidgetTester tester) async {
  await const FlutterSecureStorage().deleteAll();
  await (await SharedPreferences.getInstance()).clear();
  bridge('start');
  await app.main();
  await tester.pause(const Duration(seconds: 3));
}

Future<void> relaunch(WidgetTester tester) async {
  await app.main();
  await tester.pause(const Duration(seconds: 3));
}

void bridge(String command) {
  // ignore: avoid_print
  print('UITEST $command');
}

extension Journey on WidgetTester {
  Future<void> pause([
    Duration time = const Duration(milliseconds: 800),
  ]) async {
    final end = DateTime.now().add(time);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 50));
    }
  }

  Future<Finder> waitFor(
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return finder;
    }
    await shot('timeout');
    fail('Timed out waiting for $finder. On screen: ${visibleTexts()}');
  }

  Future<void> waitGone(
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 100));
      if (finder.hitTestable().evaluate().isEmpty) return;
    }
    await shot('timeout');
    fail('Still showing $finder. On screen: ${visibleTexts()}');
  }

  Future<bool> appears(
    Finder finder, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 100));
      if (finder.hitTestable().evaluate().isNotEmpty) return true;
    }
    return false;
  }

  Future<void> tapOn(
    Finder finder, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    await waitFor(finder.hitTestable(), timeout: timeout);
    await tap(finder.hitTestable().last, warnIfMissed: false);
    await pause();
  }

  Future<void> tapText(
    String text, {
    Duration timeout = const Duration(seconds: 20),
  }) => tapOn(find.text(text), timeout: timeout);

  Future<void> tapTextContaining(String text) =>
      tapOn(find.textContaining(text));

  Future<void> tapIcon(IconData icon) => tapOn(find.byIcon(icon));

  Future<void> fill(String label, String value) async {
    final field = find.widgetWithText(TextField, label);
    await waitFor(field.hitTestable());
    await tap(field.hitTestable().last, warnIfMissed: false);
    await pause(const Duration(milliseconds: 300));
    await enterText(field.hitTestable().last, value);
    await pause(const Duration(milliseconds: 300));
  }

  Future<void> scrollTo(Finder finder, {double delta = 300}) async {
    for (var i = 0; i < 30; i++) {
      if (finder.hitTestable().evaluate().isNotEmpty) return;
      final scrollable = find.byType(Scrollable).hitTestable();
      if (scrollable.evaluate().isEmpty) break;
      await drag(scrollable.first, Offset(0, -delta), warnIfMissed: false);
      await pause(const Duration(milliseconds: 300));
    }
    await waitFor(finder.hitTestable(), timeout: const Duration(seconds: 2));
  }

  Future<void> shot(String name) async {
    bridge('shot $name');
    await pause(const Duration(milliseconds: 700));
  }

  Future<void> host(String command, {Finder? until}) async {
    bridge(command);
    if (until != null) {
      await waitFor(until, timeout: const Duration(seconds: 60));
    }
  }

  List<String> visibleTexts() {
    final texts = <String>{};
    for (final element in find.byType(RichText).hitTestable().evaluate()) {
      final text = (element.widget as RichText).text.toPlainText().trim();
      if (text.isNotEmpty && text.length < 120) texts.add(text);
    }
    return texts.toList();
  }
}
