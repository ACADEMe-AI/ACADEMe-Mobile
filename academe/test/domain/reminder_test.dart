import 'package:academe/domain/models/folder.dart';
import 'package:academe/domain/models/reminder.dart';
import 'package:academe/domain/models/study_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

FolderSummary folder(String name, DateTime due, {bool reminds = true}) =>
    FolderSummary(
      id: name,
      name: name,
      dueOn: due,
      reminds: reminds,
      items: 1,
      todayLeft: 1,
      progress: 0,
    );

void main() {
  final now = DateTime(2026, 10, 5, 12);
  const task = StudyTask(
    kind: TaskKind.lesson,
    title: 'Lesson',
    subtitle: '',
    minutes: 6,
    isDone: false,
  );

  test('daily nudges on chosen days, bundled with test reminders', () {
    final reminders = planReminders(
      now: now,
      preferences: const StudyPreferences(
        remindsToStudy: true,
        reminderDays: {1, 2, 3, 4, 5},
      ),
      folders: [folder('Science test', DateTime(2026, 10, 8))],
      today: const TodayPlan(tasks: [task], reviewDue: 0),
    );

    expect(reminders.first.at, DateTime(2026, 10, 5, 21));
    expect(reminders.first.title, 'Science test in 3 days');
    expect(reminders.first.body, '1 thing today, about 6 min.');
    expect(reminders.map((r) => r.title), contains('Science test is tomorrow'));
    final morning = reminders.firstWhere((r) => r.at.hour == testMorningHour);
    expect(morning.title, 'Science test is today');
    expect(morning.at, DateTime(2026, 10, 8, 7));
    expect(
      reminders.where((r) => r.at.weekday > 5 && r.at.hour == 21),
      isEmpty,
    );
  });

  test('nothing is sent when reminders and folder nudges are off', () {
    expect(
      planReminders(
        now: now,
        preferences: const StudyPreferences(),
        folders: [
          folder('Science test', DateTime(2026, 10, 8), reminds: false),
        ],
        today: TodayPlan.empty,
      ),
      isEmpty,
    );
  });
}
