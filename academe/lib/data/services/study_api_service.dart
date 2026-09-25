import '../../domain/models/deck.dart';
import '../../utils/result.dart';
import '../model/deck_models.dart';
import 'api_client.dart';

class StudyApiService {
  StudyApiService(this._api);

  final ApiClient _api;

  Future<Result<StudyCatalogue>> catalogue(String accessToken) => _api.send(
    'GET',
    '/study/decks',
    accessToken: accessToken,
    parse: studyCatalogueFromJson,
  );

  Future<Result<Deck>> deck(String accessToken, String id) => _api.send(
    'GET',
    '/study/decks/$id',
    accessToken: accessToken,
    parse: deckFromJson,
  );

  Future<Result<AnswerResult>> answer(
    String accessToken,
    String deckId, {
    required int card,
    required int choice,
  }) => _api.send(
    'POST',
    '/study/decks/$deckId/answers',
    accessToken: accessToken,
    body: {'card': card, 'choice': choice},
    parse: (json) => (
      isCorrect: json['correct']! as bool,
      xpAwarded: json['xpAwarded']! as int,
    ),
  );

  Future<Result<void>> complete(
    String accessToken,
    String deckId, {
    required int correct,
  }) => _none('PUT', '/study/decks/$deckId/completion', accessToken, {
    'correct': correct,
  });

  Future<Result<void>> savePosition(
    String accessToken,
    String deckId,
    int card,
  ) => _none('PUT', '/study/decks/$deckId/position', accessToken, {
    'card': card,
  });

  Future<Result<void>> keep(String accessToken, String deckId, int card) =>
      _none('PUT', '/study/kept', accessToken, {
        'deckId': deckId,
        'card': card,
      });

  Future<Result<void>> unkeep(String accessToken, String deckId, int card) =>
      _none('DELETE', '/study/kept/$deckId/$card', accessToken, null);

  Future<Result<List<ReviewItem>>> review(
    String accessToken, {
    String? chapterId,
  }) => _api.send(
    'GET',
    chapterId == null
        ? '/study/review'
        : '/study/review?chapter=${Uri.encodeQueryComponent(chapterId)}',
    accessToken: accessToken,
    parse: (json) => [
      for (final item in json['items']! as List<Object?>)
        reviewItemFromJson(item! as Map<String, Object?>),
    ],
  );

  Future<Result<void>> rate(
    String accessToken,
    String deckId,
    int card,
    ReviewRating rating,
  ) => _none('POST', '/study/review', accessToken, {
    'deckId': deckId,
    'card': card,
    'rating': rating.code,
  });

  Future<Result<List<ChapterResult>>> chapterResults(String accessToken) =>
      _api.send(
        'GET',
        '/study/chapter-results',
        accessToken: accessToken,
        parse: (json) => [
          for (final item in json['results']! as List<Object?>)
            chapterResultFromJson(item! as Map<String, Object?>),
        ],
      );

  Future<Result<void>> saveChapterResult(
    String accessToken,
    String chapterId, {
    required int correct,
    required int total,
  }) => _none('PUT', '/study/chapter-results/$chapterId', accessToken, {
    'correct': correct,
    'total': total,
  });

  Future<Result<void>> _none(
    String method,
    String path,
    String accessToken,
    Map<String, Object?>? body,
  ) => _api.send(
    method,
    path,
    accessToken: accessToken,
    body: body,
    parse: (_) {},
  );
}
