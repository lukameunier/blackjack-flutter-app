import 'package:blackjack/models/board.dart';

abstract class HomePageView {
  void refresh();
}

class HomePagePresenter {
  HomePagePresenter(this._view) {
    _board = Board();
  }

  final HomePageView _view;
  late Board _board;

  Board get board => _board;

  void newGame() {
    _board.newGame();
    _view.refresh();
  }

  void hit() {
    _board.hit();
    _view.refresh();
  }

  void stand() {
    _board.stand();
    _view.refresh();
  }

  void doubleDown() {
    _board.doubleDown();
    _view.refresh();
  }

  void split() {
    _board.split();
    _view.refresh();
  }
}
