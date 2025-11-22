import 'package:blackjack/models/card.dart' as playing_card;
import 'package:blackjack/models/rank.dart';
import 'package:blackjack/models/suit.dart';
import 'package:blackjack/views/card_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CardView displays the rank and suit correctly', (WidgetTester tester) async {
    // Arrange
    final card = playing_card.Card(rank: Rank.ace, suit: Suit.hearts);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardView(card: card),
        ),
      ),
    );

    // Assert
    final rankFinder = find.text('A');
    final suitFinder = find.byIcon(Suit.hearts.icon);

    // Expect to find two instances of the rank text (top-left, bottom-right)
    expect(rankFinder, findsNWidgets(2));
    // Expect to find three instances of the suit icon (top-left, bottom-right, center)
    expect(suitFinder, findsNWidgets(3));
  });
}
