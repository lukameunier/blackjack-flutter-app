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

    if (board.state == GameState.betting || board.state == GameState.roundOver) {
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

    if (board.dealer.activeHand.cards.isEmpty && _displayedDealerHand.cards.isEmpty) {
      return true;
    }

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
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF3A8C3A), Color(0xFF2C6B2C)],
                radius: 0.8,
              ),
            ),
            child: _buildGameBoard(),
          ),
        ),
        Container(
          height: 180, // Fixed height for the footer
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Center(
              child: ActionButtons(presenter: widget.presenter),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    final board = widget.presenter.board;
    final showHands = board.state != GameState.betting;

    if (!showHands) {
      return const Center(
          // The betting UI is now handled in ActionButtons, so this space is for the table background.
          );
    }

    return Stack(
      children: [
        // Dealer's hand at the top
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: HandView(
              title: 'Dealer',
              cards: _displayedDealerHand.cards,
              score: _displayedDealerHand.score,
              animateCards: board.state != GameState.roundOver,
            ),
          ),
        ),

        // Player's hands at the bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_displayedPlayerHands.length, (index) {
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
                  animateCards: board.state != GameState.roundOver,
                );
              }),
            ),
          ),
        ),

        // Messages and results in the center
        Center(
          child: (board.state == GameState.offeringInsurance || board.state == GameState.roundOver)
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (board.state == GameState.offeringInsurance)
                        Text(
                          'Dealer has an Ace. Do you want insurance?',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      if (board.state == GameState.roundOver) _buildResultsView(context),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildResultsView(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.presenter.board.player.hands.map((hand) {
        final result = widget.presenter.board.getResultForHand(hand);
        final payoutInfo = result.payout > 0
            ? (result.payout == hand.bet
                ? ' (Push)'
                : ' (+${(result.payout - hand.bet).toStringAsFixed(2)})')
            : ' (-${hand.bet.toStringAsFixed(2)})';
        return Text(
          '${result.message}$payoutInfo',
          style: textStyle,
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }
}
