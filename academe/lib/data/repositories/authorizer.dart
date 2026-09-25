import '../../utils/result.dart';

abstract interface class Authorizer {
  Future<Result<T>> authorized<T>(
    Future<Result<T>> Function(String accessToken) call,
  );
}
