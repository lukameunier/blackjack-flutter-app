import 'deck.dart';
import 'dealer.dart';
import 'player.dart';

class Board {
  Board() {
    players.add(Player()); // Add one player for now
    newGame();
  }

  late Deck deck;
  late Dealer dealer;
  final List<Player> players = [];
  bool isRoundOver = false;

  // For now, we assume a single player
  Player get player => players.first;

  bool get canDoubleDown => !isRoundOver && player.hand.length == 2;

  void newGame() {
    deck = Deck();
    dealer = Dealer();
    for (var p in players) {
      p.clearHand();
    }
    dealer.clearHand();

    isRoundOver = false;

    // Deal initial cards
    player.addCard(deck.drawCard());
    dealer.addCard(deck.drawCard());
    player.addCard(deck.drawCard());
    dealer.addCard(deck.drawCard());

    if (player.isBlackjack || dealer.isBlackjack) {
      isRoundOver = true;
    }
  }

  void hit() {
    if (player.score < 21) {
      player.addCard(deck.drawCard());
      if (player.score >= 21) {
        stand(); // Automatically stand if player busts or hits 21
      }
    }
  }

  void stand() {
    isRoundOver = true;
    if (!player.isBlackjack) {
      dealer.playTurn(deck);
    }
  }

  void doubleDown() {
    if (canDoubleDown) {
      player.addCard(deck.drawCard());
      stand(); // Turn ends immediately after one card
    }
  }

  String getWinner() {
    if (player.isBlackjack && dealer.isBlackjack) return 'Push (Both have Blackjack)';
    if (player.isBlackjack) return 'Blackjack! You Win!';
    if (dealer.isBlackjack) return 'Dealer has Blackjack! You Lose';

    if (player.score > 21) return 'You Bust! Dealer Wins';
    if (dealer.score > 21) return 'Dealer Busts! You Win!';
    if (isRoundOver) {
      if (player.score > dealer.score) return 'You Win!';
      if (dealer.score > player.score) return 'Dealer Wins';
      return 'Push (Tie)';
    }
    return ''; // Game is still in progress
  }
}
