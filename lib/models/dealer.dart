import 'deck.dart';
import 'player.dart';

class Dealer extends Player {
  void playTurn(Deck deck) {
    while (score < 17) {
      addCard(deck.drawCard());
    }
  }
}
