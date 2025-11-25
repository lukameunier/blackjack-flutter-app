import 'dart:async';
import 'package:blackjack/models/board.dart';
import 'package:blackjack/models/card.dart' as model_card;
import 'package:blackjack/models/hand.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:blackjack/widgets/action_buttons.dart';
import 'package:blackjack/widgets/hand_view.dart';
import 'package:flutter/material.dart';

// Classe interne pour gérer l'état d'affichage d'une main
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
    final bool shouldAnimateCards = board.state != GameState.roundOver;

    return Column(
      children: [
        HandView(
          title: 'Dealer',
          cards: _displayedDealerHand.cards,
          score: _displayedDealerHand.score,
          animateCards: shouldAnimateCards,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(board.player.hands.length, (index) {
                final handModel = board.player.hands[index];
                final displayedHand = _displayedPlayerHands[index];
                final isActive =
                    index == board.player.activeHandIndex && board.state == GameState.playing;
                return HandView(
                  title: 'Player Hand ${index + 1}',
                  cards: displayedHand.cards,
                  score: displayedHand.score,
                  bet: handModel.bet,
                  isActive: isActive,
                  result: board.state == GameState.roundOver
                      ? board.getResultForHand(handModel)
                      : null,
                  animateCards: shouldAnimateCards,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (board.state == GameState.offeringInsurance)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Dealer has an Ace. Do you want insurance?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        if (board.state == GameState.roundOver)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildResultsView(context),
          ),
        ActionButtons(presenter: widget.presenter),
        const SizedBox(height: 16),
      ],
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
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }
}
