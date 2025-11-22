import 'package:blackjack/models/player.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHand('Dealer', _presenter.board.dealer, hideFirstCard: !_presenter.board.isRoundOver),
            const SizedBox(height: 24),
            _buildHand('Player', _presenter.board.player),
            const Spacer(),
            if (_presenter.board.isRoundOver)
              Text(
                _presenter.board.getWinner(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _presenter.board.isRoundOver ? null : _presenter.hit,
                  child: const Text('Hit'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _presenter.board.canDoubleDown ? _presenter.doubleDown : null,
                  child: const Text('Double'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _presenter.board.isRoundOver ? null : _presenter.stand,
                  child: const Text('Stand'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _presenter.newGame,
        tooltip: 'New Game',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHand(String title, Player player, {bool hideFirstCard = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (Score: ${hideFirstCard ? '??' : player.score})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(player.hand.length, (index) {
              if (index == 0 && hideFirstCard) {
                return const HiddenCardView();
              }
              return CardView(card: player.hand[index]);
            }),
          ),
        ),
      ],
    );
  }
}
