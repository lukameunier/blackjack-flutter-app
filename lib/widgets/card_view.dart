import 'dart:math' as math;

import 'package:blackjack/models/card.dart' as playing_card;
import 'package:blackjack/models/suit.dart';
import 'package:flutter/material.dart';

const double _kCardBorderRadius = 8.0;
const double _kCardBorderWidth = 1.5;
const EdgeInsets _kCardMargin = EdgeInsets.only(right: 8.0);
const double _kCornerPadding = 4.0; // Reduced padding

const double _kCenterIconSizeRatio = 0.4; // Relative to card height
const double _kCornerRankFontSizeRatio = 0.15; // Relative to card height
const double _kCornerIconSizeRatio = 0.12; // Relative to card height

const double _kShadowBlurRadius = 4.0;
const Offset _kShadowOffset = Offset(1, 2);

class CardView extends StatefulWidget {
  const CardView({super.key, required this.card, this.animateOnBuild = true});

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

    if (widget.animateOnBuild) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CardView oldWidget) {
    super.didUpdateWidget(oldWidget);
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
        child: LayoutBuilder(builder: (context, constraints) {
          final cardHeight = constraints.maxHeight;
          final centerIconSize = cardHeight * _kCenterIconSizeRatio;
          final cornerRankFontSize = cardHeight * _kCornerRankFontSizeRatio;
          final cornerIconSize = cardHeight * _kCornerIconSizeRatio;

          return Container(
            margin: _kCardMargin,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_kCardBorderRadius),
              border: Border.all(color: Colors.black87, width: _kCardBorderWidth),
              boxShadow: const [
                BoxShadow(
                  blurRadius: _kShadowBlurRadius,
                  offset: _kShadowOffset,
                  color: Colors.black26,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: _kCornerPadding,
                  left: _kCornerPadding,
                  child: _CornerLabel(
                    rank: widget.card.rank.shortName,
                    icon: widget.card.suit.icon,
                    color: color,
                    rankFontSize: cornerRankFontSize,
                    iconSize: cornerIconSize,
                  ),
                ),
                Positioned(
                  bottom: _kCornerPadding,
                  right: _kCornerPadding,
                  child: Transform.rotate(
                    angle: math.pi,
                    child: _CornerLabel(
                      rank: widget.card.rank.shortName,
                      icon: widget.card.suit.icon,
                      color: color,
                      rankFontSize: cornerRankFontSize,
                      iconSize: cornerIconSize,
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    widget.card.suit.icon,
                    size: centerIconSize,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CornerLabel extends StatelessWidget {
  const _CornerLabel({
    required this.rank,
    required this.icon,
    required this.color,
    required this.rankFontSize,
    required this.iconSize,
  });

  final String rank;
  final IconData icon;
  final Color color;
  final double rankFontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          rank,
          style: TextStyle(
            fontSize: rankFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Icon(icon, size: iconSize, color: color),
      ],
    );
  }
}
