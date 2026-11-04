class FolderSummary {
  const FolderSummary({
    required this.id,
    required this.name,
    required this.dueOn,
    required this.reminds,
    required this.items,
    required this.todayLeft,
    required this.progress,
  });

  final String id;
  final String name;
  final DateTime? dueOn;
  final bool reminds;
  final int items;
  final int todayLeft;
  final int progress;
}

class FolderChapter {
  const FolderChapter({
    required this.itemId,
    required this.chapterId,
    required this.subject,
    required this.number,
    required this.title,
    required this.lessons,
    required this.lessonsDone,
  });

  final int itemId;
  final String chapterId;
  final String subject;
  final int number;
  final String title;
  final int lessons;
  final int lessonsDone;
}

class FolderNote {
  const FolderNote({required this.itemId, required this.text});

  final int itemId;
  final String text;
}

class FolderLesson {
  const FolderLesson({
    required this.itemId,
    required this.deckId,
    required this.title,
    required this.minutes,
    required this.isDone,
  });

  final int itemId;
  final String deckId;
  final String title;
  final int minutes;
  final bool isDone;
}

enum TaskKind { lesson, test, review, todo }

class StudyTask {
  const StudyTask({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.isDone,
    this.deckId,
    this.chapterId,
    this.todoId,
    this.folderId,
    this.folderName,
  });

  final TaskKind kind;
  final String title;
  final String subtitle;
  final int minutes;
  final bool isDone;
  final String? deckId;
  final String? chapterId;
  final int? todoId;
  final String? folderId;
  final String? folderName;
}

class PlanDay {
  const PlanDay({required this.day, required this.tasks});

  final DateTime day;
  final List<StudyTask> tasks;
}

class FolderDetail {
  const FolderDetail({
    required this.summary,
    required this.chapters,
    required this.notes,
    this.lessons = const [],
    required this.today,
    required this.plan,
  });

  final FolderSummary summary;
  final List<FolderChapter> chapters;
  final List<FolderNote> notes;
  final List<FolderLesson> lessons;
  final List<StudyTask> today;
  final List<PlanDay> plan;

  bool get isEmpty =>
      chapters.isEmpty && notes.isEmpty && lessons.isEmpty && today.isEmpty;
}

class TodayPlan {
  const TodayPlan({required this.tasks, required this.reviewDue});

  final List<StudyTask> tasks;
  final int reviewDue;

  static const empty = TodayPlan(tasks: [], reviewDue: 0);

  int get minutesLeft =>
      tasks.where((t) => !t.isDone).fold(0, (sum, t) => sum + t.minutes);
}
