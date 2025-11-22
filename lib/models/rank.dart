enum Rank {
  ace(1),
  two(2),
  three(3),
  four(4),
  five(5),
  six(6),
  seven(7),
  eight(8),
  nine(9),
  ten(10),
  jack(10),
  queen(10),
  king(10);

  const Rank(this.value);
  final int value;
}

extension RankExtension on Rank {
  String get displayName {
    String n = name;
    return n[0].toUpperCase() + n.substring(1);
  }

  int get displayValue {
    return value;
  }
}