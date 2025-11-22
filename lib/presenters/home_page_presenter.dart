import 'package:blackjack/models/board.dart';

abstract class HomePageView {
  void refresh();
}

class HomePagePresenter {
  HomePagePresenter(this._view, {bool testMode = false}) {
    _board = Board(testMode: testMode);
  }

  final HomePageView _view;
  late Board _board;

  Board get board => _board;

  void placeBetAndDeal(double amount) {
    _board.placeBetAndDeal(amount);
    _view.refresh();
  }

  void takeInsurance() {
    _board.takeInsurance();
    _view.refresh();
  }

  void declineInsurance() {
    _board.declineInsurance();
    _view.refresh();
  }

  void surrender() {
    if (!board.canSurrender) return;
    _board.surrender();
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
    _view.refresh();
  }

  void doubleDown() {
    if (!board.canDoubleDown) return;
    _board.doubleDown();
    _view.refresh();
  }

  void split() {
    if (!board.canSplit) return;
    _board.split();
    _view.refresh();
  }

  void nextRound() {
    _board.nextRound();
    _view.refresh();
  }
}
