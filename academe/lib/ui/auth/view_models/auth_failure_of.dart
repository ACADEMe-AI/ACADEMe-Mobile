import '../../../domain/models/auth_failure.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

AuthFailure? authFailureOf(Command<Object?> command) =>
    switch (command.result) {
      Error(error: final AuthException error) => error.failure,
      Error() => AuthFailure.unknown,
      _ => null,
    };
