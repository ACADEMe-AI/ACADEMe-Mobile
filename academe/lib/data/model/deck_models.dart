import '../../domain/models/deck.dart';

List<String> _strings(Object? list) => [
  for (final o in (list as List<Object?>?) ?? const []) o! as String,
];

DeckSummary deckSummaryFromJson(Map<String, Object?> json) => DeckSummary(
  id: json['id']! as String,
  chapterId: json['chapterId'] as String? ?? '',
  subject: json['subject']! as String,
  subjectName: json['subjectName'] as String? ?? json['subject']! as String,
  chapterNumber: json['chapterNumber']! as int,
  chapterTitle: json['chapterTitle']! as String,
  position: json['position']! as int,
  title: json['title']! as String,
  cards: json['cards']! as int,
  quizzes: json['quizzes']! as int,
  isDone: json['done']! as bool,
  correct: json['correct']! as int,
  resumeCard: json['resumeCard'] as int? ?? 0,
  kept: json['kept'] as int? ?? 0,
);

DeckCard deckCardFromJson(Map<String, Object?> json) => switch (json['kind']) {
  'start' => StartCard(
    goals: _strings(json['goals']),
    minutes: json['minutes'] as int? ?? 0,
  ),
  'table' => TableCard(
    title: json['title'] as String? ?? '',
    rows: [
      for (final r in (json['rows'] as List<Object?>?) ?? const [])
        (
          (r! as Map<String, Object?>)['term']! as String,
          (r as Map<String, Object?>)['value']! as String,
        ),
    ],
    remember: json['remember'] as String?,
  ),
  'example' => ExampleCard(
    question: json['question']! as String,
    steps: _strings(json['steps']),
  ),
  'quiz' => QuizCard(
    question: json['question']! as String,
    options: _strings(json['options']),
    answer: json['answer']! as int,
    why: json['why']! as String,
  ),
  'summary' => SummaryCard(points: _strings(json['points'])),
  _ => ConceptCard(
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    remember: json['remember'] as String?,
  ),
};

Deck deckFromJson(Map<String, Object?> json) => Deck(
  id: json['id']! as String,
  chapterNumber: json['chapterNumber']! as int,
  chapterTitle: json['chapterTitle']! as String,
  title: json['title']! as String,
  cards: [
    for (final c in json['cards']! as List<Object?>)
      deckCardFromJson(c! as Map<String, Object?>),
  ],
  kept: {
    for (final k in (json['kept'] as List<Object?>?) ?? const []) k! as int,
  },
  resumeCard: json['resumeCard'] as int? ?? 0,
);

ReviewItem reviewItemFromJson(Map<String, Object?> json) => ReviewItem(
  deckId: json['deckId']! as String,
  card: json['card']! as int,
  isMissed: json['reason'] == 'missed',
  lessonTitle: json['lessonTitle']! as String,
  chapterTitle: json['chapterTitle']! as String,
  content: deckCardFromJson(json['content']! as Map<String, Object?>),
);

ChapterResult chapterResultFromJson(Map<String, Object?> json) => ChapterResult(
  chapterId: json['chapterId']! as String,
  correct: json['correct']! as int,
  total: json['total']! as int,
);

PlannedChapter plannedChapterFromJson(Map<String, Object?> json) =>
    PlannedChapter(
      id: json['id']! as String,
      subject: json['subject']! as String,
      subjectName: json['subjectName'] as String? ?? json['subject']! as String,
      number: json['number']! as int,
      title: json['title']! as String,
      unit: json['unit'] as String? ?? '',
      isFormativeOnly: json['formativeOnly'] as bool? ?? false,
      lessons: [
        for (final l in (json['lessons'] as List<Object?>?) ?? const [])
          PlannedLesson(
            id: (l! as Map<String, Object?>)['id']! as String,
            position: (l as Map<String, Object?>)['position']! as int,
            title: l['title']! as String,
            isAvailable: l['available'] as bool? ?? false,
          ),
      ],
    );

StudyCatalogue studyCatalogueFromJson(Map<String, Object?> json) => (
  decks: [
    for (final item in json['decks']! as List<Object?>)
      deckSummaryFromJson(item! as Map<String, Object?>),
  ],
  chapters: [
    for (final item in (json['chapters'] as List<Object?>?) ?? const [])
      plannedChapterFromJson(item! as Map<String, Object?>),
  ],
);
