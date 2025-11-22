import 'deck.dart';
import 'dealer.dart';
import 'player.dart';
import 'hand.dart';
import 'card.dart';

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

  bool get canDoubleDown => !isRoundOver && player.activeHand.cards.length == 2;
  bool get canSplit => canDoubleDown && player.activeHand.cards[0].rank.value == player.activeHand.cards[1].rank.value;

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
    if (player.activeHand.score < 21) {
      player.addCard(deck.drawCard());
      if (player.activeHand.score >= 21) {
        _nextHandOrStand();
      }
    }
  }

  void stand() {
    _nextHandOrStand();
  }

  void doubleDown() {
    if (canDoubleDown) {
      player.addCard(deck.drawCard());
      _nextHandOrStand();
    }
  }

  void split() {
    if (!canSplit) return;

    final handToSplit = player.activeHand;
    final secondCard = handToSplit.cards[1];

    // Remove the second card from the original hand
    handToSplit.removeCard(secondCard);

    // Create the new hand with the second card
    final newHand = Hand();
    newHand.addCard(secondCard);
    player.hands.add(newHand);

    // Deal a new card to each of the split hands
    handToSplit.addCard(deck.drawCard());
    newHand.addCard(deck.drawCard());
  }

  void _nextHandOrStand() {
    if (player.activeHandIndex < player.hands.length - 1) {
      player.activeHandIndex++;
    } else {
      isRoundOver = true;
      if (!player.isBlackjack) {
        dealer.playTurn(deck);
      }
    }
  }

  String getWinner() {
    // This logic will need to be updated to handle multiple hands
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
