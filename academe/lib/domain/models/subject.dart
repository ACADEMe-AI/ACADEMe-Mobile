class Subject {
  const Subject({required this.id, required this.name});

  static const english = 'english';

  final String id;
  final String name;

  bool get isLocked => id == english;
}
