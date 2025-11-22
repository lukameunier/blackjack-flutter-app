import 'package:blackjack/models/card.dart' as playing_card;
import 'package:blackjack/models/rank.dart';
import 'package:flutter/material.dart';

class HiddenCardView extends StatelessWidget {
  const HiddenCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 110,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
      ),
    );
  }
}

class CardView extends StatelessWidget {
  const CardView({super.key, required this.card});

  final playing_card.Card card;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 80,
        height: 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(card.rank.displayValue.toString(), style: Theme.of(context).textTheme.titleLarge),
            Icon(card.suit.icon, size: 30),
          ],
        ),
      ),
    );
  }
}
