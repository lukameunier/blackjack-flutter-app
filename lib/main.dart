import 'package:blackjack/models/card.dart' as playing_card;
import 'package:blackjack/models/player.dart';
import 'package:blackjack/models/rank.dart';
import 'package:flutter/material.dart';
import 'models/deck.dart';

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
  late Deck _deck;
  late Player _player;
  late Player _dealer;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _deck = Deck();
      _player = Player();
      _dealer = Player();

      // Deal initial cards
      _player.addCard(_deck.drawCard());
      _dealer.addCard(_deck.drawCard());
      _player.addCard(_deck.drawCard());
      _dealer.addCard(_deck.drawCard());
    });
  }

  void _hit() {
    if (_player.score < 21) {
      setState(() {
        _player.addCard(_deck.drawCard());
      });
    }
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
            _buildHand('Dealer', _dealer),
            const SizedBox(height: 24),
            _buildHand('Player', _player),
            const Spacer(),
            if (_player.score >= 21)
              Text(
                _player.score > 21 ? 'Bust!' : 'Blackjack!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _player.score < 21 ? _hit : null, child: const Text('Hit')),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: () {}, child: const Text('Stand')),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startGame,
        tooltip: 'New Game',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHand(String title, Player player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (Score: ${player.score})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: player.hand.map((card) => CardView(card: card)).toList(),
          ),
        ),
      ],
    );
  }
}

class CardView extends StatelessWidget {
  const CardView({super.key, required this.card});

  final playing_card.Card card;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(right: 8),
      child: SizedBox(
        width: 80,
        height: 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(card.rank.displayValue.toString(), style: Theme.of(context).textTheme.titleLarge),
            Icon(card.suit.icon, size: 30),
          ],
        ),
      ),
    );
  }
}
