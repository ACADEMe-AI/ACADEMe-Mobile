import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/domain/models/auth_method.dart';
import 'package:academe/ui/auth/view_models/sign_up_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/fake_auth_repository.dart';

void main() {
  group('email sign-up', () {
    late FakeAuthRepository repository;
    late SignUpViewModel viewModel;

    setUp(() {
      repository = FakeAuthRepository();
      viewModel = SignUpViewModel(
        authRepository: repository,
        method: AuthMethod.email,
      );
    });
    tearDown(() => viewModel.dispose());

    test('walks every step and creates the account', () async {
      expect(viewModel.step, SignUpStep.hello);
      viewModel.next();
      expect(viewModel.step, SignUpStep.firstName);
      expect(viewModel.canContinue, isFalse);

      viewModel
        ..setFirstName(' Maya ')
        ..next()
        ..setLastName('Rao')
        ..next()
        ..setEmail('maya@school.in')
        ..next();
      expect(viewModel.step, SignUpStep.password);

      viewModel.setPassword('short');
      expect(viewModel.canContinue, isFalse);
      viewModel.setPassword('long enough');
      viewModel.next();
      await pumpEventQueue();

      expect(viewModel.step, SignUpStep.done);
      expect(repository.signUps.single.firstName, 'Maya');
      expect(repository.signUps.single.email, 'maya@school.in');
    });

    test('holds on a malformed email and says so', () {
      viewModel
        ..next()
        ..setFirstName('Maya')
        ..next()
        ..setLastName('Rao')
        ..next()
        ..setEmail('maya@school')
        ..next();

      expect(viewModel.step, SignUpStep.email);
      expect(viewModel.emailProblem, EmailProblem.notAnEmail);
      viewModel.setEmail('maya@school');
      expect(
        viewModel.emailProblem,
        EmailProblem.notAnEmail,
        reason: 'same text, no edit',
      );
      viewModel.setEmail('maya@school.in');
      expect(viewModel.emailProblem, EmailProblem.none);
    });

    void fillToPassword() => viewModel
      ..next()
      ..setFirstName('Maya')
      ..next()
      ..setLastName('Rao')
      ..next()
      ..setEmail('maya@school.in')
      ..next()
      ..setPassword('long enough');

    test('stays on the password step when the network fails', () async {
      fillToPassword();
      repository.nextFailure = const AuthException(AuthFailure.network);
      viewModel.next();
      await pumpEventQueue();

      expect(viewModel.step, SignUpStep.password);
      expect(viewModel.failure, AuthFailure.network);
    });

    test('a taken email goes back to the email step and says so', () async {
      fillToPassword();
      repository.nextFailure = const AuthException(AuthFailure.emailTaken);
      viewModel.next();
      await pumpEventQueue();

      expect(viewModel.step, SignUpStep.email);
      expect(viewModel.emailProblem, EmailProblem.taken);
      viewModel.setEmail('maya.rao@school.in');
      expect(viewModel.emailProblem, EmailProblem.none);
    });

    test('back steps one question and stops at the first', () {
      viewModel
        ..next()
        ..setFirstName('Maya')
        ..next();
      expect(viewModel.back(), isTrue);
      expect(viewModel.step, SignUpStep.firstName);
      expect(viewModel.back(), isTrue);
      expect(viewModel.back(), isFalse);
    });
  });

  group('Google sign-up', () {
    late FakeAuthRepository repository;

    setUp(() => repository = FakeAuthRepository());

    Future<SignUpViewModel> connected() async {
      final viewModel = SignUpViewModel(
        authRepository: repository,
        method: AuthMethod.google,
      );
      addTearDown(viewModel.dispose);
      await pumpEventQueue();
      return viewModel;
    }

    test('fills the names and skips email and password', () async {
      final viewModel = await connected();
      expect(viewModel.firstName, 'Ada');

      viewModel
        ..next()
        ..next()
        ..next();
      await pumpEventQueue();

      expect(viewModel.step, SignUpStep.done);
      expect(repository.nameUpdates, isEmpty, reason: 'names unchanged');
    });

    test('saves edited names to the account', () async {
      final viewModel = await connected();
      viewModel
        ..next()
        ..setFirstName('Augusta ')
        ..next()
        ..next();
      await pumpEventQueue();

      expect(viewModel.step, SignUpStep.done);
      expect(repository.nameUpdates.single, ('Augusta', 'Lovelace'));
    });

    test('a returning account goes straight to done', () async {
      repository.googleIsNew = false;
      final viewModel = await connected();

      expect(viewModel.step, SignUpStep.done);
      expect(viewModel.isReturning, isTrue);
    });

    test('a failed connection can be retried from hello', () async {
      repository.nextFailure = const AuthException(AuthFailure.network);
      final viewModel = await connected();
      expect(viewModel.failure, AuthFailure.network);

      viewModel.next();
      await pumpEventQueue();

      expect(viewModel.failure, isNull);
      expect(viewModel.firstName, 'Ada');
    });
  });
}
