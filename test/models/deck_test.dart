import 'package:blackjack/models/deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('New deck has 52 cards', () {
    final deck = Deck();

    final cardCount = deck.cards.length;

    expect(cardCount, 52);
  });

  test('Drawing a card reduces deck size by one', () {
    final deck = Deck();

    deck.drawCard();
    final cardCount = deck.cards.length;

    expect(cardCount, 51);
  });

  test('Drawing from an empty deck throws a StateError', () {
    final deck = Deck();

    for (int i = 0; i < 52; i++) {
      deck.drawCard();
    }

    expect(() => deck.drawCard(), throwsA(isA<StateError>()));
  });

  test('Shuffling the deck changes the card order', () {
    final deck = Deck();
    final initialOrder = Deck().cards.map((c) => c.toString()).join(',');

    deck.shuffle();
    final shuffledOrder = deck.cards.map((c) => c.toString()).join(',');

    expect(shuffledOrder, isNot(initialOrder));
  });
}
