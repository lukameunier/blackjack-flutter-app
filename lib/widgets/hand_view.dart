import 'package:blackjack/models/board.dart';
import 'package:blackjack/models/card.dart' as model_card;
import 'package:blackjack/widgets/card_view.dart';
import 'package:flutter/material.dart';

/// A widget that displays a single hand of cards with an overlapping effect.
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

  // --- Restored Card Sizing ---
  static const double cardWidth = 80.0;
  static const double cardHeight = 120.0;
  static const double overlap = 40.0;

  @override
  Widget build(BuildContext context) {
    final betText = bet != null ? ' | Bet: \$${bet!.toStringAsFixed(0)}' : '';
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            const Shadow(
                blurRadius: 2, color: Colors.black54, offset: Offset(1, 1))
          ],
        );

    // Determine glow color based on win/loss result
    Color? glowColor;
    if (result != null) {
      if (result!.payout > (bet ?? 0)) {
        glowColor = Colors.greenAccent; // Win
      } else if (result!.payout < (bet ?? 0)) {
        glowColor = Colors.redAccent; // Loss
      }
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.7),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : (glowColor != null
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(0.7),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : []),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$title: $score$betText',
            style: titleStyle,
          ),
          const SizedBox(height: 8),
          // Overlapping card stack
          SizedBox(
            width: cards.isEmpty
                ? cardWidth
                : cardWidth + (cards.length - 1) * overlap,
            height: cardHeight,
            child: Stack(
              children: List.generate(cards.length, (index) {
                final card = cards[index];
                return Positioned(
                  left: index * overlap,
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: CardView(
                      key: ObjectKey(card),
                      card: card,
                      animateOnBuild: animateCards,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
