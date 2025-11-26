import 'package:blackjack/models/board.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:flutter/material.dart';

/// A widget that displays the appropriate action buttons based on the game state.
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.presenter});

  final HomePagePresenter presenter;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200), // Reduced from 300ms
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: presenter.board.state == GameState.betting
          ? _buildBettingView(context, presenter.board)
          : _buildGameActions(context, presenter.board),
    );
  }

  Widget _buildBettingView(BuildContext context, Board board) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.amber[700], // Golden color for bets
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );

    return Column(
      key: const ValueKey('betting'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Place Your Bet',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10.0,
          runSpacing: 10.0,
          children: [10.0, 25.0, 50.0, 100.0, 200.0, 500.0].map((amount) {
            return ElevatedButton(
              style: buttonStyle,
              onPressed: board.player.wallet >= amount
                  ? () => presenter.placeBetAndDeal(amount)
                  : null,
              child: Text(
                '\$$amount',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGameActions(BuildContext context, Board board) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blueGrey[800], // Dark, classy color
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blueGrey[600]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );

    List<Widget> buttons;

    switch (board.state) {
      case GameState.offeringInsurance:
        buttons = [
          ElevatedButton(
            style: buttonStyle,
            onPressed: board.canTakeInsurance ? presenter.takeInsurance : null,
            child: const Text('Take Insurance'),
          ),
          ElevatedButton(
            style: buttonStyle,
            onPressed: presenter.declineInsurance,
            child: const Text('No, Thanks'),
          ),
        ];
        break;
      case GameState.playing:
        buttons = [
          ElevatedButton(style: buttonStyle, onPressed: presenter.hit, child: const Text('Hit')),
          ElevatedButton(
            style: buttonStyle,
            onPressed: board.canDoubleDown ? presenter.doubleDown : null,
            child: const Text('Double'),
          ),
          ElevatedButton(
            style: buttonStyle,
            onPressed: board.canSplit ? presenter.split : null,
            child: const Text('Split'),
          ),
          ElevatedButton(
            style: buttonStyle,
            onPressed: board.canSurrender ? presenter.surrender : null,
            child: const Text('Surrender'),
          ),
          ElevatedButton(style: buttonStyle, onPressed: presenter.stand, child: const Text('Stand')),
        ];
        break;
      case GameState.roundOver:
        buttons = [
          ElevatedButton(
            style: buttonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(Colors.green[700]),
            ),
            onPressed: presenter.nextRound,
            child: const Text('Next Round'),
          ),
        ];
        break;
      default:
        buttons = [];
    }

    return Wrap(
      key: const ValueKey('actions'),
      alignment: WrapAlignment.center,
      spacing: 12.0,
      runSpacing: 12.0,
      children: buttons,
    );
  }
}
