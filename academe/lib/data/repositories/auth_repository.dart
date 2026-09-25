import '../../domain/models/account.dart';
import '../../utils/result.dart';

typedef ProviderSignIn = ({Account account, bool isNew});

abstract class AuthRepository {
  Account? get account;

  Future<Result<Account>> restoreSession();

  Future<Result<Account>> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  Future<Result<Account>> logInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<ProviderSignIn>> continueWithGoogle();

  Future<Result<void>> requestPasswordReset({required String email});

  Future<Result<String>> verifyResetCode({
    required String email,
    required String code,
  });

  Future<Result<String>> redeemResetLink(String linkToken);

  Future<Result<Account>> completePasswordReset({
    required String resetToken,
    required String password,
  });

  Future<Result<Account>> updateName({
    required String firstName,
    required String lastName,
  });

  Future<Result<Account>> changePassword({
    String? currentPassword,
    required String newPassword,
  });

  Future<Result<Account>> linkGoogle();

  Future<Result<Account>> unlinkGoogle();

  Future<Result<void>> logOut();

  Future<Result<DateTime>> deleteAccount({String? reason});
}
