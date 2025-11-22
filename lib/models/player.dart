import 'card.dart';
import 'hand.dart';

class Player {
  Player({this.wallet = 1000.0});

  double wallet;
  // A player always starts with at least one hand.
  final List<Hand> hands = [Hand()];
  int activeHandIndex = 0;

  Hand get activeHand => hands[activeHandIndex];

  int get score => activeHand.score;
  bool get isBlackjack => hands.isNotEmpty && hands.first.isNaturalBlackjack;

  void addCard(Card card) {
    activeHand.addCard(card);
  }

  void clearHands() {
    hands.clear();
    hands.add(Hand()); // Always ensure there is one hand after clearing.
    activeHandIndex = 0;
  }
}
