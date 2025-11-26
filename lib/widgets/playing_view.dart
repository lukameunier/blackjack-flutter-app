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

    // Si la partie n'a pas commencé, on considère l'état comme synchronisé
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
    final board = widget.presenter.board;

    // Si on est en phase de mise, on n'affiche que les boutons.
    // Sinon, on affiche toute la table de jeu.
    final bool showHands = board.state != GameState.betting;

    return Column(
      children: [
        // Les mains ne sont visibles que si la partie a commencé
        if (showHands)
          HandView(
            title: 'Dealer',
            cards: _displayedDealerHand.cards,
            score: _displayedDealerHand.score,
            animateCards: board.state != GameState.roundOver,
          ),
        if (showHands) const SizedBox(height: 24),

        // On utilise un Expanded pour que la vue des mains du joueur puisse scroller
        // si elle est trop grande (ex: après plusieurs splits)
        if (showHands)
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
                    animateCards: board.state != GameState.roundOver,
                  );
                }),
              ),
            ),
          ),

        // Le Spacer centre les boutons de mise quand les mains ne sont pas visibles
        if (!showHands) const Spacer(),

        // Messages et résultats
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

        // Les boutons d'action sont toujours présents, mais leur contenu change
        ActionButtons(presenter: widget.presenter),

        if (!showHands) const Spacer(),

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
