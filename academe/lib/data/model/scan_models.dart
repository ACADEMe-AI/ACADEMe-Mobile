import '../../domain/models/scan.dart';

Marking markingFromJson(Map<String, Object?> json) => Marking(
  question: json['question'] as String? ?? '',
  marks: json['marks']! as int,
  awarded: json['awarded']! as int,
  points: [
    for (final p in json['points']! as List<Object?>)
      MarkPoint(
        text: (p! as Map<String, Object?>)['text']! as String,
        marks: (p as Map<String, Object?>)['marks']! as int,
        awarded: p['awarded']! as int,
      ),
  ],
  fullMarks: json['fullMarks']! as String,
  modelAnswer: json['modelAnswer'] as String? ?? '',
);

Scan scanFromJson(Map<String, Object?> json) => Scan(
  id: json['id']! as String,
  mode: ScanMode.fromCode(json['mode']! as String),
  title: json['title']! as String,
  text: json['text']! as String,
  chapter: json['chapter'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt']! as String),
  threadId: json['threadId'] as String?,
  folderId: json['folderId'] as String?,
  deckId: json['deckId'] as String?,
  result: switch (json['result']) {
    final Map<String, Object?> result => markingFromJson(result),
    _ => null,
  },
);
