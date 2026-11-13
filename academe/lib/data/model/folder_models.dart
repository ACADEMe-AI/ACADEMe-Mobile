import '../../domain/models/folder.dart';

DateTime? _day(Object? value) =>
    value == null ? null : DateTime.parse(value as String);

String dayString(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

FolderSummary folderSummaryFromJson(Map<String, Object?> json) => FolderSummary(
  id: json['id']! as String,
  name: json['name']! as String,
  dueOn: _day(json['dueOn']),
  reminds: json['reminds'] as bool? ?? true,
  items: json['items'] as int? ?? 0,
  todayLeft: json['todayLeft'] as int? ?? 0,
  progress: json['progress'] as int? ?? 0,
);

StudyTask studyTaskFromJson(Map<String, Object?> json) => StudyTask(
  kind: switch (json['kind']) {
    'lesson' => TaskKind.lesson,
    'test' => TaskKind.test,
    'review' => TaskKind.review,
    _ => TaskKind.todo,
  },
  title: json['title']! as String,
  subtitle: json['subtitle'] as String? ?? '',
  minutes: json['minutes'] as int? ?? 0,
  isDone: json['done'] as bool? ?? false,
  deckId: json['deckId'] as String?,
  chapterId: json['chapterId'] as String?,
  todoId: json['todoId'] as int?,
  folderId: json['folderId'] as String?,
  folderName: json['folderName'] as String?,
);

List<StudyTask> _tasks(Object? list) => [
  for (final t in (list as List<Object?>?) ?? const [])
    studyTaskFromJson(t! as Map<String, Object?>),
];

FolderDetail folderDetailFromJson(Map<String, Object?> json) => FolderDetail(
  summary: folderSummaryFromJson(json),
  chapters: [
    for (final c in json['chapters']! as List<Object?>)
      FolderChapter(
        itemId: (c! as Map<String, Object?>)['itemId']! as int,
        chapterId: (c as Map<String, Object?>)['chapterId']! as String,
        subject: c['subject']! as String,
        number: c['number']! as int,
        title: c['title']! as String,
        lessons: c['lessons']! as int,
        lessonsDone: c['lessonsDone']! as int,
      ),
  ],
  notes: [
    for (final n in json['notes']! as List<Object?>)
      FolderNote(
        itemId: (n! as Map<String, Object?>)['itemId']! as int,
        text: (n as Map<String, Object?>)['text']! as String,
      ),
  ],
  lessons: [
    for (final l in json['lessons'] as List<Object?>? ?? const [])
      FolderLesson(
        itemId: (l! as Map<String, Object?>)['itemId']! as int,
        deckId: (l as Map<String, Object?>)['deckId']! as String,
        title: l['title']! as String,
        minutes: l['minutes']! as int,
        isDone: l['done']! as bool,
      ),
  ],
  today: _tasks(json['today']),
  plan: [
    for (final d in json['plan']! as List<Object?>)
      PlanDay(
        day: DateTime.parse((d! as Map<String, Object?>)['day']! as String),
        tasks: _tasks((d as Map<String, Object?>)['tasks']),
      ),
  ],
);

TodayPlan todayPlanFromJson(Map<String, Object?> json) => TodayPlan(
  tasks: _tasks(json['tasks']),
  reviewDue: json['reviewDue'] as int? ?? 0,
);
