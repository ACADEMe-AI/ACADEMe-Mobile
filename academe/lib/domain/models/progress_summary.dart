class ProgressSummary {
  const ProgressSummary({
    required this.weekStartsOn,
    required this.daysActiveThisWeek,
    required this.lessonsFinishedThisWeek,
    required this.chapterTestsThisWeek,
    required this.xpThisWeek,
    required this.bySubject,
    this.activeDays = const [false, false, false, false, false, false, false],
    this.overallGrade,
  });

  factory ProgressSummary.fromJson(Map<String, Object?> json) {
    final days = (json['activeDays'] as List<Object?>? ?? const [])
        .map((day) => day == true)
        .toList();
    while (days.length < 7) {
      days.add(false);
    }
    return ProgressSummary(
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
      activeDays: days.take(7).toList(),
      overallGrade: (json['overallGrade'] as num?)?.toDouble(),
    );
  }

  static const empty = ProgressSummary(
    weekStartsOn: '',
    daysActiveThisWeek: 0,
    lessonsFinishedThisWeek: 0,
    chapterTestsThisWeek: 0,
    xpThisWeek: 0,
    bySubject: [],
  );

  final String weekStartsOn;
  final int daysActiveThisWeek;
  final int lessonsFinishedThisWeek;
  final int chapterTestsThisWeek;
  final int xpThisWeek;
  final List<ProgressSubjectSummary> bySubject;
  final List<bool> activeDays;
  final double? overallGrade;

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

  String get gradeLabel {
    final grade = overallGrade;
    if (grade == null) return '0.00';
    return grade.toStringAsFixed(2);
  }

  double get gradeFraction {
    final grade = overallGrade;
    if (grade == null || grade <= 0) return 0;
    return (grade / 100).clamp(0.0, 1.0);
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
