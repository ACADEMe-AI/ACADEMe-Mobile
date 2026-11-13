import 'dart:async';

import 'package:academe/utils/command.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a command that finishes after dispose does not notify', () async {
    final done = Completer<Result<int>>();
    final command = Command0<int>(() => done.future);
    final running = command.execute();
    command.dispose();
    done.complete(Result.ok(1));
    await expectLater(running, completes);
  });
}
