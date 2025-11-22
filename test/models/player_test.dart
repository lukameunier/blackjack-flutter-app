import 'package:blackjack/models/card.dart';
import 'package:blackjack/models/player.dart';
import 'package:blackjack/models/rank.dart';
import 'package:blackjack/models/suit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Score Calculation', () {
    test('is calculated correctly without Aces', () {
      final player = Player();
      final card1 = Card(rank: Rank.five, suit: Suit.hearts);
      final card2 = Card(rank: Rank.ten, suit: Suit.clubs);

      player.addCard(card1);
      player.addCard(card2);

      expect(player.activeHand.score, 15);
    });

    test('is calculated correctly with one Ace as 11', () {
      final player = Player();
      final aceCard = Card(rank: Rank.ace, suit: Suit.spades);
      final fiveCard = Card(rank: Rank.five, suit: Suit.diamonds);

      player.addCard(aceCard);
      player.addCard(fiveCard);

      expect(player.activeHand.score, 16);
    });

    test('is calculated correctly with one Ace as 1 when score would bust', () {
      final player = Player();
      final eightCard = Card(rank: Rank.eight, suit: Suit.hearts);
      final sevenCard = Card(rank: Rank.seven, suit: Suit.clubs);
      final aceCard = Card(rank: Rank.ace, suit: Suit.spades);

      player.addCard(eightCard);
      player.addCard(sevenCard);
      player.addCard(aceCard);

      expect(player.activeHand.score, 16);
    });

    test('is calculated correctly with multiple Aces', () {
      final player = Player();
      final ace1 = Card(rank: Rank.ace, suit: Suit.spades);
      final ace2 = Card(rank: Rank.ace, suit: Suit.hearts);
      final five = Card(rank: Rank.five, suit: Suit.clubs);

      player.addCard(ace1);
      player.addCard(ace2);
      player.addCard(five);

      expect(player.activeHand.score, 17);
    });
  });

  group('isBlackjack Getter', () {
    test('returns true for a natural blackjack (Ace and 10-value card)', () {
      // Arrange
      final player = Player();
      final ace = Card(rank: Rank.ace, suit: Suit.spades);
      final king = Card(rank: Rank.king, suit: Suit.clubs);

      // Act
      player.addCard(ace);
      player.addCard(king);

      // Assert
      expect(player.isBlackjack, isTrue);
    });

    test('returns false for a 21 with three cards', () {
      // Arrange
      final player = Player();
      player.addCard(Card(rank: Rank.seven, suit: Suit.hearts));
      player.addCard(Card(rank: Rank.seven, suit: Suit.clubs));
      player.addCard(Card(rank: Rank.seven, suit: Suit.spades));

      // Act & Assert
      expect(player.isBlackjack, isFalse);
    });

    test('returns false for a hand with only one card', () {
      final player = Player();
      player.addCard(Card(rank: Rank.ace, suit: Suit.spades));

      expect(player.isBlackjack, isFalse);
    });
  });
}
