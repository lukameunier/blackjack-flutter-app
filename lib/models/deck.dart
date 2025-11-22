import 'card.dart';
import 'rank.dart';
import 'suit.dart';

class Deck {
  Deck() {
    _cards = [];
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        _cards.add(Card(rank: rank, suit: suit));
      }
    }
    shuffle();
  }

  late List<Card> _cards;

  List<Card> get cards => List.unmodifiable(_cards);

  void shuffle() {
    _cards.shuffle();
  }

  Card drawCard() {
    if (_cards.isEmpty) {
      throw StateError('Cannot draw from an empty deck.');
    }
    return _cards.removeLast();
  }

  @override
  String toString() {
    return _cards.toString();
  }
}
