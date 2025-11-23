import 'package:flutter/material.dart';

/// A widget that animates the transition of the wallet amount.
class AnimatedWallet extends StatefulWidget {
  final double amount;

  const AnimatedWallet({super.key, required this.amount});

  @override
  State<AnimatedWallet> createState() => _AnimatedWalletState();
}

class _AnimatedWalletState extends State<AnimatedWallet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    // Initializes the animation with the starting value
    _animation =
        Tween<double>(begin: widget.amount, end: widget.amount).animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedWallet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the amount changes, create a new animation from the old to the new amount
    if (oldWidget.amount != widget.amount) {
      _animation = Tween<double>(
        begin: oldWidget.amount,
        end: widget.amount,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      // Restart the animation
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // The text is rebuilt on every frame of the animation
        return Text(
          '\$${_animation.value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge,
        );
      },
    );
  }
}
