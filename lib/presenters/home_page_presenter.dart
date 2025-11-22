import 'package:blackjack/models/board.dart';
import 'package:blackjack/services/wallet_service.dart';

abstract class HomePageView {
  void refresh();
  void showReshuffleMessage();
}

class HomePagePresenter {
  HomePagePresenter(this._view, {WalletService? walletService, bool testMode = false})
      : _walletService = walletService ?? WalletService(),
        _board = Board(testMode: testMode);

  final HomePageView _view;
  final Board _board;
  final WalletService _walletService;

  Board get board => _board;

  Future<void> init() async {
    final amount = await _walletService.loadWallet();
    board.player.wallet = amount;
    _view.refresh();
  }

  Future<void> _saveWallet() async {
    await _walletService.saveWallet(board.player.wallet);
  }

  void placeBetAndDeal(double amount) {
    if (board.reshuffleNeeded) {
      _view.showReshuffleMessage();
    }
    _board.placeBetAndDeal(amount);
    _saveWallet();
    _view.refresh();
  }

  void takeInsurance() {
    _board.takeInsurance();
    _saveWallet();
    _view.refresh();
  }

  void declineInsurance() {
    _board.declineInsurance();
    _saveWallet(); // Save wallet in case the round ends
    _view.refresh();
  }

  void surrender() {
    if (!board.canSurrender) return;
    _board.surrender();
    _saveWallet();
    _view.refresh();
  }

  void hit() {
    if (board.state != GameState.playing) return;
    _board.hit();
    _view.refresh();
  }

  void stand() {
    if (board.state != GameState.playing) return;
    _board.stand();
    _saveWallet();
    _view.refresh();
  }

  void doubleDown() {
    if (!board.canDoubleDown) return;
    _board.doubleDown();
    _saveWallet();
    _view.refresh();
  }

  void split() {
    if (!board.canSplit) return;
    _board.split();
    _saveWallet();
    _view.refresh();
  }

  void nextRound() {
    _board.nextRound();
    _view.refresh();
  }
}
