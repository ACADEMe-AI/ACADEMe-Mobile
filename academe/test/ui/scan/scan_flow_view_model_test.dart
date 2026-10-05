import 'package:academe/data/repositories/photo_repository.dart';
import 'package:academe/domain/models/scan.dart';
import 'package:academe/ui/scan/view_models/scan_flow_view_model.dart';
import 'package:academe/ui/scan/view_models/scan_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_photo_repository.dart';
import '../../../testing/fakes/fake_scan_repository.dart';

void main() {
  late FakeScanRepository scans;
  late FakePhotoRepository photos;

  ScanFlowViewModel flow(ScanMode mode) {
    final viewModel = ScanFlowViewModel(
      scanRepository: scans,
      photoRepository: photos,
      mode: mode,
    );
    addTearDown(viewModel.dispose);
    return viewModel;
  }

  setUp(() {
    scans = FakeScanRepository();
    photos = FakePhotoRepository();
  });

  test('solve takes one photo and reads it', () async {
    final viewModel = flow(ScanMode.solve);
    await viewModel.addPages.execute(PhotoSource.camera);
    await viewModel.addPages.execute(PhotoSource.gallery);
    expect(viewModel.pages, ['/tmp/page-1.jpg']);
    expect(photos.picks.last, (PhotoSource.gallery, 1));

    await viewModel.read.execute();
    expect(viewModel.scan?.mode, ScanMode.solve);
    expect(viewModel.failure, isNull);

    await viewModel.linkThread('t1');
    expect(scans.threads, [('s1', 't1')]);
  });

  test('notes collect up to ten pages', () async {
    photos.photos = [for (var i = 0; i < 8; i++) '/tmp/p$i.jpg'];
    final viewModel = flow(ScanMode.notes);
    await viewModel.addPages.execute(PhotoSource.gallery);
    await viewModel.addPages.execute(PhotoSource.gallery);
    expect(viewModel.pages, hasLength(10));
    expect(viewModel.isFull, isTrue);
    expect(photos.picks.last, (PhotoSource.gallery, 2));

    viewModel.removePage(0);
    expect(viewModel.pages, hasLength(9));

    await viewModel.read.execute();
    await viewModel.saveNotes.execute((folderId: 'f1', makeLesson: true));
    expect(scans.notes, [('s1', 'f1', true)]);
  });

  test('check marks with the typed question', () async {
    final viewModel = flow(ScanMode.check);
    await viewModel.addPages.execute(PhotoSource.camera);
    await viewModel.read.execute();
    await viewModel.check.execute('  Define refraction. ');
    expect(scans.lastQuestion, 'Define refraction.');
    expect(viewModel.check.isCompleted, isTrue);
  });

  test('a failed read says why', () async {
    scans.failure = ScanFailure.unavailable;
    final viewModel = flow(ScanMode.ask);
    await viewModel.addPages.execute(PhotoSource.camera);
    await viewModel.read.execute();
    expect(viewModel.scan, isNull);
    expect(viewModel.failure, ScanFailure.unavailable);
  });

  test('recent scans reload after a new scan', () async {
    final recent = ScanViewModel(scanRepository: scans);
    addTearDown(recent.dispose);
    await recent.load.execute();
    expect(recent.recent, isEmpty);

    await scans.read(ScanMode.solve, ['/tmp/a.jpg']);
    await pumpEventQueue();
    expect(recent.recent, hasLength(1));
  });
}
