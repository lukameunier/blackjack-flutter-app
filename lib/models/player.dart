import 'card.dart';
import 'hand.dart';

class Player {
  final List<Hand> hands = [Hand()];
  int activeHandIndex = 0;

  Hand get activeHand => hands[activeHandIndex];

  int get score => activeHand.score;
  bool get isBlackjack => hands.first.isNaturalBlackjack;

  void addCard(Card card) {
    activeHand.addCard(card);
  }

  void clearHand() {
    hands.clear();
    hands.add(Hand());
    activeHandIndex = 0;
  }
}
