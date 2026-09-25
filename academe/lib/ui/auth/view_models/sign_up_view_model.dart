import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/auth_failure.dart';
import '../../../domain/models/auth_method.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

enum SignUpStep { hello, firstName, lastName, email, password, done }

enum EmailProblem { none, notAnEmail, taken }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel({
    required AuthRepository authRepository,
    required this.method,
  }) : _authRepository = authRepository {
    connectProvider = Command0(_connectProvider)..addListener(_onConnected);
    createAccount = Command0(_createAccount)..addListener(_onCreated);
    saveName = Command0(_saveName)..addListener(_onNameSaved);
    if (method != AuthMethod.email) connectProvider.execute();
  }

  final AuthRepository _authRepository;
  final AuthMethod method;

  late final Command0<ProviderSignIn> connectProvider;
  late final Command0<Account> createAccount;
  late final Command0<Account> saveName;

  static const minPasswordLength = 8;
  static final emailShape = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  List<SignUpStep> get steps => method == AuthMethod.email
      ? SignUpStep.values
      : const [
          SignUpStep.hello,
          SignUpStep.firstName,
          SignUpStep.lastName,
          SignUpStep.done,
        ];

  int _index = 0;
  SignUpStep get step => steps[_index];

  double get progress => _index / (steps.length - 1);

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  Account? _providerAccount;
  bool _isReturning = false;
  EmailProblem _emailProblem = EmailProblem.none;

  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;

  bool get isReturning => _isReturning;
  EmailProblem get emailProblem => _emailProblem;

  bool get isEmailValid => emailShape.hasMatch(_email.trim());
  bool get isPasswordLongEnough => _password.length >= minPasswordLength;

  AuthFailure? get failure => switch (step) {
    SignUpStep.hello => _failureOf(connectProvider),
    SignUpStep.password => _failureOf(createAccount),
    SignUpStep.lastName => _failureOf(saveName),
    _ => null,
  };

  bool get canContinue => switch (step) {
    SignUpStep.hello => !connectProvider.isRunning,
    SignUpStep.firstName => _firstName.trim().isNotEmpty,
    SignUpStep.lastName => _lastName.trim().isNotEmpty && !saveName.isRunning,
    SignUpStep.email => _email.trim().isNotEmpty,
    SignUpStep.password => isPasswordLongEnough && !createAccount.isRunning,
    SignUpStep.done => true,
  };

  void setFirstName(String value) {
    if (value != _firstName) _update(() => _firstName = value);
  }

  void setLastName(String value) {
    if (value != _lastName) _update(() => _lastName = value);
  }

  void setPassword(String value) {
    if (value != _password) _update(() => _password = value);
  }

  void setEmail(String value) {
    if (value == _email) return;
    _update(() {
      _email = value;
      _emailProblem = EmailProblem.none;
    });
  }

  void _update(VoidCallback change) {
    change();
    notifyListeners();
  }

  void _goTo(SignUpStep target) =>
      _update(() => _index = steps.indexOf(target));

  void next() {
    if (!canContinue) return;
    switch (step) {
      case SignUpStep.hello when connectProvider.hasError:
        connectProvider.execute();
      case SignUpStep.email when !isEmailValid:
        _update(() => _emailProblem = EmailProblem.notAnEmail);
      case SignUpStep.password:
        createAccount.execute();
      case SignUpStep.lastName when method != AuthMethod.email:
        saveName.execute();
      case _ when _index < steps.length - 1:
        _update(() => _index++);
      case _:
        break;
    }
  }

  bool back() {
    if (_index == 0 || step == SignUpStep.done) return false;
    _update(() => _index--);
    return true;
  }

  Future<Result<ProviderSignIn>> _connectProvider() async {
    if (method != AuthMethod.google) {
      return Result.error(const AuthException(AuthFailure.providerUnavailable));
    }
    return _authRepository.continueWithGoogle();
  }

  void _onConnected() {
    if (connectProvider.result case Ok(:final value)) {
      _providerAccount = value.account;
      _firstName = value.account.firstName;
      _lastName = value.account.lastName;
      _isReturning = !value.isNew;
      if (_isReturning) _index = steps.indexOf(SignUpStep.done);
    }
    notifyListeners();
  }

  Future<Result<Account>> _createAccount() => _authRepository.signUpWithEmail(
    firstName: _firstName.trim(),
    lastName: _lastName.trim(),
    email: _email.trim(),
    password: _password,
  );

  void _onCreated() {
    if (step != SignUpStep.password) return;
    if (createAccount.isCompleted) return _goTo(SignUpStep.done);
    final error = _exceptionOf(createAccount);
    if (error?.failure == AuthFailure.invalidInput ||
        error?.failure == AuthFailure.emailTaken) {
      createAccount.clearResult();
    }
    switch (error) {
      case AuthException(failure: AuthFailure.emailTaken):
        _emailProblem = EmailProblem.taken;
        _goTo(SignUpStep.email);
      case AuthException(failure: AuthFailure.invalidInput, field: 'email'):
        _emailProblem = EmailProblem.notAnEmail;
        _goTo(SignUpStep.email);
      case AuthException(failure: AuthFailure.invalidInput, :final field?)
          when field == 'firstName' || field == 'lastName':
        _goTo(
          field == 'firstName' ? SignUpStep.firstName : SignUpStep.lastName,
        );
      case _:
        break;
    }
  }

  Future<Result<Account>> _saveName() async {
    final account = _providerAccount;
    final first = _firstName.trim();
    final last = _lastName.trim();
    if (account != null &&
        account.firstName == first &&
        account.lastName == last) {
      return Result.ok(account);
    }
    return _authRepository.updateName(firstName: first, lastName: last);
  }

  void _onNameSaved() {
    if (saveName.isCompleted && step == SignUpStep.lastName) {
      _goTo(SignUpStep.done);
    }
  }

  static AuthException? _exceptionOf(Command<Object?> command) =>
      switch (command.result) {
        Error(error: final AuthException error) => error,
        Error() => const AuthException(AuthFailure.unknown),
        _ => null,
      };

  static AuthFailure? _failureOf(Command<Object?> command) =>
      _exceptionOf(command)?.failure;

  @override
  void dispose() {
    connectProvider
      ..removeListener(_onConnected)
      ..dispose();
    createAccount
      ..removeListener(_onCreated)
      ..dispose();
    saveName
      ..removeListener(_onNameSaved)
      ..dispose();
    super.dispose();
  }
}
