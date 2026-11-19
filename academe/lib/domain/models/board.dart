enum Board {
  cbse('CBSE', 'Central Board of Secondary Education'),
  icse('ICSE', 'Council for the Indian School Certificate');

  const Board(this.code, this.fullName);

  final String code;
  final String fullName;

  static Board? fromCode(String? code) {
    for (final board in values) {
      if (board.code == code) return board;
    }
    return null;
  }
}
