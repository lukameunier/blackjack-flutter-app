import 'package:blackjack/models/board.dart';
import 'package:blackjack/models/card.dart';
import 'package:blackjack/models/rank.dart';
import 'package:blackjack/models/suit.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:blackjack/services/wallet_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_page_presenter_test.mocks.dart';

class MockHomePageView implements HomePageView {
  bool hasBeenRefreshed = false;
  bool reshuffleMessageWasShown = false;

  @override
  void refresh() {
    hasBeenRefreshed = true;
  }

  @override
  void showReshuffleMessage() {
    reshuffleMessageWasShown = true;
  }
}

@GenerateMocks([WalletService])
void main() {
  late HomePagePresenter presenter;
  late MockHomePageView mockView;
  late MockWalletService mockWalletService;

  setUp(() {
    mockView = MockHomePageView();
    mockWalletService = MockWalletService();
    presenter = HomePagePresenter(
      mockView,
      walletService: mockWalletService,
      testMode: true,
    );

    when(mockWalletService.loadWallet()).thenAnswer((_) async => 1000.0);
    when(mockWalletService.saveWallet(any)).thenAnswer((_) async {});
  });

  test('init() loads the wallet and refreshes the view', () async {
    await presenter.init();

    expect(presenter.board.player.wallet, 1000.0);
    verify(mockWalletService.loadWallet()).called(1);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('placeBetAndDeal() saves the wallet', () async {
    await presenter.init();
    presenter.placeBetAndDeal(10);

    verify(mockWalletService.saveWallet(990.0));
  });

  test(
    'stand() with a push saves the wallet with original bet returned',
    () async {
      await presenter.init();
      presenter.placeBetAndDeal(10);

      presenter.stand();

      // With a predictable deck, Player gets 20 (K+J) and Dealer gets 20 (Q+10).
      // This is a Push. The player gets their bet back.
      // Wallet: 1000 - 10 (bet) + 10 (payout) = 1000
      verify(mockWalletService.saveWallet(1000.0));
    },
  );

  test('surrender() saves the wallet with half the bet returned', () async {
    await presenter.init();
    presenter.placeBetAndDeal(20);

    presenter.surrender();

    // Wallet: 1000 - 20 (bet) + 10 (surrender) = 990
    verify(mockWalletService.saveWallet(990.0));
  });

  test('placeBetAndDeal() shows reshuffle message when needed', () {
    presenter.board.reshuffleNeeded = true;
    presenter.placeBetAndDeal(10);

    expect(mockView.reshuffleMessageWasShown, isTrue);
  });

  test('hit() adds a card to the hand', () async {
    await presenter.init();
    presenter.placeBetAndDeal(10);
    final initialCardCount = presenter.board.player.activeHand.cards.length;

    presenter.hit();

    expect(presenter.board.player.activeHand.cards.length, initialCardCount + 1);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  group('Actions with specific hands', () {
    test('doubleDown() on a win saves the correct wallet amount', () async {
      await presenter.init();
      // Manually set up the hand for a double down scenario
      presenter.board.placeBetAndDeal(10);
      presenter.board.player.clearHands();
      presenter.board.dealer.clearHands();
      presenter.board.player.activeHand.bet = 10;
      presenter.board.player.wallet = 990;
      presenter.board.player.addCard(Card(rank: Rank.six, suit: Suit.clubs));
      presenter.board.player.addCard(Card(rank: Rank.five, suit: Suit.clubs)); // Player has 11
      presenter.board.dealer.addCard(Card(rank: Rank.ten, suit: Suit.hearts));
      presenter.board.dealer.addCard(Card(rank: Rank.six, suit: Suit.hearts)); // Dealer has 16

      presenter.doubleDown(); // Player draws K of spades -> 21. Dealer hits and busts.

      // Wallet: 990 (start) - 10 (double) = 980. Bet is now 20.
      // Player wins. Payout is 20 * 2 = 40.
      // Final wallet = 980 + 40 = 1020.
      verify(mockWalletService.saveWallet(1020.0));
    });

    test('split() correctly debits wallet for the new hand', () async {
      await presenter.init();
      presenter.placeBetAndDeal(10);
      presenter.board.player.clearHands();
      presenter.board.dealer.clearHands();
      presenter.board.player.activeHand.bet = 10;
      presenter.board.player.wallet = 990;
      presenter.board.player.addCard(Card(rank: Rank.eight, suit: Suit.clubs));
      presenter.board.player.addCard(Card(rank: Rank.eight, suit: Suit.spades));

      presenter.split();

      // Wallet: 990 (start) - 10 (for the split) = 980
      verify(mockWalletService.saveWallet(980.0));
      expect(presenter.board.player.hands.length, 2);
    });
  });

  group('Insurance', () {
    setUp(() async {
      await presenter.init();
      // Manually set up the insurance scenario
      final board = presenter.board;
      board.player.clearHands();
      board.dealer.clearHands();
      board.player.activeHand.bet = 100;
      board.player.wallet = 900; // 1000 - 100 bet
      board.dealer.addCard(Card(rank: Rank.ace, suit: Suit.spades)); // Dealer shows Ace
      board.state = GameState.offeringInsurance;
      mockView.hasBeenRefreshed = false;
    });

    test('takeInsurance() with dealer blackjack has neutral payout', () {
      presenter.board.dealer.addCard(Card(rank: Rank.king, suit: Suit.spades));
      presenter.takeInsurance();

      // Wallet: 900 (start) - 50 (insurance) = 850.
      // Main bet lost (-100), insurance won (+100).
      // Final wallet: 850 + 150 (payout) = 1000.
      verify(mockWalletService.saveWallet(1000.0));
    });

    test('takeInsurance() with no dealer blackjack loses insurance bet', () {
      presenter.board.dealer.addCard(Card(rank: Rank.five, suit: Suit.spades));
      presenter.board.player.addCard(Card(rank: Rank.ten, suit: Suit.clubs));
      presenter.board.player.addCard(Card(rank: Rank.ten, suit: Suit.hearts)); // Player has 20

      presenter.takeInsurance(); // Wallet: 850. Insurance bet is lost.
      presenter.stand(); // Player stands on 20. Dealer (16) hits and busts.

      // Main bet is won. Payout is 100 * 2 = 200.
      // Final wallet: 850 + 200 = 1050.
      verify(mockWalletService.saveWallet(1050.0));
    });

    test('declineInsurance() with dealer blackjack loses main bet', () {
      presenter.board.dealer.addCard(Card(rank: Rank.king, suit: Suit.spades));
      presenter.declineInsurance();
      
      // Wallet: 900 (start). Main bet is lost.
      // Final wallet: 900.
      verify(mockWalletService.saveWallet(900.0));
    });
  });

  group('Game End Scenarios', () {
    test('Player bust on hit ends round and loses bet', () async {
      await presenter.init();
      presenter.placeBetAndDeal(10);
      // Manually rig a hand that will bust
      presenter.board.player.clearHands();
      presenter.board.player.activeHand.bet = 10;
      presenter.board.player.wallet = 990;
      presenter.board.player.addCard(Card(rank: Rank.ten, suit: Suit.clubs));
      presenter.board.player.addCard(Card(rank: Rank.six, suit: Suit.hearts)); // Player has 16

      presenter.hit(); // Player draws King of Spades -> 26, Bust!

      expect(presenter.board.state, GameState.roundOver);
      // Wallet: 990 (start). Bet is lost.
      // Final wallet: 990.
      verify(mockWalletService.saveWallet(990.0));
    });

    test('Split hand with one push and one loss has correct final wallet', () async {
      await presenter.init();
      // Manually set up a split scenario
      presenter.board.placeBetAndDeal(10);
      presenter.board.player.clearHands();
      presenter.board.dealer.clearHands();
      presenter.board.player.activeHand.bet = 10;
      presenter.board.player.wallet = 990;
      presenter.board.player.addCard(Card(rank: Rank.eight, suit: Suit.clubs));
      presenter.board.player.addCard(Card(rank: Rank.eight, suit: Suit.spades));
      presenter.board.dealer.addCard(Card(rank: Rank.ten, suit: Suit.hearts));
      presenter.board.dealer.addCard(Card(rank: Rank.seven, suit: Suit.hearts)); // Dealer has 17

      presenter.split(); // Wallet is now 980
      
      // First hand gets a 9 -> 17. Player stands.
      presenter.stand();

      // Second hand gets an 8 -> 16. Player stands.
      presenter.stand();

      // Hand 1 (17) is a PUSH against Dealer (17) -> Bet of 10 is returned.
      // Hand 2 (16) LOSES to Dealer (17) -> Bet of 10 is lost.
      // Wallet: 980 (after split) + 10 (push) + 0 (loss) = 990
      verify(mockWalletService.saveWallet(990.0));
    });
  });
}
