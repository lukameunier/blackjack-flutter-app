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
    presenter = HomePagePresenter(mockView);
  });

  test('When hit() is called, player receives a card and view is refreshed', () {
    final initialCardCount = presenter.board.player.hand.length;

    presenter.hit();

    expect(presenter.board.player.hand.length, initialCardCount + 1);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('When stand() is called, the round is over and view is refreshed', () {
    presenter.stand();

    expect(presenter.board.isRoundOver, isTrue);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('When doubleDown() is called, player gets one card, round ends, and view is refreshed', () {
    final initialCardCount = presenter.board.player.hand.length;

    presenter.doubleDown();

    expect(presenter.board.player.hand.length, initialCardCount + 1);
    expect(presenter.board.isRoundOver, isTrue);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('When newGame() is called, the board is reset and view is refreshed', () {
    presenter.hit();
    presenter.stand();
    expect(presenter.board.isRoundOver, isTrue);

    presenter.newGame();

    expect(presenter.board.isRoundOver, isFalse);
    expect(presenter.board.player.hand.length, 2);
    expect(mockView.hasBeenRefreshed, isTrue);
  });
}
