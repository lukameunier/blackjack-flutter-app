import 'card.dart';
import 'rank.dart';

class Hand {
  final List<Card> _cards = [];

  List<Card> get cards => List.unmodifiable(_cards);

  void addCard(Card card) {
    _cards.add(card);
  }

  void removeCard(Card card) {
    _cards.remove(card);
  }

  void clear() {
    _cards.clear();
  }

  int get score {
    int total = 0;
    int aceCount = 0;

    for (final card in _cards) {
      total += card.rank.value;
      if (card.rank == Rank.ace) {
        aceCount++;
      }
    }

    while (total <= 11 && aceCount > 0) {
      total += 10;
      aceCount--;
    }

    return total;
  }

  bool get isBlackjack => _cards.length == 2 && score == 21;
}
