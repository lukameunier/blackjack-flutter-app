import 'dart:math' as math;

import 'package:blackjack/models/card.dart' as playing_card;
import 'package:blackjack/models/suit.dart';
import 'package:flutter/material.dart';

class CardView extends StatefulWidget {
  const CardView({
    super.key,
    required this.card,
    this.animateOnBuild = true, // Le widget animera par défaut
  });

  final playing_card.Card card;
  final bool animateOnBuild;

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(2.0, -2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Condition pour l'animation
    if (widget.animateOnBuild) {
      _controller.forward();
    } else {
      // Si pas d'animation, on affiche directement l'état final
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Au cas où le widget est reconstruit et qu'on lui demande d'arrêter d'animer
    if (!widget.animateOnBuild) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRed =
        widget.card.suit == Suit.hearts || widget.card.suit == Suit.diamonds;
    final color = isRed ? Colors.red[700]! : Colors.black87;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: 80,
          height: 120,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black87, width: 1.5),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                offset: Offset(1, 2),
                color: Colors.black26,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 6,
                left: 6,
                child: _CornerLabel(
                  rank: widget.card.rank.shortName,
                  icon: widget.card.suit.icon,
                  color: color,
                ),
              ),
              Positioned(
                bottom: 6,
                right: 6,
                child: Transform.rotate(
                  angle: math.pi,
                  child: _CornerLabel(
                    rank: widget.card.rank.shortName,
                    icon: widget.card.suit.icon,
                    color: color,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(-5.5, 0),
                child: Center(
                  child: Icon(widget.card.suit.icon, size: 36, color: color),
                ),
              ),
            ],
          ),
        ),
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
            fontSize: 14, // Taille du texte encore réduite
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Icon(icon, size: 12, color: color), // Taille de l'icône encore réduite
      ],
    );
  }
}
