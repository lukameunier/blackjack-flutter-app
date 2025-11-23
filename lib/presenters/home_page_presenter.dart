import 'package:blackjack/models/board.dart';
import 'package:blackjack/services/wallet_service.dart';
import 'package:flutter/foundation.dart';

class HomePagePresenter with ChangeNotifier {
  HomePagePresenter({WalletService? walletService, bool testMode = false})
      : _walletService = walletService ?? WalletService(),
        _board = Board(testMode: testMode);

  final Board _board;
  final WalletService _walletService;

  Board get board => _board;

  Future<void> init() async {
    final amount = await _walletService.loadWallet();
    board.player.wallet = amount;
    notifyListeners();
  }

  Future<void> _saveWallet() async {
    await _walletService.saveWallet(board.player.wallet);
  }

  void placeBetAndDeal(double amount) {
    _board.placeBetAndDeal(amount);
    _saveWallet();
    notifyListeners();
  }

  void takeInsurance() {
    _board.takeInsurance();
    _saveWallet();
    notifyListeners();
  }

  void declineInsurance() {
    _board.declineInsurance();
    _saveWallet();
    notifyListeners();
  }

  void surrender() {
    if (!board.canSurrender) return;
    _board.surrender();
    _saveWallet();
    notifyListeners();
  }

  void hit() {
    if (board.state != GameState.playing) return;
    _board.hit();
    notifyListeners();
  }

  void stand() {
    if (board.state != GameState.playing) return;
    _board.stand();
    _saveWallet();
    notifyListeners();
  }

  void doubleDown() {
    if (!board.canDoubleDown) return;
    _board.doubleDown();
    _saveWallet();
    notifyListeners();
  }

  void split() {
    if (!board.canSplit) return;
    _board.split();
    _saveWallet();
    notifyListeners();
  }

  void nextRound() {
    _board.nextRound();
    notifyListeners();
  }
}
