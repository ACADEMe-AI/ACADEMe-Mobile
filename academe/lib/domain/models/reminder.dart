import 'folder.dart';
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

List<Reminder> planReminders({
  required DateTime now,
  required StudyPreferences preferences,
  required List<FolderSummary> folders,
  required TodayPlan today,
}) {
  final start = DateTime(now.year, now.month, now.day);
  final dated = [
    for (final f in folders)
      if (f.reminds && f.dueOn != null && preferences.warnsBeforeTests) f,
  ];
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
    if (!evening.isAfter(now) || (soon.isEmpty && !nudges)) continue;
    final left = today.tasks.where((t) => !t.isDone).length;
    final body = d == 0 && left > 0
        ? '$left thing${left == 1 ? '' : 's'} today, about ${today.minutesLeft} min.'
        : 'Your plan for today is ready. One lesson is enough.';
    out.add(
      Reminder(
        id: d * 2,
        at: evening,
        title: soon.isEmpty ? 'Time to study' : soon.join(' · '),
        body: body,
      ),
    );
  }
  return out;
}
