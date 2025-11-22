import 'rank.dart';
import 'suit.dart';

class Card {
  Card({required this.rank, required this.suit});

  final Rank rank;
  final Suit suit;

  get value {
    return rank.value;
  }

  @override
  String toString() {
    return '$rank$suit';
  }
}
