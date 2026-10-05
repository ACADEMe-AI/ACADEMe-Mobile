import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/ui/auth/view_models/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late LoginViewModel viewModel;

  setUp(() {
    repository = FakeAuthRepository();
    viewModel = LoginViewModel(authRepository: repository);
  });
  tearDown(() => viewModel.dispose());

  test('needs an email and a password', () {
    expect(viewModel.canLogIn, isFalse);
    viewModel.setEmail('maya@school.in');
    expect(viewModel.canLogIn, isFalse);
    viewModel.setPassword('sunflower');
    expect(viewModel.canLogIn, isTrue);
  });

  test('logs in with the trimmed email', () async {
    viewModel
      ..setEmail(' maya@school.in ')
      ..setPassword('sunflower');
    await viewModel.logIn.execute();

    expect(repository.logIns.single, ('maya@school.in', 'sunflower'));
    expect(viewModel.logIn.isCompleted, isTrue);
  });

  test('shows a wrong password until the next edit', () async {
    viewModel
      ..setEmail('maya@school.in')
      ..setPassword('sunflowers');
    repository.nextFailure = const AuthException(AuthFailure.wrongCredentials);
    await viewModel.logIn.execute();
    expect(viewModel.failure, AuthFailure.wrongCredentials);

    viewModel.setPassword('sunflower');
    expect(viewModel.failure, isNull);
  });
}
