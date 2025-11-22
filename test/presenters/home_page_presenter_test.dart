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
}
