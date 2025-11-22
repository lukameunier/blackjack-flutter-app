import 'card.dart';
import 'rank.dart';

class Player {
  final List<Card> _hand = [];

  List<Card> get hand => List.unmodifiable(_hand);

  void addCard(Card card) {
    _hand.add(card);
  }

  void clearHand() {
    _hand.clear();
  }

  int get score {
    int total = 0;
    int aceCount = 0;

    for (final card in _hand) {
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

  bool get isBlackjack => _hand.length == 2 && score == 21;
}
