import 'dealer.dart';
import 'deck.dart';
import 'hand.dart';
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

  bool get canDoubleDown => !isRoundOver && player.activeHand.cards.length == 2;

  bool get canSplit =>
      canDoubleDown &&
      player.activeHand.cards[0].rank.value ==
          player.activeHand.cards[1].rank.value;

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

    handToSplit.removeCard(secondCard);

    final newHand = Hand();
    newHand.addCard(secondCard);
    player.hands.add(newHand);

    handToSplit.addCard(deck.drawCard());
    newHand.addCard(deck.drawCard());
  }

  void _nextHandOrStand() {
    if (player.activeHandIndex < player.hands.length - 1) {
      player.activeHandIndex++;
    } else {
      isRoundOver = true;
      // Dealer only plays if at least one player hand is not a bust/blackjack
      if (player.hands.any((hand) => hand.score <= 21 && !hand.isBlackjack)) {
        dealer.playTurn(deck);
      }
    }
  }

  List<String> getWinner() {
    if (!isRoundOver) return [];

    List<String> results = [];
    int handNum = 1;

    for (final hand in player.hands) {
      String prefix = player.hands.length > 1 ? "Hand $handNum: " : "";

      if (hand.isBlackjack && !dealer.isBlackjack) {
        results.add("${prefix}Blackjack! You Win!");
      } else if (hand.isBlackjack && dealer.isBlackjack) {
        results.add("${prefix}Push (Both have Blackjack)");
      } else if (!hand.isBlackjack && dealer.isBlackjack) {
        results.add("${prefix}Dealer has Blackjack! You Lose");
      } else if (hand.score > 21) {
        results.add("${prefix}Bust! Dealer Wins");
      } else if (dealer.score > 21) {
        results.add("${prefix}Dealer Busts! You Win!");
      } else if (hand.score > dealer.score) {
        results.add("${prefix}You Win!");
      } else if (dealer.score > hand.score) {
        results.add("${prefix}Dealer Wins");
      } else {
        results.add("${prefix}Push (Tie)");
      }
      handNum++;
    }
    return results;
  }
}
