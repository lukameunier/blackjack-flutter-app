import 'card.dart';
import 'rank.dart';
import 'suit.dart';

class Deck {
  static const int RESHUFFLE_THRESHOLD = 75;

  Deck({bool shuffle = true, int numDecks = 6}) {
    _cards = [];
    for (int i = 0; i < numDecks; i++) {
      for (final suit in Suit.values) {
        for (final rank in Rank.values) {
          _cards.add(Card(rank: rank, suit: suit));
        }
      }
    }
    if (shuffle) {
      this.shuffle();
    }
  }

  late List<Card> _cards;

  List<Card> get cards => List.unmodifiable(_cards);

  bool get needsReshuffle => _cards.length < RESHUFFLE_THRESHOLD;

  void shuffle() {
    _cards.shuffle();
  }

  void burn(int count) {
    if (_cards.length > count) {
      _cards.removeRange(0, count);
    }
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
