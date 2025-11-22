import 'card.dart';
import 'hand.dart';

class Player {
  final List<Hand> hands = [Hand()];
  int activeHandIndex = 0;

  Hand get activeHand => hands[activeHandIndex];

  // For simplicity, these getters will work on the first hand for now.
  // This will need to be updated when we have multiple hands.
  int get score => activeHand.score;
  bool get isBlackjack => activeHand.isBlackjack;
  List<Card> get hand => activeHand.cards; // Keep this for compatibility for now

  void addCard(Card card) {
    activeHand.addCard(card);
  }

  void clearHand() {
    hands.clear();
    hands.add(Hand());
    activeHandIndex = 0;
  }
}
