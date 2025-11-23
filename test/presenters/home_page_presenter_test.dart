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

// Aucun mock de vue n'est plus nécessaire grâce au ChangeNotifier

@GenerateMocks([WalletService])
void main() {
  late HomePagePresenter presenter;
  late MockWalletService mockWalletService;

  setUp(() {
    mockWalletService = MockWalletService();
    // On injecte le mock dans le constructeur
    presenter = HomePagePresenter(
      walletService: mockWalletService,
      testMode: true,
    );

    when(mockWalletService.loadWallet()).thenAnswer((_) async => 1000.0);
    when(mockWalletService.saveWallet(any)).thenAnswer((_) async {});
  });

  test('init() loads the wallet and notifies listeners', () async {
    int listenerCallCount = 0;
    presenter.addListener(() => listenerCallCount++);

    await presenter.init();

    expect(presenter.board.player.wallet, 1000.0);
    verify(mockWalletService.loadWallet()).called(1);
    expect(listenerCallCount, 1);
  });

  test('placeBetAndDeal() saves the wallet and notifies listeners', () {
    presenter.board.player.wallet = 1000.0; // État initial
    int listenerCallCount = 0;
    presenter.addListener(() => listenerCallCount++);

    presenter.placeBetAndDeal(10);

    verify(mockWalletService.saveWallet(990.0));
    expect(listenerCallCount, 1);
  });

  test(
    'stand() with a push saves the wallet and notifies listeners',
    () async {
      await presenter.init(); // Met le portefeuille à 1000
      presenter.placeBetAndDeal(10); // Met le portefeuille à 990 et sauvegarde

      int listenerCallCount = 0;
      presenter.addListener(() => listenerCallCount++);

      presenter.stand();

      // Wallet: 1000 - 10 (bet) + 10 (payout) = 1000
      verify(mockWalletService.saveWallet(1000.0));
      expect(listenerCallCount, 1);
    },
  );

  test('surrender() saves the wallet and notifies listeners', () async {
    await presenter.init();
    presenter.placeBetAndDeal(20);

    int listenerCallCount = 0;
    presenter.addListener(() => listenerCallCount++);

    presenter.surrender();

    // Wallet: 1000 - 20 (bet) + 10 (surrender) = 990
    verify(mockWalletService.saveWallet(990.0));
    expect(listenerCallCount, 1);
  });

  test('hit() adds a card to the hand and notifies listeners', () async {
    await presenter.init();
    presenter.placeBetAndDeal(10);
    final initialCardCount = presenter.board.player.activeHand.cards.length;

    int listenerCallCount = 0;
    presenter.addListener(() => listenerCallCount++);

    presenter.hit();

    expect(presenter.board.player.activeHand.cards.length, initialCardCount + 1);
    expect(listenerCallCount, 1);
  });

  test('nextRound() resets the board and notifies listeners', () {
    // Given a board in a round-over state
    presenter.board.state = GameState.roundOver;
    presenter.board.player.addCard(Card(rank: Rank.ace, suit: Suit.spades));
    presenter.board.dealer.addCard(Card(rank: Rank.king, suit: Suit.hearts));
    
    int listenerCallCount = 0;
    presenter.addListener(() => listenerCallCount++);

    // When nextRound is called
    presenter.nextRound();

    // Then the board is reset to betting state and listeners are notified
    expect(presenter.board.state, GameState.betting);
    expect(presenter.board.player.activeHand.cards.isEmpty, isTrue);
    expect(presenter.board.dealer.activeHand.cards.isEmpty, isTrue);
    expect(listenerCallCount, 1);
  });

  group('Actions with specific hands', () {
    test('doubleDown() on a win saves the correct wallet amount', () async {
      await presenter.init();
      // Setup manuel de la main
      presenter.board.placeBetAndDeal(10);
      presenter.board.player.clearHands();
      presenter.board.dealer.clearHands();
      presenter.board.player.activeHand.bet = 10;
      presenter.board.player.wallet = 990;
      presenter.board.player.addCard(Card(rank: Rank.six, suit: Suit.clubs));
      presenter.board.player.addCard(Card(rank: Rank.five, suit: Suit.clubs)); // Le joueur a 11
      presenter.board.dealer.addCard(Card(rank: Rank.ten, suit: Suit.hearts));
      presenter.board.dealer.addCard(Card(rank: Rank.six, suit: Suit.hearts)); // Le croupier a 16

      presenter.doubleDown(); // Le joueur tire un Roi -> 21. Le croupier saute.

      // Wallet: 990 (début) - 10 (double) = 980. La mise est maintenant 20.
      // Le joueur gagne. Le gain est 20 * 2 = 40.
      // Wallet final = 980 + 40 = 1020.
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

      // Wallet: 990 (début) - 10 (pour le split) = 980
      verify(mockWalletService.saveWallet(980.0));
      expect(presenter.board.player.hands.length, 2);
    });
  });

  group('Insurance', () {
    setUp(() async {
      await presenter.init();
      // Setup manuel du scénario d'assurance
      final board = presenter.board;
      board.player.clearHands();
      board.dealer.clearHands();
      board.player.activeHand.bet = 100;
      board.player.wallet = 900; // 1000 - 100 de mise
      board.dealer.addCard(Card(rank: Rank.ace, suit: Suit.spades)); // Le croupier montre un As
      board.state = GameState.offeringInsurance;
      presenter.notifyListeners(); // Simule la mise à jour de la vue
    });

    test('takeInsurance() with dealer blackjack has neutral payout', () {
      presenter.board.dealer.addCard(Card(rank: Rank.king, suit: Suit.spades));
      presenter.takeInsurance();

      // Wallet: 900 (début) - 50 (assurance) = 850.
      // Mise principale perdue (-100), assurance gagnée (+100).
      // Wallet final: 850 + 100 (mise principale) + 50 (assurance) = 1000.
      verify(mockWalletService.saveWallet(1000.0));
    });

    test('takeInsurance() with no dealer blackjack loses insurance bet', () {
      presenter.board.dealer.addCard(Card(rank: Rank.five, suit: Suit.spades));
      presenter.board.player.addCard(Card(rank: Rank.ten, suit: Suit.clubs));
      presenter.board.player.addCard(Card(rank: Rank.ten, suit: Suit.hearts)); // Joueur a 20

      presenter.takeInsurance(); // Wallet: 850. L'assurance est perdue.
      presenter.stand(); // Joueur reste à 20. Le croupier (16) saute.

      // La mise principale est gagnée. Gain est 100 * 2 = 200.
      // Wallet final: 850 + 200 = 1050.
      verify(mockWalletService.saveWallet(1050.0));
    });

    test('declineInsurance() with dealer blackjack loses main bet', () {
      presenter.board.dealer.addCard(Card(rank: Rank.king, suit: Suit.spades));
      presenter.declineInsurance();

      // Wallet: 900 (début). La mise principale est perdue.
      // Wallet final: 900.
      verify(mockWalletService.saveWallet(900.0));
    });
  });

  group('Game End Scenarios', () {
    test('Player bust on hit ends round and loses bet', () async {
      await presenter.init();
      presenter.placeBetAndDeal(10);
      // Truquer la main pour qu'elle saute
      presenter.board.player.clearHands();
      presenter.board.player.activeHand.bet = 10;
      presenter.board.player.wallet = 990;
      presenter.board.player.addCard(Card(rank: Rank.ten, suit: Suit.clubs));
      presenter.board.player.addCard(Card(rank: Rank.six, suit: Suit.hearts)); // Joueur a 16

      presenter.hit(); // Joueur tire un Roi -> 26, Bust!

      expect(presenter.board.state, GameState.roundOver);
      // Wallet: 990 (début). La mise est perdue.
      // Le wallet ne change pas, mais on vérifie que la sauvegarde est appelée à la fin du tour du joueur.
      verify(mockWalletService.saveWallet(990.0));
    });

    test('Split hand with one push and one loss has correct final wallet', () async {
      await presenter.init();
      // Setup manuel du split
      presenter.placeBetAndDeal(10);
      presenter.board.player.clearHands();
      presenter.board.dealer.clearHands();
      presenter.board.player.activeHand.bet = 10;
      presenter.board.player.wallet = 990;
      presenter.board.player.addCard(Card(rank: Rank.eight, suit: Suit.clubs));
      presenter.board.player.addCard(Card(rank: Rank.eight, suit: Suit.spades));
      presenter.board.dealer.addCard(Card(rank: Rank.ten, suit: Suit.hearts));
      presenter.board.dealer.addCard(Card(rank: Rank.seven, suit: Suit.hearts)); // Le croupier a 17

      presenter.split(); // Wallet est maintenant 980

      // Première main reçoit un 9 -> 17. Le joueur reste.
      presenter.stand();

      // Seconde main reçoit un 8 -> 16. Le joueur reste.
      presenter.stand();

      // Main 1 (17) est un PUSH contre le croupier (17) -> Mise de 10 est retournée.
      // Main 2 (16) PERD contre le croupier (17) -> Mise de 10 est perdue.
      // Wallet: 980 (après split) + 10 (push) + 0 (perte) = 990
      verify(mockWalletService.saveWallet(990.0));
    });
  });
}