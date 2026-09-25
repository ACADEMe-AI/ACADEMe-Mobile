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

String shortDay(DateTime day) =>
    '${_weekdays[day.weekday - 1]} ${day.day} ${_months[day.month - 1]}';

String weekday(DateTime day) => _weekdays[day.weekday - 1];

String dueLabel(DateTime due, {DateTime? now}) {
  final days = dateOnly(due).difference(dateOnly(now ?? DateTime.now())).inDays;
  return switch (days) {
    0 => 'Today',
    1 => 'Tomorrow',
    -1 => 'Yesterday',
    < 0 => '${-days} days ago',
    < 7 => '${_weekdays[due.weekday - 1]} · $days days',
    _ => '$days days',
  };
}
