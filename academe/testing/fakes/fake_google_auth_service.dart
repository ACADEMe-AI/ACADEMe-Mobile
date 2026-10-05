import 'package:academe/data/services/google_auth_service.dart';
import 'package:academe/utils/result.dart';

class FakeGoogleAuthService implements GoogleAuthService {
  FakeGoogleAuthService(this.answer);

  Result<String> answer;
  var signOuts = 0;

  @override
  Future<Result<String>> idToken() async => answer;

  @override
  Future<void> signOut() async => signOuts++;
}
