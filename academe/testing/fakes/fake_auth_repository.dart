import 'package:academe/data/repositories/auth_repository.dart';
import 'package:academe/domain/models/account.dart';
import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/utils/result.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({Account? signedIn}) : _account = signedIn;

  static const ada = Account(
    id: 'google-1',
    firstName: 'Ada',
    lastName: 'Lovelace',
    email: 'ada@gmail.com',
  );

  Account? _account;
  AuthException? nextFailure;
  bool googleIsNew = true;
  final signUps = <Account>[];
  final logIns = <(String, String)>[];
  final nameUpdates = <(String, String)>[];
  var logOuts = 0;
  var deletions = 0;
  static const resetCode = '482913';
  static const resetLink = 'link-token';
  final linkRedemptions = <String>[];
  final resetRequests = <String>[];
  final codeChecks = <(String, String)>[];
  final passwordResets = <(String, String)>[];
  final deletionReasons = <String?>[];
  final passwordChanges = <(String?, String)>[];
  var googleLinks = 0;
  var googleUnlinks = 0;

  @override
  Account? get account => _account;

  Result<T> _answer<T>(T value) {
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      return Result.error(failure);
    }
    return Result.ok(value);
  }

  @override
  Future<Result<Account>> restoreSession() async {
    final account = _account;
    return account == null
        ? Result.error(const AuthException(AuthFailure.signedOut))
        : Result.ok(account);
  }

  @override
  Future<Result<Account>> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final result = _answer(
      Account(
        id: 'account-${signUps.length + 1}',
        firstName: firstName,
        lastName: lastName,
        email: email,
      ),
    );
    if (result case Ok(:final value)) {
      signUps.add(value);
      _account = value;
    }
    return result;
  }

  @override
  Future<Result<Account>> logInWithEmail({
    required String email,
    required String password,
  }) async {
    logIns.add((email, password));
    final result = _answer(
      Account(
        id: 'account-1',
        firstName: 'Maya',
        lastName: 'Rao',
        email: email,
      ),
    );
    if (result case Ok(:final value)) _account = value;
    return result;
  }

  @override
  Future<Result<ProviderSignIn>> continueWithGoogle() async {
    final result = _answer((account: ada, isNew: googleIsNew));
    if (result case Ok()) _account = ada;
    return result;
  }

  @override
  Future<Result<void>> requestPasswordReset({required String email}) async {
    final result = _answer<void>(null);
    if (result case Ok()) resetRequests.add(email);
    return result;
  }

  @override
  Future<Result<String>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    codeChecks.add((email, code));
    if (nextFailure == null && code != resetCode) {
      return Result.error(const AuthException(AuthFailure.wrongCode));
    }
    return _answer('reset-token');
  }

  @override
  Future<Result<String>> redeemResetLink(String linkToken) async {
    linkRedemptions.add(linkToken);
    if (nextFailure == null && linkToken != resetLink) {
      return Result.error(const AuthException(AuthFailure.resetExpired));
    }
    return _answer('link-reset-token');
  }

  @override
  Future<Result<Account>> completePasswordReset({
    required String resetToken,
    required String password,
  }) async {
    passwordResets.add((resetToken, password));
    final result = _answer(
      Account(
        id: 'account-1',
        firstName: 'Maya',
        lastName: 'Rao',
        email: resetRequests.lastOrNull ?? 'maya@example.com',
      ),
    );
    if (result case Ok(:final value)) _account = value;
    return result;
  }

  @override
  Future<Result<Account>> updateName({
    required String firstName,
    required String lastName,
  }) async {
    nameUpdates.add((firstName, lastName));
    final result = _answer(
      (_account ?? ada).copyWith(firstName: firstName, lastName: lastName),
    );
    if (result case Ok(:final value)) _account = value;
    return result;
  }

  @override
  Future<Result<Account>> changePassword({
    String? currentPassword,
    required String newPassword,
  }) async {
    passwordChanges.add((currentPassword, newPassword));
    return _update(
      (account) => Account(
        id: account.id,
        firstName: account.firstName,
        lastName: account.lastName,
        email: account.email,
        googleEmail: account.googleEmail,
      ),
    );
  }

  @override
  Future<Result<Account>> linkGoogle() async {
    googleLinks++;
    return _update(
      (account) => Account(
        id: account.id,
        firstName: account.firstName,
        lastName: account.lastName,
        email: account.email,
        hasPassword: account.hasPassword,
        googleEmail: ada.email,
      ),
    );
  }

  @override
  Future<Result<Account>> unlinkGoogle() async {
    googleUnlinks++;
    return _update(
      (account) => Account(
        id: account.id,
        firstName: account.firstName,
        lastName: account.lastName,
        email: account.email,
        hasPassword: account.hasPassword,
      ),
    );
  }

  Result<Account> _update(Account Function(Account account) change) {
    final result = _answer(change(_account ?? ada));
    if (result case Ok(:final value)) _account = value;
    return result;
  }

  @override
  Future<Result<void>> logOut() async {
    logOuts++;
    _account = null;
    return Result.ok(null);
  }

  @override
  Future<Result<DateTime>> deleteAccount({String? reason}) async {
    final result = _answer(DateTime(2026, 10, 25));
    if (result case Ok()) {
      deletions++;
      deletionReasons.add(reason);
      _account = null;
    }
    return result;
  }
}
