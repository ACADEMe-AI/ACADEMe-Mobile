import '../../domain/models/deck.dart';
import '../../utils/result.dart';
import '../services/study_api_service.dart';
import 'authorizer.dart';
import 'study_repository.dart';

class StudyRepositoryRemote implements StudyRepository {
  StudyRepositoryRemote({
    required StudyApiService api,
    required Authorizer authorizer,
  }) : _api = api,
       _authorizer = authorizer;

  final StudyApiService _api;
  final Authorizer _authorizer;

  Future<Result<T>> _call<T>(Future<Result<T>> Function(String token) call) =>
      _authorizer.authorized(call);

  @override
  Future<Result<StudyCatalogue>> catalogue() => _call(_api.catalogue);

  @override
  Future<Result<Deck>> deck(String id) => _call((t) => _api.deck(t, id));

  @override
  Future<Result<AnswerResult>> answer(
    String deckId, {
    required int card,
    required int choice,
  }) => _call((t) => _api.answer(t, deckId, card: card, choice: choice));

  @override
  Future<Result<void>> complete(String deckId, {required int correct}) =>
      _call((t) => _api.complete(t, deckId, correct: correct));

  @override
  Future<Result<void>> savePosition(String deckId, int card) =>
      _call((t) => _api.savePosition(t, deckId, card));

  @override
  Future<Result<void>> keep(String deckId, int card) =>
      _call((t) => _api.keep(t, deckId, card));

  @override
  Future<Result<void>> unkeep(String deckId, int card) =>
      _call((t) => _api.unkeep(t, deckId, card));

  @override
  Future<Result<List<ReviewItem>>> review({String? chapterId}) =>
      _call((t) => _api.review(t, chapterId: chapterId));

  @override
  Future<Result<void>> rate(String deckId, int card, ReviewRating rating) =>
      _call((t) => _api.rate(t, deckId, card, rating));

  @override
  Future<Result<List<ChapterResult>>> chapterResults() =>
      _call(_api.chapterResults);

  @override
  Future<Result<void>> saveChapterResult(
    String chapterId, {
    required int correct,
    required int total,
  }) => _call(
    (t) => _api.saveChapterResult(t, chapterId, correct: correct, total: total),
  );
}
