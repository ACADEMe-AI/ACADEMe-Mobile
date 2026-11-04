import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/models/account.dart';
import '../model/api_models.dart';

class StoredSession {
  const StoredSession({required this.refreshToken, required this.account});

  final String refreshToken;
  final Account account;
}

abstract class SessionStore {
  Future<StoredSession?> read();

  Future<void> write(StoredSession session);

  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _refreshTokenKey = 'refresh_token';
  static const _accountKey = 'account';

  @override
  Future<StoredSession?> read() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      final account = await _storage.read(key: _accountKey);
      if (refreshToken == null || account == null) return null;
      return StoredSession(
        refreshToken: refreshToken,
        account: accountFromJson(jsonDecode(account) as Map<String, Object?>),
      );
    } on Object {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(StoredSession session) async {
    await _storage.write(key: _refreshTokenKey, value: session.refreshToken);
    await _storage.write(
      key: _accountKey,
      value: jsonEncode(accountToJson(session.account)),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accountKey);
  }
}
