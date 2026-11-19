import 'subject.dart';

class StudyStream {
  const StudyStream({
    required this.id,
    required this.name,
    required this.main,
    required this.optional,
  });

  final String id;
  final String name;
  final List<Subject> main;
  final List<Subject> optional;

  String get summary => [
    for (final s in main)
      if (!s.isLocked) s.name,
  ].join(', ');

  bool isMain(String subject) => main.any((s) => s.id == subject);

  bool fits(Iterable<String> picks) =>
      main.every((s) => s.isLocked || picks.contains(s.id));
}
