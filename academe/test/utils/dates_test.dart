import 'package:academe/utils/dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 4, 21, 30);

  test('due dates say the weekday once and how far away they are', () {
    expect(dueLine(DateTime(2026, 10, 9), now: now), 'Fri 9 Oct · in 5 days');
    expect(dueLine(DateTime(2026, 10, 4), now: now), 'Sun 4 Oct · Today');
    expect(dueLine(DateTime(2026, 10, 5), now: now), 'Mon 5 Oct · Tomorrow');
  });

  test('due labels read sensibly near, far and in the past', () {
    String label(int days) => dueLabel(DateTime(2026, 10, 4 + days), now: now);
    expect(label(0), 'Today');
    expect(label(1), 'Tomorrow');
    expect(label(2), 'in 2 days');
    expect(label(30), 'in 30 days');
    expect(label(-1), 'Yesterday');
    expect(label(-3), '3 days ago');
  });

  test('india clock shifts UTC by five and a half hours', () {
    final utc = DateTime.utc(2026, 11, 2, 18, 30);
    final ist = indiaClock(utc);
    expect(ist.year, 2026);
    expect(ist.month, 11);
    expect(ist.day, 3);
    expect(ist.hour, 0);
    expect(ist.minute, 0);
  });

  test('india weekday index matches the IST calendar day', () {
    final utc = DateTime.utc(2026, 11, 2, 18, 30);
    expect(indiaWeekdayIndex(utc), indiaClock(utc).weekday - 1);
  });
}
