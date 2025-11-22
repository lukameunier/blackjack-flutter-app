import 'dealer.dart';
import 'deck.dart';
import 'hand.dart';
import 'player.dart';
import 'rank.dart';

enum GameState { betting, playing, offeringInsurance, roundOver }

class GameResult {
  final String message;
  final double payout;

  GameResult(this.message, this.payout);
}

class Board {
  Board({this.testMode = false}) {
    players.add(Player());
    deck = Deck(shuffle: !testMode);
    deck.burn(5);
  }

  late Deck deck;
  final Dealer dealer = Dealer();
  final List<Player> players = [];
  GameState state = GameState.betting;
  final bool testMode;

  Player get player => players.first;

  bool get canDoubleDown =>
      state == GameState.playing &&
      player.activeHand.cards.length == 2 &&
      player.wallet >= player.activeHand.bet;

  bool get canSplit =>
      canDoubleDown &&
      player.activeHand.isSplittable &&
      player.wallet >= player.activeHand.bet;

  bool get canTakeInsurance =>
      state == GameState.offeringInsurance &&
      player.wallet >= player.hands.first.bet / 2;

  void placeBetAndDeal(double amount) {
    if (state != GameState.betting || player.wallet < amount) return;

    if (deck.cards.length < 52) {
      deck = Deck(shuffle: !testMode);
      deck.burn(5);
    }

    player.clearHands();
    dealer.clearHands();

    player.wallet -= amount;
    player.activeHand.bet = amount;

    state = GameState.playing;

    player.addCard(deck.drawCard());
    dealer.addCard(deck.drawCard());
    player.addCard(deck.drawCard());
    dealer.addCard(deck.drawCard());

    if (dealer.activeHand.cards.first.rank == Rank.ace) {
      state = GameState.offeringInsurance;
    } else if (player.isBlackjack || dealer.isBlackjack) {
      _endRound();
    }
  }

  void takeInsurance() {
    if (!canTakeInsurance) return;
    final insuranceAmount = player.hands.first.bet / 2;
    player.wallet -= insuranceAmount;
    player.insuranceBet = insuranceAmount;
    _resumePlay();
  }

  void declineInsurance() {
    if (state != GameState.offeringInsurance) return;
    _resumePlay();
  }

  void _resumePlay() {
    if (player.isBlackjack || dealer.isBlackjack) {
      _endRound();
    } else {
      state = GameState.playing;
    }
  }

  void hit() {
    if (state != GameState.playing) return;

    if (player.activeHand.score < 21) {
      player.addCard(deck.drawCard());
      if (player.activeHand.score >= 21) {
        _nextHandOrStand();
      }
    }
  }

  void stand() {
    if (state != GameState.playing) return;
    _nextHandOrStand();
  }

  void doubleDown() {
    if (!canDoubleDown) return;

    final hand = player.activeHand;
    player.wallet -= hand.bet;
    hand.bet *= 2;
    player.addCard(deck.drawCard());
    _nextHandOrStand();
  }

  void split() {
    if (!canSplit) return;

    final handToSplit = player.activeHand;
    final bet = handToSplit.bet;
    player.wallet -= bet;

    final secondCard = handToSplit.cards[1];
    handToSplit.removeCard(secondCard);

    final newHand = Hand(bet: bet);
    newHand.addCard(secondCard);
    player.hands.add(newHand);

    handToSplit.addCard(deck.drawCard());
    newHand.addCard(deck.drawCard());

    if (handToSplit.cards[0].rank == Rank.ace) {
      stand();
      stand();
    }
  }

  void _nextHandOrStand() {
    if (player.activeHandIndex < player.hands.length - 1) {
      player.activeHandIndex++;
    } else {
      _endRound();
    }
  }

  void _endRound() {
    state = GameState.roundOver;
    if (player.hands.any((hand) => hand.score <= 21)) {
      dealer.playTurn(deck);
    }
    _calculatePayouts();
  }

  void _calculatePayouts() {
    if (player.insuranceBet > 0) {
      if (dealer.isBlackjack) {
        player.wallet += player.insuranceBet * 3;
      }
    }

    for (final hand in player.hands) {
      final result = getResultForHand(hand);
      player.wallet += result.payout;
    }
  }

  GameResult getResultForHand(Hand hand) {
    if (hand.isNaturalBlackjack && !dealer.isBlackjack) {
      return GameResult('Blackjack! You Win!', hand.bet * 2.5);
    } else if (hand.isNaturalBlackjack && dealer.isBlackjack) {
      return GameResult('Push (Both have Blackjack)', hand.bet);
    } else if (!hand.isNaturalBlackjack && dealer.isBlackjack) {
      return GameResult('Dealer has Blackjack! You Lose', 0);
    } else if (hand.score > 21) {
      return GameResult('Bust! Dealer Wins', 0);
    } else if (dealer.score > 21) {
      return GameResult('Dealer Busts! You Win!', hand.bet * 2);
    } else if (hand.score > dealer.score) {
      return GameResult('You Win!', hand.bet * 2);
    } else if (dealer.score > hand.score) {
      return GameResult('Dealer Wins', 0);
    } else {
      return GameResult('Push (Tie)', hand.bet);
    }
  }

  void nextRound() {
    state = GameState.betting;
    player.clearHands();
    dealer.clearHands();
  }
}
