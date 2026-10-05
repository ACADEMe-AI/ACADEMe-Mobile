class Level {
  const Level._(this.number, this.startXp, this.nextXp);

  factory Level.of(int xp) {
    var start = 0;
    var step = 100;
    var number = 1;
    while (xp >= start + step) {
      start += step;
      number++;
      step += 50;
    }
    return Level._(number, start, start + step);
  }

  final int number;
  final int startXp;
  final int nextXp;

  int toNext(int xp) => nextXp - xp;

  double progress(int xp) => (xp - startXp) / (nextXp - startXp);
}
