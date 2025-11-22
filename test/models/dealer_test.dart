import 'package:blackjack/models/card.dart';
import 'package:blackjack/models/dealer.dart';
import 'package:blackjack/models/deck.dart';
import 'package:blackjack/models/rank.dart';
import 'package:blackjack/models/suit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dealer hits when score is less than 17', () {
    final dealer = Dealer();
    dealer.addCard(Card(rank: Rank.ten, suit: Suit.clubs));
    dealer.addCard(Card(rank: Rank.six, suit: Suit.hearts));

    final deck = Deck();

    dealer.playTurn(deck);
    
    expect(dealer.score, greaterThanOrEqualTo(17));
    expect(dealer.hand.length, greaterThan(2));
  });

  test('Dealer stands when score is 17 or greater', () {
    final dealer = Dealer();
    dealer.addCard(Card(rank: Rank.ten, suit: Suit.clubs));
    dealer.addCard(Card(rank: Rank.seven, suit: Suit.hearts));

    final deck = Deck();

    dealer.playTurn(deck);

    expect(dealer.score, 17);
    expect(dealer.hand.length, 2);
  });
}
