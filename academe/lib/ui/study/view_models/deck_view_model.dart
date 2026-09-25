import 'package:flutter/foundation.dart';

import '../../../data/repositories/folder_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/study_repository.dart';
import '../../../domain/models/deck.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

typedef SessionCard = ({
  String deckId,
  int card,
  String lessonTitle,
  DeckCard content,
});
typedef DeckStep = ({int card, bool isWhy});
typedef LessonScore = ({String title, int correct, int total});

class DeckViewModel extends ChangeNotifier {
  DeckViewModel.lesson({
    required StudyRepository studyRepository,
    required ProfileRepository profileRepository,
    required FolderRepository folderRepository,
    required String deckId,
  }) : this._(
         studyRepository,
         profileRepository,
         folderRepository,
         deckIds: [deckId],
         chapterId: null,
       );

  DeckViewModel.chapterTest({
    required StudyRepository studyRepository,
    required ProfileRepository profileRepository,
    required FolderRepository folderRepository,
    required String chapterId,
    required List<String> deckIds,
    required String title,
  }) : this._(
         studyRepository,
         profileRepository,
         folderRepository,
         deckIds: deckIds,
         chapterId: chapterId,
         title: title,
       );

  DeckViewModel._(
    this._repository,
    this._profiles,
    this._folders, {
    required this.deckIds,
    required this.chapterId,
    String title = '',
  }) : _title = title {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final StudyRepository _repository;
  final ProfileRepository _profiles;
  final FolderRepository _folders;
  final List<String> deckIds;
  final String? chapterId;

  late final Command0<void> load;

  String _title;
  List<SessionCard> _cards = const [];
  List<DeckStep> _steps = const [];
  int _index = 0;
  final _picks = <int, int>{};
  final _results = <int, bool>{};
  final _revealed = <int, int>{};
  final _kept = <int>{};
  final _streakAt = <int, int>{};
  final _xpAt = <int, int>{};
  int _streak = 0;
  int _xpEarned = 0;
  bool _isFinished = false;

  bool get isChapterTest => chapterId != null;
  bool get isLoaded => _cards.isNotEmpty;
  String get title => _title;
  List<SessionCard> get cards => _cards;
  int get index => _index;
  DeckStep get step => _steps[_index];
  SessionCard get current => _cards[step.card];
  bool get hasNext => _index + 1 < _steps.length;
  int? pickOf(int card) => _picks[card];
  bool? resultOf(int card) => _results[card];
  int revealedOf(int card) => _revealed[card] ?? 1;
  bool isKept(int card) => _kept.contains(card);
  int streakAt(int card) => _streakAt[card] ?? 0;
  int xpAt(int card) => _xpAt[card] ?? 0;
  bool get isPerfect => quizCount > 0 && correctCount == quizCount;
  int get keptCount => _kept.length;
  int get xpEarned => _xpEarned;
  bool get isFinished => _isFinished;
  int get correctCount => _results.values.where((r) => r).length;
  int get quizCount => _cards.where((c) => c.content is QuizCard).length;

  List<LessonScore> get lessonScores {
    final out = <String, (int, int)>{};
    for (var i = 0; i < _cards.length; i++) {
      if (_cards[i].content is! QuizCard) continue;
      final (right, total) = out[_cards[i].lessonTitle] ?? (0, 0);
      out[_cards[i].lessonTitle] = (
        right + ((_results[i] ?? false) ? 1 : 0),
        total + 1,
      );
    }
    return [
      for (final MapEntry(:key, :value) in out.entries)
        (title: key, correct: value.$1, total: value.$2),
    ];
  }

  bool get needsCheck =>
      !step.isWhy &&
      current.content is QuizCard &&
      !_results.containsKey(step.card);

  bool get hasHiddenStep {
    final content = current.content;
    return !step.isWhy &&
        content is ExampleCard &&
        revealedOf(step.card) < content.steps.length;
  }

  bool get canGoForward => !needsCheck;
  bool get canGoBack => _index > 0;

  void pick(int choice) {
    if (!needsCheck) return;
    _picks[step.card] = choice;
    notifyListeners();
  }

  void revealStep() {
    if (!hasHiddenStep) return;
    _revealed[step.card] = revealedOf(step.card) + 1;
    notifyListeners();
  }

  Future<void> check() async {
    final at = step.card;
    final card = _cards[at];
    final quiz = card.content;
    final choice = _picks[at];
    if (quiz is! QuizCard || choice == null || _results.containsKey(at)) {
      return;
    }
    final isCorrect = choice == quiz.answer;
    _results[at] = isCorrect;
    _streak = isCorrect ? _streak + 1 : 0;
    _streakAt[at] = _streak;
    if (!isCorrect) {
      _kept.add(at);
      _steps = [..._steps]..insert(_index + 1, (card: at, isWhy: true));
    }
    notifyListeners();
    final result = await _repository.answer(
      card.deckId,
      card: card.card,
      choice: choice,
    );
    if (result case Ok(:final value) when value.xpAwarded > 0) {
      _xpEarned += value.xpAwarded;
      _xpAt[at] = value.xpAwarded;
      notifyListeners();
    }
  }

  Future<void> toggleKeep(int at) async {
    final card = _cards[at];
    final keep = !_kept.contains(at);
    keep ? _kept.add(at) : _kept.remove(at);
    notifyListeners();
    final result = keep
        ? await _repository.keep(card.deckId, card.card)
        : await _repository.unkeep(card.deckId, card.card);
    if (result is Error) {
      keep ? _kept.remove(at) : _kept.add(at);
      notifyListeners();
    }
  }

  Future<void> primary() async {
    if (hasHiddenStep) return revealStep();
    if (needsCheck) return check();
    await forward();
  }

  Future<void> forward() async {
    if (!canGoForward) return;
    if (hasNext) {
      _index++;
      notifyListeners();
      _savePosition();
      return;
    }
    _isFinished = true;
    notifyListeners();
    if (chapterId case final id?) {
      await _repository.saveChapterResult(
        id,
        correct: correctCount,
        total: quizCount,
      );
    } else {
      await _repository.complete(deckIds.single, correct: correctCount);
      await _repository.savePosition(deckIds.single, 0);
    }
    _folders.studyChanged();
    await _profiles.load();
  }

  void back() {
    if (!canGoBack) return;
    _index--;
    notifyListeners();
    _savePosition();
  }

  void _savePosition() {
    if (isChapterTest || step.isWhy) return;
    _repository.savePosition(deckIds.single, step.card);
  }

  Future<Result<void>> _load() async {
    final cards = <SessionCard>[];
    for (final id in deckIds) {
      final result = await _repository.deck(id);
      if (result case Error(:final error)) return Result.error(error);
      final deck = (result as Ok<Deck>).value;
      if (!isChapterTest) _title = deck.title;
      for (var i = 0; i < deck.cards.length; i++) {
        final content = deck.cards[i];
        if (isChapterTest && content is! QuizCard) continue;
        if (!isChapterTest && deck.kept.contains(i)) _kept.add(cards.length);
        cards.add((
          deckId: id,
          card: i,
          lessonTitle: deck.title,
          content: content,
        ));
      }
      if (!isChapterTest && deck.resumeCard < deck.cards.length) {
        _index = deck.resumeCard;
      }
    }
    _cards = cards;
    _steps = [for (var i = 0; i < cards.length; i++) (card: i, isWhy: false)];
    if (_index >= _steps.length) _index = 0;
    return Result.ok(null);
  }

  @override
  void dispose() {
    load
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
