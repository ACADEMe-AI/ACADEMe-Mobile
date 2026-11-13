import 'package:academe/utils/plural.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('one is singular, every other count is plural', () {
    expect(pluralize(1, 'lesson'), '1 lesson');
    expect(pluralize(0, 'lesson'), '0 lessons');
    expect(pluralize(2, 'quick check'), '2 quick checks');
  });
}
