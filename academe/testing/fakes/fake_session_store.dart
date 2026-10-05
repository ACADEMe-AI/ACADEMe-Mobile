import 'package:academe/data/services/session_store.dart';

class FakeSessionStore implements SessionStore {
  FakeSessionStore([this.session]);

  StoredSession? session;

  @override
  Future<StoredSession?> read() async => session;

  @override
  Future<void> write(StoredSession session) async => this.session = session;

  @override
  Future<void> clear() async => session = null;
}
