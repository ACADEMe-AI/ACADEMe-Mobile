import '../../utils/plural.dart';
import 'folder.dart';
import 'streak.dart';
import 'study_preferences.dart';

class Reminder {
  const Reminder({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;
}

enum NotificationAccess { unknown, allowed, askable, blocked }

const reminderDays = 7;
const testMorningHour = 7;
const streakReminderIdBase = 100;

List<Reminder> planReminders({
  required DateTime now,
  required StudyPreferences preferences,
  required List<FolderSummary> folders,
  required TodayPlan today,
  Streak streak = const Streak(),
}) {
  final start = DateTime(now.year, now.month, now.day);
  final dated = [
    for (final f in folders)
      if (f.reminds && f.dueOn != null && preferences.warnsBeforeTests) f,
  ];
  final streakAtRisk =
      preferences.savesStreak && streak.current > 0 && !streak.isTodayCounted;
  final goal = preferences.dailyGoalMinutes;
  String withGoal(String text) => goal > 0 ? '$text Goal: $goal min.' : text;

  final out = <Reminder>[];
  for (var d = 0; d < reminderDays; d++) {
    final day = start.add(Duration(days: d));
    final evening = DateTime(
      day.year,
      day.month,
      day.day,
      preferences.reminderHour,
      preferences.reminderMinute,
    );
    final soon = <String>[];
    for (final f in dated) {
      final due = f.dueOn!;
      final left = DateTime(
        due.year,
        due.month,
        due.day,
      ).difference(day).inDays;
      if (left == 3) soon.add('${f.name} in 3 days');
      if (left == 1) soon.add('${f.name} is tomorrow');
      if (left == 0) {
        final morning = DateTime(day.year, day.month, day.day, testMorningHour);
        if (morning.isAfter(now)) {
          out.add(
            Reminder(
              id: d * 2 + 1,
              at: morning,
              title: '${f.name} is today',
              body:
                  'A 5-minute recap of what you kept will help. You’re ready.',
            ),
          );
        }
      }
    }
    final nudges =
        preferences.remindsToStudy &&
        preferences.reminderDays.contains(day.weekday);
    if (!evening.isAfter(now)) continue;
    if (soon.isEmpty && !nudges && !(d == 0 && streakAtRisk)) continue;

    final left = today.tasks.where((t) => !t.isDone).length;
    final streakToday = d == 0 && streakAtRisk;
    final title = soon.isNotEmpty
        ? soon.join(' · ')
        : streakToday
        ? 'Keep your streak'
        : 'Time to study';
    final body = withGoal(
      soon.isNotEmpty
          ? (d == 0 && left > 0
                ? '${pluralize(left, 'thing')} today, about ${today.minutesLeft} min.'
                : 'Your plan for today is ready. One lesson is enough.')
          : streakToday
          ? 'Study once today to keep your ${streak.current}-day streak.'
          : (d == 0 && left > 0
                ? '${pluralize(left, 'thing')} today, about ${today.minutesLeft} min.'
                : 'Your plan for today is ready. One lesson is enough.'),
    );
    out.add(
      Reminder(
        id: soon.isEmpty && !nudges && streakToday
            ? streakReminderIdBase + d
            : d * 2,
        at: evening,
        title: title,
        body: body,
      ),
    );
  }
  return out;
}
