enum Rank {
  ace(1, 'A'),
  two(2, '2'),
  three(3, '3'),
  four(4, '4'),
  five(5, '5'),
  six(6, '6'),
  seven(7, '7'),
  eight(8, '8'),
  nine(9, '9'),
  ten(10, '10'),
  jack(10, 'J'),
  queen(10, 'Q'),
  king(10, 'K');

  const Rank(this.value, this.shortName);
  final int value;
  final String shortName;
}
