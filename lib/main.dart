import 'package:blackjack/models/board.dart';
import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:blackjack/widgets/animated_wallet.dart';
import 'package:blackjack/widgets/betting_view.dart';
import 'package:blackjack/widgets/playing_view.dart';
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

class _MyHomePageState extends State<MyHomePage> {
  late HomePagePresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = HomePagePresenter();
    _presenter.init();
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
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
              child: AnimatedBuilder(
                animation: _presenter,
                builder: (context, child) {
                  return AnimatedWallet(amount: _presenter.board.player.wallet);
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _presenter,
          builder: (context, child) {
            final board = _presenter.board;
            switch (board.state) {
              case GameState.betting:
                return BettingView(
                  playerWallet: board.player.wallet,
                  onBetPlaced: (amount) => _presenter.placeBetAndDeal(amount),
                );
              case GameState.playing:
              case GameState.offeringInsurance:
              case GameState.roundOver:
                return PlayingView(presenter: _presenter);
            }
          },
        ),
      ),
    );
  }
}
