import 'package:blackjack/models/board.dart';
import 'package:blackjack/models/card.dart' as model_card;
import 'package:blackjack/widgets/card_view.dart';
import 'package:flutter/material.dart';

/// A widget that displays a single hand of cards (for the player or dealer).
class HandView extends StatelessWidget {
  const HandView({
    super.key,
    required this.title,
    required this.cards,
    required this.score,
    this.bet,
    this.isActive = false,
    this.result,
    this.animateCards = true,
  });

  final String title;
  final List<model_card.Card> cards;
  final int score;
  final double? bet;
  final bool isActive;
  final GameResult? result;
  final bool animateCards;

  @override
  Widget build(BuildContext context) {
    final betText = bet != null ? ', Bet: \$${bet!.toStringAsFixed(0)}' : '';

    Color? borderColor;
    if (result != null) {
      if (result!.payout > (bet ?? 0)) {
        borderColor = Colors.green.withAlpha(200); // Win
      } else if (result!.payout == (bet ?? 0)) {
        borderColor = Colors.grey.withAlpha(200); // Push
      } else {
        borderColor = Colors.red.withAlpha(200); // Loss
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ??
              (isActive ? Colors.deepPurple.withAlpha(128) : Colors.transparent),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (Score: $score$betText)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cards.map((card) {
                return CardView(
                  key: ObjectKey(card),
                  card: card,
                  animateOnBuild: animateCards,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
