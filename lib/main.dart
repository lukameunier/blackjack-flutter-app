import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:blackjack/widgets/animated_wallet.dart';
import 'package:blackjack/widgets/login_screen.dart';
import 'package:blackjack/widgets/playing_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? userName = prefs.getString('userName');

  runApp(MyApp(isLoggedIn: isLoggedIn, userName: userName));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.userName,
  });

  final bool isLoggedIn;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blackjack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn && userName != null
          ? MyHomePage(userName: userName!)
          : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.userName});

  final String userName;

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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userName');

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Welcome, ${widget.userName}'),
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _presenter,
          builder: (context, child) {
            // On utilise maintenant toujours PlayingView, qui s'adapte à l'état du jeu.
            return PlayingView(presenter: _presenter);
          },
        ),
      ),
    );
  }
}
