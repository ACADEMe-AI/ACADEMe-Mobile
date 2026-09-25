import '../../domain/models/deck.dart';
import '../../utils/result.dart';

abstract class StudyRepository {
  Future<Result<StudyCatalogue>> catalogue();

  Future<Result<Deck>> deck(String id);

  Future<Result<AnswerResult>> answer(
    String deckId, {
    required int card,
    required int choice,
  });

  Future<Result<void>> complete(String deckId, {required int correct});

  Future<Result<void>> savePosition(String deckId, int card);

  Future<Result<void>> keep(String deckId, int card);

  Future<Result<void>> unkeep(String deckId, int card);

  Future<Result<List<ReviewItem>>> review({String? chapterId});

  Future<Result<void>> rate(String deckId, int card, ReviewRating rating);

  Future<Result<List<ChapterResult>>> chapterResults();

  Future<Result<void>> saveChapterResult(
    String chapterId, {
    required int correct,
    required int total,
  });
}
