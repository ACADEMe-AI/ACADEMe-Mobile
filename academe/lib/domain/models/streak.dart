class Streak {
  const Streak({
    this.current = 0,
    this.longest = 0,
    this.isTodayCounted = false,
  });

  final int current;
  final int longest;
  final bool isTodayCounted;
}
