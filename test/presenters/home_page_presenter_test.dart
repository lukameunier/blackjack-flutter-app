import 'package:blackjack/models/card.dart';
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
    presenter = HomePagePresenter(mockView);
  });

  test('When hit() is called, player receives a card and view is refreshed', () {
    final initialCardCount = presenter.board.player.activeHand.cards.length;

    presenter.hit();

    expect(presenter.board.player.activeHand.cards.length, initialCardCount + 1);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('When stand() is called, the round is over and view is refreshed', () {
    presenter.stand();

    expect(presenter.board.isRoundOver, isTrue);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('When doubleDown() is called, player gets one card, round ends, and view is refreshed', () {
    final initialCardCount = presenter.board.player.activeHand.cards.length;

    presenter.doubleDown();

    expect(presenter.board.player.activeHand.cards.length, initialCardCount + 1);
    expect(presenter.board.isRoundOver, isTrue);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('When newGame() is called, the board is reset and view is refreshed', () {
    presenter.hit();
    presenter.stand();
    expect(presenter.board.isRoundOver, isTrue);

    presenter.newGame();

    expect(presenter.board.isRoundOver, isFalse);
    expect(presenter.board.player.activeHand.cards.length, 2);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('When split() is called, player has two hands and view is refreshed', () {
    // Arrange
    final player = presenter.board.player;
    player.clearHand();
    player.addCard(Card(rank: Rank.ace, suit: Suit.clubs));
    player.addCard(Card(rank: Rank.ace, suit: Suit.spades));

    // Act
    presenter.split();

    // Assert
    expect(player.hands.length, 2);
    expect(player.hands[0].cards.length, 2);
    expect(player.hands[1].cards.length, 2);
    expect(mockView.hasBeenRefreshed, isTrue);
  });
}
