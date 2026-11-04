import 'study_chapter.dart';

enum ChapterSort {
  textbook('Textbook'),
  marks('Most marks'),
  recent('Recent');

  const ChapterSort(this.label);

  final String label;
}

enum ChapterFlag {
  boardOnly('Board exam'),
  ready('Ready'),
  revisionDue('Revision due');

  const ChapterFlag(this.label);

  final String label;
}

class ChapterFilters {
  const ChapterFilters({
    this.flags = const {},
    this.sort = ChapterSort.textbook,
  });

  final Set<ChapterFlag> flags;
  final ChapterSort sort;

  int get count => flags.length + (sort == ChapterSort.textbook ? 0 : 1);
  bool get isEmpty => count == 0;
  bool has(ChapterFlag flag) => flags.contains(flag);

  ChapterFilters toggle(ChapterFlag flag) => ChapterFilters(
    flags: has(flag) ? ({...flags}..remove(flag)) : {...flags, flag},
    sort: sort,
  );

  ChapterFilters sortBy(ChapterSort next) =>
      ChapterFilters(flags: flags, sort: next);

  List<StudyChapter> apply(Iterable<StudyChapter> chapters) {
    final kept = [
      for (final c in chapters)
        if ((!has(ChapterFlag.boardOnly) || !c.isFormativeOnly) &&
            (!has(ChapterFlag.ready) || !c.isComingSoon) &&
            (!has(ChapterFlag.revisionDue) || c.revisionDue > 0))
          c,
    ];
    return switch (sort) {
      ChapterSort.textbook => kept,
      ChapterSort.marks => _sorted(kept, (c) => -c.marks),
      ChapterSort.recent => _sorted(
        kept,
        (c) => -(c.lastStudiedAt?.millisecondsSinceEpoch ?? 0),
      ),
    };
  }

  static List<StudyChapter> _sorted(
    List<StudyChapter> chapters,
    int Function(StudyChapter) key,
  ) {
    final indexed = chapters.indexed.toList()
      ..sort((a, b) {
        final byKey = key(a.$2).compareTo(key(b.$2));
        return byKey != 0 ? byKey : a.$1.compareTo(b.$1);
      });
    return [for (final (_, c) in indexed) c];
  }
}
