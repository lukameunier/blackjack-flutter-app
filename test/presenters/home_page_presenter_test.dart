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

  // Helper function to set up a known, non-random hand
  void _setUpKnownHand(List<Card> playerCards) {
    presenter.board.player.clearHand();
    for (var card in playerCards) {
      presenter.board.player.addCard(card);
    }
    // Ensure dealer doesn't have blackjack to avoid auto-ending the round
    presenter.board.dealer.clearHand();
    presenter.board.dealer.addCard(Card(rank: Rank.two, suit: Suit.clubs));
    presenter.board.dealer.addCard(Card(rank: Rank.three, suit: Suit.clubs));
    presenter.board.isRoundOver = false;
  }

  test('When hit() is called, player receives a card and view is refreshed', () {
    _setUpKnownHand([Card(rank: Rank.five, suit: Suit.hearts), Card(rank: Rank.ten, suit: Suit.clubs)]);
    final initialCardCount = presenter.board.player.activeHand.cards.length;

    presenter.hit();

    expect(presenter.board.player.activeHand.cards.length, initialCardCount + 1);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('When stand() is called, the round is over and view is refreshed', () {
    _setUpKnownHand([Card(rank: Rank.five, suit: Suit.hearts), Card(rank: Rank.ten, suit: Suit.clubs)]);
    presenter.stand();

    expect(presenter.board.isRoundOver, isTrue);
    expect(mockView.hasBeenRefreshed, isTrue);
  });

  test('When doubleDown() is called, player gets one card, round ends, and view is refreshed', () {
    _setUpKnownHand([Card(rank: Rank.five, suit: Suit.hearts), Card(rank: Rank.ten, suit: Suit.clubs)]);
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

  group('Split Action', () {
    test('When split() is called on a valid pair, player gets two hands and view is refreshed', () {
      _setUpKnownHand([Card(rank: Rank.ace, suit: Suit.clubs), Card(rank: Rank.ace, suit: Suit.spades)]);

      presenter.split();

      expect(presenter.board.player.hands.length, 2);
      expect(presenter.board.player.hands[0].cards.length, 2);
      expect(presenter.board.player.hands[1].cards.length, 2);
      expect(mockView.hasBeenRefreshed, isTrue);
    });

    test('When split() is called on an invalid hand, nothing happens', () {
      _setUpKnownHand([Card(rank: Rank.ace, suit: Suit.clubs), Card(rank: Rank.king, suit: Suit.spades)]);

      presenter.split();

      expect(presenter.board.player.hands.length, 1);
      expect(presenter.board.player.activeHand.cards.length, 2);
      expect(mockView.hasBeenRefreshed, isFalse);
    });
  });
}
