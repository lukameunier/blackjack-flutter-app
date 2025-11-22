import 'package:blackjack/models/board.dart';
import 'package:blackjack/models/player.dart';
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

class _MyHomePageState extends State<MyHomePage> {
  late Board _board;

  @override
  void initState() {
    super.initState();
    _board = Board();
  }

  void _newGame() {
    setState(() {
      _board.newGame();
    });
  }

  void _hit() {
    setState(() {
      _board.hit();
    });
  }

  void _stand() {
    setState(() {
      _board.stand();
    });
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
            _buildHand('Dealer', _board.dealer, hideFirstCard: !_board.isRoundOver),
            const SizedBox(height: 24),
            _buildHand('Player', _board.player),
            const Spacer(),
            if (_board.isRoundOver)
              Text(
                _board.getWinner(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _board.isRoundOver ? null : _hit,
                  child: const Text('Hit'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _board.isRoundOver ? null : _stand,
                  child: const Text('Stand'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newGame,
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
