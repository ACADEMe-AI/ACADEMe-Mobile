class DeckSummary {
  const DeckSummary({
    required this.id,
    required this.chapterId,
    required this.subject,
    required this.subjectName,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.position,
    required this.title,
    required this.cards,
    required this.quizzes,
    required this.isDone,
    required this.correct,
    this.resumeCard = 0,
    this.kept = 0,
  });

  final String id;
  final String chapterId;
  final String subject;
  final String subjectName;
  final int chapterNumber;
  final String chapterTitle;
  final int position;
  final String title;
  final int cards;
  final int quizzes;
  final bool isDone;
  final int correct;
  final int resumeCard;
  final int kept;

  bool get isStarted => isDone || resumeCard > 0;
}

sealed class DeckCard {
  const DeckCard();
}

class StartCard extends DeckCard {
  const StartCard({required this.goals, required this.minutes});

  final List<String> goals;
  final int minutes;
}

class ConceptCard extends DeckCard {
  const ConceptCard({required this.title, required this.body, this.remember});

  final String title;
  final String body;
  final String? remember;
}

class TableCard extends DeckCard {
  const TableCard({required this.title, required this.rows, this.remember});

  final String title;
  final List<(String, String)> rows;
  final String? remember;
}

class ExampleCard extends DeckCard {
  const ExampleCard({required this.question, required this.steps});

  final String question;
  final List<String> steps;
}

class QuizCard extends DeckCard {
  const QuizCard({
    required this.question,
    required this.options,
    required this.answer,
    required this.why,
  });

  final String question;
  final List<String> options;
  final int answer;
  final String why;

  static const xp = 5;
}

class SummaryCard extends DeckCard {
  const SummaryCard({required this.points});

  final List<String> points;
}

class Deck {
  const Deck({
    required this.id,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.title,
    required this.cards,
    this.kept = const {},
    this.resumeCard = 0,
  });

  final String id;
  final int chapterNumber;
  final String chapterTitle;
  final String title;
  final List<DeckCard> cards;
  final Set<int> kept;
  final int resumeCard;

  int get quizzes => cards.whereType<QuizCard>().length;
}

typedef AnswerResult = ({bool isCorrect, int xpAwarded});

class ReviewItem {
  const ReviewItem({
    required this.deckId,
    required this.card,
    required this.isMissed,
    required this.lessonTitle,
    required this.chapterTitle,
    required this.content,
  });

  final String deckId;
  final int card;
  final bool isMissed;
  final String lessonTitle;
  final String chapterTitle;
  final DeckCard content;
}

enum ReviewRating {
  again('again', 'Didn’t know'),
  almost('almost', 'Almost'),
  knew('knew', 'Knew it');

  const ReviewRating(this.code, this.label);

  final String code;
  final String label;
}

class ChapterResult {
  const ChapterResult({
    required this.chapterId,
    required this.correct,
    required this.total,
  });

  final String chapterId;
  final int correct;
  final int total;

  int get percent => total == 0 ? 0 : correct * 100 ~/ total;
}

class PlannedLesson {
  const PlannedLesson({
    required this.id,
    required this.position,
    required this.title,
    required this.isAvailable,
  });

  final String id;
  final int position;
  final String title;
  final bool isAvailable;
}

class PlannedChapter {
  const PlannedChapter({
    required this.id,
    required this.subject,
    required this.subjectName,
    required this.number,
    required this.title,
    this.unit = '',
    this.lessons = const [],
  });

  final String id;
  final String subject;
  final String subjectName;
  final int number;
  final String title;
  final String unit;
  final List<PlannedLesson> lessons;
}

typedef StudyCatalogue = ({
  List<DeckSummary> decks,
  List<PlannedChapter> chapters,
});
