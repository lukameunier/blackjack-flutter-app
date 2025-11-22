import 'package:flutter/material.dart';

class BettingView extends StatelessWidget {
  const BettingView({
    super.key,
    required this.playerWallet,
    required this.onBetPlaced,
  });

  final double playerWallet;
  final void Function(double) onBetPlaced;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Place your bet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [10.0, 25.0, 50.0, 100.0].map((amount) {
              return ElevatedButton(
                onPressed: playerWallet >= amount
                    ? () => onBetPlaced(amount)
                    : null,
                child: Text('\$$amount'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
