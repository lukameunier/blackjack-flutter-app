import 'package:blackjack/models/card.dart' as playing_card;
import 'package:blackjack/models/dealer.dart';
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
  late Dealer _dealer;
  bool _playerStands = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _deck = Deck();
      _player = Player();
      _dealer = Dealer();
      _playerStands = false;

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

  void _stand() {
    setState(() {
      _playerStands = true;
      _dealer.playTurn(_deck);
    });
  }

  String _getWinner() {
    if (_player.score > 21) return 'You Bust! Dealer Wins';
    if (_dealer.score > 21) return 'Dealer Busts! You Win!';
    if (_player.score > _dealer.score) return 'You Win!';
    if (_dealer.score > _player.score) return 'Dealer Wins';
    return 'Push (Tie)';
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
            _buildHand('Dealer', _dealer, hideFirstCard: !_playerStands),
            const SizedBox(height: 24),
            _buildHand('Player', _player),
            const Spacer(),
            if (_playerStands || _player.score >= 21)
              Text(
                _getWinner(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _playerStands || _player.score >= 21 ? null : _hit,
                  child: const Text('Hit'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _playerStands || _player.score >= 21 ? null : _stand,
                  child: const Text('Stand'),
                ),
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

class HiddenCardView extends StatelessWidget {
  const HiddenCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 110,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
      ),
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
