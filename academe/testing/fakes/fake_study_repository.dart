import 'package:academe/data/repositories/study_repository.dart';
import 'package:academe/domain/models/deck.dart';
import 'package:academe/utils/result.dart';

class FakeStudyRepository implements StudyRepository {
  static const reflection = Deck(
    id: 'deck-1',
    chapterNumber: 9,
    chapterTitle: 'Light',
    title: 'Reflection',
    cards: [
      StartCard(goals: ['Use the laws of reflection'], minutes: 5),
      ConceptCard(
        title: 'Light travels straight',
        body: 'It **bounces**.',
        remember: 'Measure from the normal.',
      ),
      ExampleCard(question: 'Find r when i = 30°', steps: ['i = r', 'r = 30°']),
      QuizCard(
        question: 'Angle of reflection at 35°?',
        options: ['55°', '35°'],
        answer: 1,
        why: 'Measured from the normal.',
      ),
      SummaryCard(points: ['i = r']),
    ],
  );

  static const mirrors = Deck(
    id: 'deck-2',
    chapterNumber: 9,
    chapterTitle: 'Light',
    title: 'Spherical mirrors',
    cards: [
      StartCard(goals: ['Know f = R/2'], minutes: 3),
      QuizCard(
        question: 'f = ?',
        options: ['R/2', '2R'],
        answer: 0,
        why: 'Half the radius.',
      ),
      SummaryCard(points: ['f = R/2']),
    ],
  );

  static DeckSummary summaryOf(
    Deck deck, {
    bool isDone = false,
    int resumeCard = 0,
    int kept = 0,
  }) => DeckSummary(
    id: deck.id,
    chapterId: 'cbse-10-science-9',
    subject: 'science',
    subjectName: 'Science',
    chapterNumber: deck.chapterNumber,
    chapterTitle: deck.chapterTitle,
    position: deck.id == reflection.id ? 1 : 2,
    title: deck.title,
    cards: deck.cards.length,
    quizzes: deck.quizzes,
    isDone: isDone,
    correct: 0,
    resumeCard: resumeCard,
    kept: kept,
  );

  final decksById = {reflection.id: reflection, mirrors.id: mirrors};
  List<DeckSummary> deckList = [summaryOf(reflection), summaryOf(mirrors)];
  List<PlannedChapter> chapterList = [];
  List<ChapterResult> results = [];
  List<ReviewItem> reviewItems = [];
  Exception? nextFailure;
  final answers = <(String, int, int)>[];
  final completions = <(String, int)>[];
  final positions = <(String, int)>[];
  final kept = <(String, int)>{};
  final ratings = <(String, int, ReviewRating)>[];
  final chapterScores = <(String, int, int)>[];

  Result<T> _answer<T>(T Function() value) {
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      return Result.error(failure);
    }
    return Result.ok(value());
  }

  @override
  Future<Result<StudyCatalogue>> catalogue() async =>
      _answer(() => (decks: deckList, chapters: chapterList));

  @override
  Future<Result<Deck>> deck(String id) async => _answer(() => decksById[id]!);

  @override
  Future<Result<AnswerResult>> answer(
    String deckId, {
    required int card,
    required int choice,
  }) async => _answer(() {
    answers.add((deckId, card, choice));
    final quiz = decksById[deckId]!.cards[card] as QuizCard;
    final isCorrect = quiz.answer == choice;
    if (!isCorrect) kept.add((deckId, card));
    return (isCorrect: isCorrect, xpAwarded: isCorrect ? 5 : 0);
  });

  @override
  Future<Result<void>> complete(String deckId, {required int correct}) async =>
      _answer(() => completions.add((deckId, correct)));

  @override
  Future<Result<void>> savePosition(String deckId, int card) async =>
      _answer(() => positions.add((deckId, card)));

  @override
  Future<Result<void>> keep(String deckId, int card) async =>
      _answer(() => kept.add((deckId, card)));

  @override
  Future<Result<void>> unkeep(String deckId, int card) async =>
      _answer(() => kept.remove((deckId, card)));

  @override
  Future<Result<List<ReviewItem>>> review({String? chapterId}) async =>
      _answer(() => reviewItems);

  @override
  Future<Result<void>> rate(
    String deckId,
    int card,
    ReviewRating rating,
  ) async => _answer(() => ratings.add((deckId, card, rating)));

  @override
  Future<Result<List<ChapterResult>>> chapterResults() async =>
      _answer(() => results);

  @override
  Future<Result<void>> saveChapterResult(
    String chapterId, {
    required int correct,
    required int total,
  }) async => _answer(() => chapterScores.add((chapterId, correct, total)));
}
