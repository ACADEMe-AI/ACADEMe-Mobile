import 'package:academe/domain/models/deck.dart';
import 'package:academe/ui/core/ui/app_button.dart';
import 'package:academe/ui/home/widgets/subject_rows.dart';
import 'package:academe/ui/me/widgets/me_screen.dart';
import 'package:academe/ui/shell/widgets/app_nav_bar.dart';
import 'package:academe/ui/study/widgets/chapter_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_folder_repository.dart';
import '../../../testing/fakes/fake_study_repository.dart';
import '../../helpers/shell_app.dart';

void main() {
  Future<void> pumpShell(
    WidgetTester tester,
    Size size,
    FakeViewPadding inset,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 2.625;
    tester.view.padding = inset;
    tester.view.viewPadding = inset;
    addTearDown(tester.view.reset);
    final folders = FakeFolderRepository();
    for (var i = 1; i <= 8; i++) {
      await folders.create(name: 'Folder $i');
    }
    final studies = FakeStudyRepository()
      ..subjectList = [
        for (final (id, name) in [
          ('maths', 'Maths'),
          ('science', 'Science'),
          ('english', 'English'),
          ('hindi', 'Hindi'),
          ('social', 'Social Science'),
        ])
          SubjectProgress(id: id, name: name, chapters: 12),
      ]
      ..chapterList = [
        for (var n = 1; n <= 12; n++)
          PlannedChapter(
            id: 'cbse-10-science-$n',
            subject: 'science',
            subjectName: 'Science',
            number: n,
            title: 'Chapter $n',
          ),
      ];
    await pumpShellApp(tester, studies: studies, folders: folders);
  }

  Future<void> expectEndAboveBar(WidgetTester tester, Finder last) async {
    final list = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first;
    await tester.fling(list, const Offset(0, -4000), 4000);
    await tester.pumpAndSettle();
    final barTop = tester.getTopLeft(find.byType(AppNavBar)).dy;
    expect(tester.getBottomLeft(last.last).dy, lessThanOrEqualTo(barTop));
  }

  for (final (name, size, inset) in [
    ('portrait', const Size(1080, 2424), const FakeViewPadding(bottom: 63)),
    ('landscape', const Size(2424, 1080), const FakeViewPadding(bottom: 63)),
    (
      'landscape with three-button navigation',
      const Size(2424, 1080),
      const FakeViewPadding(bottom: 126),
    ),
  ]) {
    testWidgets('in $name every tab scrolls its end above the tab bar', (
      tester,
    ) async {
      await pumpShell(tester, size, inset);
      await expectEndAboveBar(tester, find.byType(SubjectRows));
      await tester.tap(find.text('ASKMe'));
      await tester.pumpAndSettle();
      await expectEndAboveBar(tester, find.text('What is photosynthesis?'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Me'));
      await tester.pumpAndSettle();
      await expectEndAboveBar(tester, find.text(MeScreen.version));
      await tester.tap(find.byIcon(Icons.photo_camera_rounded));
      await tester.pumpAndSettle();
      await expectEndAboveBar(tester, find.text('Anything else'));
      await tester.tap(find.text('Study'));
      await tester.pumpAndSettle();
      await expectEndAboveBar(tester, find.byType(ChapterRow));
      await tester.tap(find.text('Folders'));
      await tester.pumpAndSettle();
      await expectEndAboveBar(
        tester,
        find.widgetWithText(AppButton, 'New folder'),
      );
    });
  }
}
