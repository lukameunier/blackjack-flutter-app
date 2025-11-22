import 'card.dart';
import 'rank.dart';

class Hand {
  Hand({this.bet = 0});

  final List<Card> _cards = [];
  double bet;
  bool isSurrendered = false;

  List<Card> get cards => List.unmodifiable(_cards);

  void addCard(Card card) {
    _cards.add(card);
  }

  void removeCard(Card card) {
    _cards.remove(card);
  }

  void clear() {
    _cards.clear();
    bet = 0;
    isSurrendered = false;
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

  /// A natural blackjack is a two-card hand totaling 21.
  bool get isNaturalBlackjack => _cards.length == 2 && score == 21;

  /// A hand is splittable if it contains two cards of the same value.
  bool get isSplittable => _cards.length == 2 && _cards[0].rank.value == _cards[1].rank.value;
}
