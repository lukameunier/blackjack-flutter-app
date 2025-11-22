import 'dart:math' as math;

import 'package:blackjack/models/card.dart' as playing_card;
import 'package:blackjack/models/suit.dart';
import 'package:flutter/material.dart';

class HiddenCardView extends StatelessWidget {
  const HiddenCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87, width: 1.5),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 4, offset: Offset(1, 2), color: Colors.black26),
        ],
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white70, width: 1),
          ),
        ),
      ),
    );
  }
}

class CardView extends StatelessWidget {
  const CardView({super.key, required this.card});

  final playing_card.Card card;

  @override
  Widget build(BuildContext context) {
    final isRed = card.suit == Suit.hearts || card.suit == Suit.diamonds;
    final color = isRed ? Colors.red[700]! : Colors.black87;

    return Container(
      width: 80,
      height: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: const [
          BoxShadow(blurRadius: 4, offset: Offset(1, 2), color: Colors.black26),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 6,
            child: _CornerLabel(
              rank: card.rank.shortName,
              icon: card.suit.icon,
              color: color,
            ),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: Transform.rotate(
              angle: math.pi,
              child: _CornerLabel(
                rank: card.rank.shortName,
                icon: card.suit.icon,
                color: color,
              ),
            ),
          ),
          Center(child: Icon(card.suit.icon, size: 36, color: color)),
        ],
      ),
    );
  }
}

class _CornerLabel extends StatelessWidget {
  const _CornerLabel({
    required this.rank,
    required this.icon,
    required this.color,
  });

  final String rank;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          rank,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Icon(icon, size: 16, color: color),
      ],
    );
  }
}
