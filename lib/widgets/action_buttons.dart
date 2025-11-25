import 'package:blackjack/models/board.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:flutter/material.dart';

/// A widget that displays the appropriate action buttons based on the game state.
class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key, required this.presenter});

  final HomePagePresenter presenter;

  @override
  Widget build(BuildContext context) {
    final board = presenter.board;

    switch (board.state) {
      case GameState.betting:
        return const SizedBox.shrink();
      case GameState.offeringInsurance:
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            ElevatedButton(
              onPressed:
                  board.canTakeInsurance ? presenter.takeInsurance : null,
              child: const Text('Take Insurance'),
            ),
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
            ElevatedButton(
              onPressed: presenter.stand,
              child: const Text('Stand'),
            ),
          ],
        );
      case GameState.roundOver:
        return ElevatedButton(
          onPressed: presenter.nextRound,
          child: const Text('Next Round'),
        );
    }
  }
}
