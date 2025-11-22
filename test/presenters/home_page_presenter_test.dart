import 'package:blackjack/models/board.dart';
import 'package:blackjack/models/card.dart';
import 'package:blackjack/models/deck.dart';
import 'package:blackjack/models/rank.dart';
import 'package:blackjack/models/suit.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

class MockHomePageView implements HomePageView {
  bool hasBeenRefreshed = false;

  @override
  void refresh() {
    hasBeenRefreshed = true;
  }
}

void main() {
  late HomePagePresenter presenter;
  late MockHomePageView mockView;

  setUp(() {
    mockView = MockHomePageView();
    presenter = HomePagePresenter(mockView, testMode: true);
  });

  test('Initial state is betting', () {
    expect(presenter.board.state, GameState.betting);
  });

  test('placeBetAndDeal() starts the game with a predictable hand and refreshes', () {
    final initialWallet = presenter.board.player.wallet;

    presenter.placeBetAndDeal(10);

    expect(presenter.board.state, GameState.playing);
    expect(presenter.board.player.wallet, initialWallet - 10);
    expect(presenter.board.player.hands.first.bet, 10);
    expect(presenter.board.player.hands.first.cards.length, 2);
    expect(presenter.board.player.hands.first.score, 20); // Unshuffled: King + King
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  group('During gameplay with a predictable hand', () {
    setUp(() {
      presenter.placeBetAndDeal(10);
      mockView.hasBeenRefreshed = false;
    });

    test('hit() adds a card and refreshes', () {
      final initialCardCount = presenter.board.player.activeHand.cards.length;
      presenter.hit();
      expect(presenter.board.player.activeHand.cards.length, initialCardCount + 1);
      expect(mockView.hasBeenRefreshed, isTrue);
    });

    test('stand() ends the round and refreshes', () {
      presenter.stand();
      expect(presenter.board.state, GameState.roundOver);
      expect(mockView.hasBeenRefreshed, isTrue);
    });

    test('doubleDown() adds one card, ends turn, and refreshes', () {
      final initialWallet = presenter.board.player.wallet;
      final initialBet = presenter.board.player.activeHand.bet;

      presenter.doubleDown();

      expect(presenter.board.player.activeHand.cards.length, 3);
      expect(presenter.board.player.wallet, initialWallet - initialBet);
      expect(presenter.board.player.activeHand.bet, initialBet * 2);
      expect(presenter.board.state, GameState.roundOver);
      expect(mockView.hasBeenRefreshed, isTrue);
    });

    test('split() creates a second hand and refreshes', () {
      presenter.placeBetAndDeal(10);
      final initialWallet = presenter.board.player.wallet;

      presenter.split();

      expect(presenter.board.player.hands.length, 2);
      expect(presenter.board.player.hands[0].cards.length, 2);
      expect(presenter.board.player.hands[1].cards.length, 2);
      expect(presenter.board.player.wallet, initialWallet - 10);
      expect(mockView.hasBeenRefreshed, isTrue);
    });
  });

  group('Insurance', () {
    setUp(() {
      final board = presenter.board;
      board.player.clearHands();
      board.dealer.clearHands();
      board.player.wallet = 1000;

      // Manually set up the bet for the hand
      board.player.wallet -= 100;
      board.player.activeHand.bet = 100;

      // Manually rig the deck so dealer gets an Ace
      board.deck = Deck(shuffle: false);
      // To get specific cards, we need to know the unshuffled order.
      // Let's manually deal cards instead.
      board.player.addCard(Card(rank: Rank.ten, suit: Suit.clubs));
      board.dealer.addCard(Card(rank: Rank.ace, suit: Suit.spades)); // Dealer shows Ace
      board.player.addCard(Card(rank: Rank.ten, suit: Suit.hearts));
      board.dealer.addCard(Card(rank: Rank.king, suit: Suit.spades)); // Dealer has blackjack

      board.state = GameState.offeringInsurance;
      mockView.hasBeenRefreshed = false;
    });

    test('takeInsurance() with dealer blackjack results in a net neutral wallet', () {
      final initialWallet = 1000.0;
      presenter.takeInsurance();

      expect(presenter.board.player.insuranceBet, 50);
      // Player loses 100 on main bet, but wins 100 on insurance (50 * 2).
      // Net change is 0. So wallet should be back to 1000.
      expect(presenter.board.player.wallet, initialWallet);
      expect(presenter.board.state, GameState.roundOver);
      expect(mockView.hasBeenRefreshed, isTrue);
    });

    test('declineInsurance() results in a loss of the main bet', () {
      presenter.declineInsurance();

      expect(presenter.board.player.insuranceBet, 0);
      // Player just loses their main bet of 100.
      expect(presenter.board.player.wallet, 1000 - 100);
      expect(presenter.board.state, GameState.roundOver);
      expect(mockView.hasBeenRefreshed, isTrue);
    });
  });

  test('nextRound() resets to betting state and refreshes', () {
    presenter.placeBetAndDeal(10);
    presenter.stand();
    mockView.hasBeenRefreshed = false;

    presenter.nextRound();

    expect(presenter.board.state, GameState.betting);
    expect(presenter.board.player.hands.first.cards, isEmpty);
    expect(mockView.hasBeenRefreshed, isTrue);
  });
}
