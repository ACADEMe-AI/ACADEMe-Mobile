import 'package:academe/domain/models/level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each level needs 50 XP more than the last', () {
    expect(Level.of(0).number, 1);
    expect(Level.of(99).number, 1);
    expect(Level.of(100).number, 2);
    expect(Level.of(249).number, 2);
    expect(Level.of(250).number, 3);
    final level = Level.of(340);
    expect(level.number, 3);
    expect(level.toNext(340), 110);
    expect(level.progress(340), closeTo(90 / 200, 1e-9));
  });
}
