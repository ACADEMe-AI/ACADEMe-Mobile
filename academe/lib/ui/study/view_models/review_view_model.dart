import 'package:flutter/foundation.dart';

import '../../../data/repositories/folder_repository.dart';
import '../../../data/repositories/study_repository.dart';
import '../../../domain/models/deck.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class ReviewViewModel extends ChangeNotifier {
  ReviewViewModel({
    required StudyRepository studyRepository,
    required FolderRepository folderRepository,
    this.chapterId,
  }) : _repository = studyRepository,
       _folders = folderRepository {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final StudyRepository _repository;
  final FolderRepository _folders;
  final String? chapterId;

  late final Command0<void> load;

  List<ReviewItem> _items = const [];
  int _index = 0;
  bool _isRevealed = false;
  final _ratings = <ReviewRating>[];

  List<ReviewItem> get items => _items;
  int get index => _index;
  ReviewItem get current => _items[_index];
  bool get isRevealed => _isRevealed;
  bool get isFinished => _items.isNotEmpty && _ratings.length == _items.length;
  int countOf(ReviewRating rating) => _ratings.where((r) => r == rating).length;

  void reveal() {
    if (_isRevealed) return;
    _isRevealed = true;
    notifyListeners();
  }

  Future<void> rate(ReviewRating rating) async {
    if (!_isRevealed || isFinished) return;
    final item = current;
    _ratings.add(rating);
    if (_index + 1 < _items.length) {
      _index++;
      _isRevealed = false;
    }
    notifyListeners();
    await _repository.rate(item.deckId, item.card, rating);
    if (isFinished) _folders.studyChanged();
  }

  Future<Result<void>> _load() async {
    final result = await _repository.review(chapterId: chapterId);
    if (result case Ok(:final value)) _items = value;
    return result;
  }

  @override
  void dispose() {
    load
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
