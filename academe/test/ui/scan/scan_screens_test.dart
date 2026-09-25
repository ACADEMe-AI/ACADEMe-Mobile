import 'package:academe/domain/models/scan.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/scan/view_models/scan_flow_view_model.dart';
import 'package:academe/ui/scan/view_models/scan_view_model.dart';
import 'package:academe/ui/scan/widgets/check_result_screen.dart';
import 'package:academe/ui/scan/widgets/scan_flow_screen.dart';
import 'package:academe/ui/scan/widgets/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_photo_repository.dart';
import '../../../testing/fakes/fake_scan_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeScanRepository scans;

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(theme: AppTheme.dark(), home: page),
      ),
    );
    await tester.pump();
  }

  setUp(() => scans = FakeScanRepository());

  testWidgets('the Scan tab offers four jobs and recent scans', (tester) async {
    await scans.read(ScanMode.check, ['/tmp/a.jpg']);
    final started = <ScanMode>[];
    final viewModel = ScanViewModel(scanRepository: scans);
    addTearDown(viewModel.dispose);
    await pump(
      tester,
      Scaffold(
        body: ScanScreen(
          viewModel: viewModel,
          onStart: started.add,
          onOpen: (_) {},
        ),
      ),
    );
    await tester.pump();

    for (final mode in ScanMode.values) {
      expect(find.text(mode.label), findsOneWidget);
    }
    expect(find.text('Recent scans'), findsOneWidget);
    expect(find.textContaining('Not marked yet'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Check my answer'));
    expect(started, [ScanMode.check]);
    expectOnlyAppFonts(tester);
  });

  testWidgets('solve shows the text to fix, then hands it to ASKMe', (
    tester,
  ) async {
    final solved = <String>[];
    final flow = ScanFlowViewModel(
      scanRepository: scans,
      photoRepository: FakePhotoRepository(),
      mode: ScanMode.solve,
      pages: const ['/tmp/a.jpg'],
    );
    await pump(
      tester,
      ScanFlowScreen(
        viewModel: flow,
        onSolve: (_, text) => solved.add(text),
        onAsk: (_, _) {},
        onMarked: (_, _) {},
        onPickFolder: () async => null,
        onSaved: (_) {},
      ),
    );
    await tester.pump();

    expect(find.text('Pebby read this'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Solve x + 1 = 2');
    await tester.tap(find.text('Solve this'));
    expect(solved, ['Solve x + 1 = 2']);
  });

  testWidgets('a scan without Sarvam explains itself', (tester) async {
    scans.failure = ScanFailure.unavailable;
    final flow = ScanFlowViewModel(
      scanRepository: scans,
      photoRepository: FakePhotoRepository(),
      mode: ScanMode.ask,
      pages: const ['/tmp/a.jpg'],
    );
    await pump(
      tester,
      ScanFlowScreen(
        viewModel: flow,
        onSolve: (_, _) {},
        onAsk: (_, _) {},
        onMarked: (_, _) {},
        onPickFolder: () async => null,
        onSaved: (_) {},
      ),
    );
    await tester.pump();

    expect(find.text('Scan isn’t ready yet'), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget);
  });

  testWidgets('notes go to the chosen folder as a lesson', (tester) async {
    final flow = ScanFlowViewModel(
      scanRepository: scans,
      photoRepository: FakePhotoRepository(),
      mode: ScanMode.notes,
    );
    final opened = <String>[];
    await pump(
      tester,
      ScanFlowScreen(
        viewModel: flow,
        onSolve: (_, _) {},
        onAsk: (_, _) {},
        onMarked: (_, _) {},
        onPickFolder: () async => (id: 'f1', name: 'Science test'),
        onSaved: opened.add,
      ),
    );
    await tester.tap(find.text('Gallery'));
    await tester.pump();
    await tester.tap(find.text('Read 1 page'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Pebby read 1 page'), findsOneWidget);
    await tester.tap(find.text('Swipe lesson'));
    await tester.pump();
    await tester.pump();
    expect(scans.notes, [('s1', 'f1', true)]);
    expect(opened, ['f1']);
  });

  testWidgets('the marks screen shows points and hides the model answer', (
    tester,
  ) async {
    await pump(
      tester,
      CheckResultScreen(
        marking: FakeScanRepository.marking,
        chapter: 'Science · Ch 10 · Light',
        onAskPebby: () {},
        onCheckAgain: () {},
      ),
    );

    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('Nearly there'), findsOneWidget);
    expect(find.text('All three in one plane'), findsOneWidget);
    expect(find.textContaining('angle of incidence'), findsNothing);

    await tester.tap(find.text('Show model answer'));
    await tester.pump();
    expect(find.textContaining('angle of incidence'), findsOneWidget);
    expectOnlyAppFonts(tester);
  });
}
