import 'package:blackjack/models/board.dart';
import 'package:blackjack/models/hand.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:blackjack/views/card_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blackjack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Blackjack'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements HomePageView {
  late HomePagePresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = HomePagePresenter(this);
  }

  @override
  void refresh() {
    setState(() {});
  }

  @override
  void showReshuffleMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The dealer is shuffling a new shoe...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Wallet: \$${_presenter.board.player.wallet.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildGameView(),
      ),
    );
  }

  Widget _buildGameView() {
    switch (_presenter.board.state) {
      case GameState.betting:
        return _buildBettingView();
      case GameState.playing:
      case GameState.offeringInsurance:
      case GameState.roundOver:
        return _buildPlayingView();
    }
  }

  Widget _buildBettingView() {
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
                onPressed: _presenter.board.player.wallet >= amount
                    ? () => _presenter.placeBetAndDeal(amount)
                    : null,
                child: Text('\$$amount'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingView() {
    return Column(
      children: [
        _buildHandView('Dealer', _presenter.board.dealer.activeHand),
        const SizedBox(height: 24),
        ..._presenter.board.player.hands.map((hand) {
          final handIndex = _presenter.board.player.hands.indexOf(hand);
          final isActive =
              handIndex == _presenter.board.player.activeHandIndex &&
              _presenter.board.state == GameState.playing;
          return _buildHandView(
            'Player Hand ${handIndex + 1}',
            hand,
            isActive: isActive,
          );
        }),
        const Spacer(),
        if (_presenter.board.state == GameState.offeringInsurance)
          Text(
            'Dealer has an Ace. Do you want insurance?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        if (_presenter.board.state == GameState.roundOver) _buildResultsView(),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildResultsView() {
    return Column(
      children: _presenter.board.player.hands.map((hand) {
        final result = _presenter.board.getResultForHand(hand);
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

  Widget _buildActionButtons() {
    final board = _presenter.board;
    switch (board.state) {
      case GameState.betting:
        return const SizedBox.shrink(); // No buttons during betting
      case GameState.offeringInsurance:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: board.canTakeInsurance
                  ? _presenter.takeInsurance
                  : null,
              child: const Text('Take Insurance'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _presenter.declineInsurance,
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
            ElevatedButton(onPressed: _presenter.hit, child: const Text('Hit')),
            ElevatedButton(
              onPressed: board.canDoubleDown ? _presenter.doubleDown : null,
              child: const Text('Double'),
            ),
            ElevatedButton(
              onPressed: board.canSplit ? _presenter.split : null,
              child: const Text('Split'),
            ),
            ElevatedButton(
              onPressed: board.canSurrender ? _presenter.surrender : null,
              child: const Text('Surrender'),
            ),
            ElevatedButton(
              onPressed: _presenter.stand,
              child: const Text('Stand'),
            ),
          ],
        );
      case GameState.roundOver:
        return ElevatedButton(
          onPressed: _presenter.nextRound,
          child: const Text('Next Round'),
        );
    }
  }

  Widget _buildHandView(String title, Hand hand, {bool isActive = false}) {
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
