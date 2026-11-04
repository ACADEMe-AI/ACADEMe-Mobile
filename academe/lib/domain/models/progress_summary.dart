class ProgressSummary {
  const ProgressSummary({
    required this.weekStartsOn,
    required this.daysActiveThisWeek,
    required this.lessonsFinishedThisWeek,
    required this.chapterTestsThisWeek,
    required this.xpThisWeek,
    required this.bySubject,
  });

  factory ProgressSummary.fromJson(Map<String, Object?> json) =>
      ProgressSummary(
        weekStartsOn: json['weekStartsOn'] as String? ?? '',
        daysActiveThisWeek: json['daysActiveThisWeek'] as int? ?? 0,
        lessonsFinishedThisWeek: json['lessonsFinishedThisWeek'] as int? ?? 0,
        chapterTestsThisWeek: json['chapterTestsThisWeek'] as int? ?? 0,
        xpThisWeek: json['xpThisWeek'] as int? ?? 0,
        bySubject: (json['bySubject'] as List<Object?>? ?? const [])
            .map(
              (row) =>
                  ProgressSubjectSummary.fromJson(row! as Map<String, Object?>),
            )
            .toList(),
      );

  final String weekStartsOn;
  final int daysActiveThisWeek;
  final int lessonsFinishedThisWeek;
  final int chapterTestsThisWeek;
  final int xpThisWeek;
  final List<ProgressSubjectSummary> bySubject;

  String get weekLine {
    final parts = <String>[
      if (daysActiveThisWeek > 0) '$daysActiveThisWeek active days',
      if (lessonsFinishedThisWeek > 0) '$lessonsFinishedThisWeek lessons',
      if (chapterTestsThisWeek > 0) '$chapterTestsThisWeek chapter tests',
      if (xpThisWeek > 0) '$xpThisWeek XP',
    ];
    if (parts.isEmpty) return 'No study logged this week yet.';
    return 'This week: ${parts.join(' · ')}.';
  }
}

class ProgressSubjectSummary {
  const ProgressSubjectSummary({
    required this.id,
    required this.name,
    required this.lessonsDone,
  });

  factory ProgressSubjectSummary.fromJson(Map<String, Object?> json) =>
      ProgressSubjectSummary(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        lessonsDone: json['lessonsDone'] as int? ?? 0,
      );

  final String id;
  final String name;
  final int lessonsDone;
}
