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
}
