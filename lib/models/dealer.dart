import 'deck.dart';
import 'player.dart';

class Dealer extends Player {
  /// The dealer plays their turn according to the house rules.
  /// They must hit until their score is 17 or higher.
  void playTurn(Deck deck) {
    while (score < 17) {
      addCard(deck.drawCard());
    }
  }
}
