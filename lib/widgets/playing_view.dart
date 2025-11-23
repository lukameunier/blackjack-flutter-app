// Forcing rebuild
import 'dart:async';
import 'package:blackjack/models/board.dart';
import 'package:blackjack/models/card.dart' as model_card;
import 'package:blackjack/models/hand.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:blackjack/widgets/card_view.dart';
import 'package:flutter/material.dart';

class _DisplayedHand {
  final List<model_card.Card> cards = [];
  int score = 0;
}

class PlayingView extends StatefulWidget {
  const PlayingView({super.key, required this.presenter});

  final HomePagePresenter presenter;

  @override
  State<PlayingView> createState() => _PlayingViewState();
}

class _PlayingViewState extends State<PlayingView> {
  final _displayedDealerHand = _DisplayedHand();
  final _displayedPlayerHands = <_DisplayedHand>[];

  final _animationQueue = <Function>[];
  bool _isProcessingQueue = false;

  @override
  void initState() {
    super.initState();
    _syncAndCheckForNewCards();
  }

  @override
  void didUpdateWidget(PlayingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAndCheckForNewCards();
  }

  void _syncAndCheckForNewCards() {
    final board = widget.presenter.board;

    if (board.state == GameState.roundOver) {
      if (!_isStateSynced()) {
        _syncStateWithoutAnimation();
      }
      _animationQueue.clear();
      return;
    }

    _addCardsToQueue(board.dealer.activeHand, _displayedDealerHand);

    while (_displayedPlayerHands.length < board.player.hands.length) {
      _displayedPlayerHands.add(_DisplayedHand());
    }
    for (int i = 0; i < board.player.hands.length; i++) {
      _addCardsToQueue(board.player.hands[i], _displayedPlayerHands[i]);
    }

    _processAnimationQueue();
  }

  void _addCardsToQueue(Hand sourceHand, _DisplayedHand displayedHand) {
    final displayedCardsSet = displayedHand.cards.toSet();
    for (final card in sourceHand.cards) {
      if (!displayedCardsSet.contains(card)) {
        final scoreOfHandWhenCardIsDealt = sourceHand.score;
        _animationQueue.add(() async {
          if (!mounted) return;
          setState(() {
            displayedHand.cards.add(card);
          });
          await Future.delayed(const Duration(milliseconds: 200));
          if (!mounted) return;
          setState(() {
            displayedHand.score = scoreOfHandWhenCardIsDealt;
          });
        });
      }
    }
  }

  Future<void> _processAnimationQueue() async {
    if (_isProcessingQueue || _animationQueue.isEmpty) return;

    _isProcessingQueue = true;
    while (_animationQueue.isNotEmpty) {
      final task = _animationQueue.removeAt(0);
      task();
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) break;
    }
    _isProcessingQueue = false;
  }

  bool _isStateSynced() {
    final board = widget.presenter.board;
    if (board.dealer.activeHand.cards.length != _displayedDealerHand.cards.length) return false;
    if (board.player.hands.length != _displayedPlayerHands.length) return false;
    for (int i = 0; i < board.player.hands.length; i++) {
      if (board.player.hands[i].cards.length != _displayedPlayerHands[i].cards.length) return false;
    }
    return true;
  }

  void _syncStateWithoutAnimation() {
    setState(() {
      final board = widget.presenter.board;

      _displayedDealerHand.cards.clear();
      _displayedDealerHand.cards.addAll(board.dealer.activeHand.cards);
      _displayedDealerHand.score = board.dealer.activeHand.score;

      while (_displayedPlayerHands.length < board.player.hands.length) {
        _displayedPlayerHands.add(_DisplayedHand());
      }
      while (_displayedPlayerHands.length > board.player.hands.length) {
        _displayedPlayerHands.removeLast();
      }

      for (int i = 0; i < board.player.hands.length; i++) {
        final sourceHand = board.player.hands[i];
        final displayedHand = _displayedPlayerHands[i];

        displayedHand.cards.clear();
        displayedHand.cards.addAll(sourceHand.cards);
        displayedHand.score = sourceHand.score;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.presenter.board;
    return Column(
      children: [
        _buildHandView(
          context,
          'Dealer',
          _displayedDealerHand,
        ),
        const SizedBox(height: 24),
        ...List.generate(board.player.hands.length, (index) {
          final handModel = board.player.hands[index];
          final displayedHand = _displayedPlayerHands[index];
          final isActive = index == board.player.activeHandIndex && board.state == GameState.playing;
          return _buildHandView(
            context,
            'Player Hand ${index + 1}',
            displayedHand,
            bet: handModel.bet,
            isActive: isActive,
            result: board.state == GameState.roundOver
                ? board.getResultForHand(handModel)
                : null,
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

  Widget _buildHandView(
    BuildContext context,
    String title,
    _DisplayedHand hand, {
    double? bet,
    bool isActive = false,
    GameResult? result,
  }) {
    final betText = bet != null ? ', Bet: \$${bet.toStringAsFixed(0)}' : '';
    final bool shouldAnimate = widget.presenter.board.state != GameState.roundOver;
    
    Color? borderColor;
    if (result != null) {
      if (result.payout > (bet ?? 0)) {
        borderColor = Colors.green.withAlpha(200); // Victoire
      } else if (result.payout == (bet ?? 0)) {
        borderColor = Colors.grey.withAlpha(200); // Égalité
      } else {
        borderColor = Colors.red.withAlpha(200); // Défaite
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? (isActive ? Colors.deepPurple.withAlpha(128) : Colors.transparent),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title (Score: ${hand.score}$betText)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: hand.cards.map((card) {
                return CardView(
                  key: ObjectKey(card),
                  card: card,
                  animateOnBuild: shouldAnimate,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(BuildContext context) {
    return Column(
      children: widget.presenter.board.player.hands.map((hand) {
        final result = widget.presenter.board.getResultForHand(hand);
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
    final board = widget.presenter.board;
    switch (board.state) {
      case GameState.betting:
        return const SizedBox.shrink();
      case GameState.offeringInsurance:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: board.canTakeInsurance ? widget.presenter.takeInsurance : null,
              child: const Text('Take Insurance'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: widget.presenter.declineInsurance,
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
            ElevatedButton(onPressed: widget.presenter.hit, child: const Text('Hit')),
            ElevatedButton(
              onPressed: board.canDoubleDown ? widget.presenter.doubleDown : null,
              child: const Text('Double'),
            ),
            ElevatedButton(
              onPressed: board.canSplit ? widget.presenter.split : null,
              child: const Text('Split'),
            ),
            ElevatedButton(
              onPressed: board.canSurrender ? widget.presenter.surrender : null,
              child: const Text('Surrender'),
            ),
            ElevatedButton(onPressed: widget.presenter.stand, child: const Text('Stand')),
          ],
        );
      case GameState.roundOver:
        return ElevatedButton(
          onPressed: widget.presenter.nextRound,
          child: const Text('Next Round'),
        );
    }
  }
}
