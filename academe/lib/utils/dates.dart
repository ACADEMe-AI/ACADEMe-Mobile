import 'plural.dart';

const weekDayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

const _istOffset = Duration(hours: 5, minutes: 30);

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

DateTime indiaClock([DateTime? now]) =>
    (now ?? DateTime.now()).toUtc().add(_istOffset);

int indiaWeekdayIndex([DateTime? now]) => indiaClock(now).weekday - 1;

String shortDay(DateTime day) =>
    '${_weekdays[day.weekday - 1]} ${day.day} ${_months[day.month - 1]}';

String longDate(DateTime day) =>
    '${day.day} ${_months[day.month - 1]} ${day.year}';

String weekday(DateTime day) => _weekdays[day.weekday - 1];

String dueLabel(DateTime due, {DateTime? now}) {
  final days = dateOnly(due).difference(dateOnly(now ?? DateTime.now())).inDays;
  return switch (days) {
    0 => 'Today',
    1 => 'Tomorrow',
    -1 => 'Yesterday',
    < 0 => '${pluralize(-days, 'day')} ago',
    _ => 'in ${pluralize(days, 'day')}',
  };
}

String dueLine(DateTime due, {DateTime? now}) =>
    '${shortDay(due)} · ${dueLabel(due, now: now)}';

String resetsIn(DateTime at, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = at.difference(current);
  if (diff.isNegative) return 'soon';
  if (diff.inHours < 48) {
    final hours = diff.inHours < 1 ? 1 : diff.inHours;
    return 'in ${pluralize(hours, 'hour')}';
  }
  return dueLabel(at, now: current);
}
