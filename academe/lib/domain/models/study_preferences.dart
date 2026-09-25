class StudyPreferences {
  const StudyPreferences({
    this.remindsToStudy = false,
    this.reminderHour = 21,
    this.reminderMinute = 0,
    this.reminderDays = const {1, 2, 3, 4, 5, 6},
    this.savesStreak = true,
    this.warnsBeforeTests = true,
    this.celebratesLevelUps = false,
    this.dailyGoalMinutes = 25,
  });

  final bool remindsToStudy;
  final int reminderHour;
  final int reminderMinute;
  final Set<int> reminderDays;
  final bool savesStreak;
  final bool warnsBeforeTests;
  final bool celebratesLevelUps;
  final int dailyGoalMinutes;

  static const dailyGoalChoices = [10, 15, 20, 25, 30, 45, 60];

  String get reminderLabel {
    final hour = reminderHour % 12 == 0 ? 12 : reminderHour % 12;
    final minute = reminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute ${reminderHour < 12 ? 'am' : 'pm'}';
  }

  StudyPreferences copyWith({
    bool? remindsToStudy,
    int? reminderHour,
    int? reminderMinute,
    Set<int>? reminderDays,
    bool? savesStreak,
    bool? warnsBeforeTests,
    bool? celebratesLevelUps,
    int? dailyGoalMinutes,
  }) => StudyPreferences(
    remindsToStudy: remindsToStudy ?? this.remindsToStudy,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    reminderDays: reminderDays ?? this.reminderDays,
    savesStreak: savesStreak ?? this.savesStreak,
    warnsBeforeTests: warnsBeforeTests ?? this.warnsBeforeTests,
    celebratesLevelUps: celebratesLevelUps ?? this.celebratesLevelUps,
    dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
  );
}
