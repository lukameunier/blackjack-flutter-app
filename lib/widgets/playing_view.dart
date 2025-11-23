import 'package:blackjack/models/board.dart';
import 'package:blackjack/models/hand.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:blackjack/widgets/card_view.dart';
import 'package:flutter/material.dart';

class PlayingView extends StatelessWidget {
  const PlayingView({super.key, required this.presenter});

  final HomePagePresenter presenter;

  @override
  Widget build(BuildContext context) {
    final board = presenter.board;
    return Column(
      children: [
        _buildHandView(context, 'Dealer', board.dealer.activeHand),
        const SizedBox(height: 24),
        ...board.player.hands.map((hand) {
          final handIndex = board.player.hands.indexOf(hand);
          final isActive =
              handIndex == board.player.activeHandIndex &&
              board.state == GameState.playing;
          return _buildHandView(
            context,
            'Player Hand ${handIndex + 1}',
            hand,
            isActive: isActive,
          );
        }),
        const Spacer(),
        if (board.state == GameState.offeringInsurance)
          Text(
            'Dealer has an Ace. Do you want insurance?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        if (board.state == GameState.roundOver) _buildResultsView(context),
        const SizedBox(height: 24),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildResultsView(BuildContext context) {
    return Column(
      children: presenter.board.player.hands.map((hand) {
        final result = presenter.board.getResultForHand(hand);
        final payoutInfo = result.payout > 0
            ? (result.payout == hand.bet
                ? ' (Push)'
                : ' (+${(result.payout - hand.bet).toStringAsFixed(2)})')
            : ' (-${hand.bet.toStringAsFixed(2)})';
        return Text(
          '${result.message}$payoutInfo',
          style: Theme.of(context).textTheme.headlineSmall,
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final board = presenter.board;
    switch (board.state) {
      case GameState.betting:
        return const SizedBox.shrink(); // Should not happen in this view
      case GameState.offeringInsurance:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: board.canTakeInsurance ? presenter.takeInsurance : null,
              child: const Text('Take Insurance'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: presenter.declineInsurance,
              child: const Text('No, Thanks'),
            ),
          ],
        );
      case GameState.playing:
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            ElevatedButton(onPressed: presenter.hit, child: const Text('Hit')),
            ElevatedButton(
              onPressed: board.canDoubleDown ? presenter.doubleDown : null,
              child: const Text('Double'),
            ),
            ElevatedButton(
              onPressed: board.canSplit ? presenter.split : null,
              child: const Text('Split'),
            ),
            ElevatedButton(
              onPressed: board.canSurrender ? presenter.surrender : null,
              child: const Text('Surrender'),
            ),
            ElevatedButton(onPressed: presenter.stand, child: const Text('Stand')),
          ],
        );
      case GameState.roundOver:
        return ElevatedButton(
          onPressed: presenter.nextRound,
          child: const Text('Next Round'),
        );
    }
  }

  Widget _buildHandView(
    BuildContext context,
    String title,
    Hand hand, {
    bool isActive = false,
  }) {
    return Container(
      decoration: isActive
          ? BoxDecoration(
              border: Border.all(
                color: Colors.deepPurple.withAlpha(128),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (Score: ${hand.score}, Bet: \$${hand.bet.toStringAsFixed(0)})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: hand.cards.map((card) => CardView(card: card)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
