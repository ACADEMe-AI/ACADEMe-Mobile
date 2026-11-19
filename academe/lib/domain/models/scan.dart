enum ScanMode {
  solve('solve', 'Solve homework'),
  check('check', 'Check my answer'),
  notes('notes', 'Notes to a folder'),
  ask('ask', 'Ask about a photo');

  const ScanMode(this.code, this.label);

  final String code;
  final String label;

  static ScanMode fromCode(String code) =>
      values.firstWhere((mode) => mode.code == code, orElse: () => ask);
}

class MarkPoint {
  const MarkPoint({
    required this.text,
    required this.marks,
    required this.awarded,
  });

  final String text;
  final int marks;
  final int awarded;

  bool get isFull => awarded == marks;
}

class Marking {
  const Marking({
    required this.question,
    required this.marks,
    required this.awarded,
    required this.points,
    required this.fullMarks,
    required this.modelAnswer,
  });

  final String question;
  final int marks;
  final int awarded;
  final List<MarkPoint> points;
  final String fullMarks;
  final String modelAnswer;

  bool get isFull => awarded == marks;
}

class Scan {
  const Scan({
    required this.id,
    required this.mode,
    required this.title,
    required this.text,
    required this.chapter,
    required this.createdAt,
    this.threadId,
    this.folderId,
    this.deckId,
    this.result,
  });

  final String id;
  final ScanMode mode;
  final String title;
  final String text;
  final String chapter;
  final DateTime createdAt;
  final String? threadId;
  final String? folderId;
  final String? deckId;
  final Marking? result;
}

enum ScanFailure {
  unavailable,
  noText,
  tooLarge,
  network,
  scanLimit,
  checkLimit,
  proOnly,
  unknown,
}

class ScanException implements Exception {
  const ScanException(this.failure);

  final ScanFailure failure;
}
