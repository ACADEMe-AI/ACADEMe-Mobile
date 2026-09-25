import 'package:academe/data/services/hint_store.dart';

class FakeHintStore implements HintStore {
  final seen = <Hint>{};

  @override
  Future<bool> hasSeen(Hint hint) async => seen.contains(hint);

  @override
  Future<void> markSeen(Hint hint) async => seen.add(hint);
}
