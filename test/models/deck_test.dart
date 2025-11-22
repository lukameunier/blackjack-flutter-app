import 'package:blackjack/models/deck.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('New default deck has 312 cards (6 * 52)', () {
    final deck = Deck();
    final cardCount = deck.cards.length;
    expect(cardCount, 312);
  });

  test('Can create a deck with a specific number of packs', () {
    final deck = Deck(numDecks: 1);
    expect(deck.cards.length, 52);
  });

  test('Deck is created in a predictable order when shuffle is false', () {
    final deck = Deck(numDecks: 1, shuffle: false);
    // First card should be Ace of Hearts, last should be King of Spades
    expect(deck.cards.first.rank.shortName, 'A');
    expect(deck.cards.first.suit.name, 'hearts');
    expect(deck.cards.last.rank.shortName, 'K');
    expect(deck.cards.last.suit.name, 'spades');
  });

  test('burn() method removes the correct number of cards from the top', () {
    final deck = Deck(shuffle: false);
    deck.burn(5);
    expect(deck.cards.length, 307); // 312 - 5
    // The first card should now be the 6th card of an unshuffled deck (the 'six' of hearts)
    expect(deck.cards.first.rank.shortName, '6');
  });

  test('Drawing a card reduces deck size by one', () {
    final deck = Deck();
    deck.drawCard();
    final cardCount = deck.cards.length;
    expect(cardCount, 311);
  });

  test('Drawing from an empty deck throws a StateError', () {
    final deck = Deck(numDecks: 1);
    for (int i = 0; i < 52; i++) {
      deck.drawCard();
    }
    expect(() => deck.drawCard(), throwsA(isA<StateError>()));
  });

  test('Shuffling the deck changes the card order', () {
    final deck = Deck();
    final initialOrder = Deck(shuffle: false).cards.map((c) => c.toString()).join(',');
    final shuffledOrder = deck.cards.map((c) => c.toString()).join(',');
    expect(shuffledOrder, isNot(initialOrder));
  });
}
