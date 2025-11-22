import 'package:blackjack/models/board.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_page_presenter_test.mocks.dart';
import 'package:blackjack/services/wallet_service.dart';

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
    // Provide the mock service to the presenter
    presenter = HomePagePresenter(mockView, walletService: mockWalletService, testMode: true);

    // Default behavior for the mock
    when(mockWalletService.loadWallet()).thenAnswer((_) async => 1000.0);
    when(mockWalletService.saveWallet(any)).thenAnswer((_) async {});
  });

  test('Initial state is betting and wallet is loaded', () async {
    // We need to wait for the initial wallet load
    await presenter.loadInitialWallet();

    expect(presenter.board.state, GameState.betting);
    expect(presenter.board.player.wallet, 1000.0);
    verify(mockWalletService.loadWallet());
  });

  test('placeBetAndDeal() saves the wallet', () async {
    await presenter.loadInitialWallet(); // Ensure wallet is loaded first
    presenter.placeBetAndDeal(10);

    // Verify that saveWallet was called with the new amount
    verify(mockWalletService.saveWallet(990.0));
  });

  test('stand() saves the wallet after payout', () async {
    await presenter.loadInitialWallet();
    presenter.placeBetAndDeal(10); // Player gets 20, Dealer gets 19
    
    presenter.stand();
    await Future.delayed(Duration.zero); // Allow async operations to complete

    // Player wins, wallet should be 1000 - 10 + 20 = 1010
    verify(mockWalletService.saveWallet(1010.0));
  });
}
