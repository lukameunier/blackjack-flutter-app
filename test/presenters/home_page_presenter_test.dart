import 'package:blackjack/models/board.dart';
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
    // Create the presenter in test mode to ensure a predictable (unshuffled) deck
    mockView = MockHomePageView();
    presenter = HomePagePresenter(mockView, testMode: true);
  });

  test('Initial state is betting', () {
    expect(presenter.board.state, GameState.betting);
  });

  test('placeBetAndDeal() starts the game with a predictable hand and refreshes', () {
    // Arrange
    final initialWallet = presenter.board.player.wallet;

    // Act
    presenter.placeBetAndDeal(10);

    // Assert
    expect(presenter.board.state, GameState.playing);
    expect(presenter.board.player.wallet, initialWallet - 10);
    expect(presenter.board.player.hands.first.bet, 10);
    expect(presenter.board.player.hands.first.cards.length, 2);
    // With an unshuffled deck, the player will have King of Spades and King of Hearts
    expect(presenter.board.player.hands.first.score, 20);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  group('During gameplay with a predictable hand', () {
    setUp(() {
      presenter.placeBetAndDeal(10);
      mockView.hasBeenRefreshed = false;
    });

    test('hit() adds a card and refreshes', () {
      final initialCardCount = presenter.board.player.activeHand.cards.length;
      presenter.hit();
      expect(presenter.board.player.activeHand.cards.length, initialCardCount + 1);
      expect(mockView.hasBeenRefreshed, isTrue);
    });

    test('stand() ends the round and refreshes', () {
      presenter.stand();
      expect(presenter.board.state, GameState.roundOver);
      expect(mockView.hasBeenRefreshed, isTrue);
    });

    test('nextRound() resets to betting state and refreshes', () {
      presenter.stand();
      mockView.hasBeenRefreshed = false;

      presenter.nextRound();

      expect(presenter.board.state, GameState.betting);
      expect(presenter.board.player.hands.first.cards, isEmpty);
      expect(mockView.hasBeenRefreshed, isTrue);
    });
  });
}
