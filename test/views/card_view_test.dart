import 'package:blackjack/models/card.dart' as playing_card;
import 'package:blackjack/models/rank.dart';
import 'package:blackjack/models/suit.dart';
import 'package:blackjack/views/card_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CardView displays the rank and suit of a card', (WidgetTester tester) async {
    // 1. Arrange: Define the card to be displayed.
    final card = playing_card.Card(rank: Rank.ace, suit: Suit.hearts);

    // 2. Act: Build our widget.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardView(card: card),
        ),
      ),
    );

    // 3. Assert: Verify that the correct text and icon are displayed.
    final rankFinder = find.text('A');
    final suitFinder = find.byIcon(Suit.hearts.icon);

    expect(rankFinder, findsOneWidget);
    expect(suitFinder, findsOneWidget);
  });
}
