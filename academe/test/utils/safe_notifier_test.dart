import 'package:academe/utils/safe_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _Model extends ChangeNotifier with SafeNotifier {}

void main() {
  test('notifying after dispose is ignored', () {
    final model = _Model()..dispose();
    expect(model.isDisposed, isTrue);
    expect(model.notifyListeners, returnsNormally);
  });
}
