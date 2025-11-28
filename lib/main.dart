import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:blackjack/services/auth_service.dart';
import 'package:blackjack/supabase_credentials.dart';
import 'package:blackjack/widgets/animated_wallet.dart';
import 'package:blackjack/widgets/login_screen.dart';
import 'package:blackjack/widgets/playing_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Blackjack 3D',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            // Si l’utilisateur est connecté → on va sur le jeu
            if (authService.isLoggedIn()) {
              return const GameScreen();
            }
            // Sinon → écran de login
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // On crée le HomePagePresenter uniquement pour l’écran de jeu
    return ChangeNotifierProvider<HomePagePresenter>(
      create: (_) => HomePagePresenter(),
      child: const _GameScaffold(),
    );
  }
}

class _GameScaffold extends StatelessWidget {
  const _GameScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final presenter = context.watch<HomePagePresenter>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blackjack 3D'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              // On affiche le wallet actuel du joueur
              child: AnimatedWallet(amount: presenter.board.player.wallet),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: PlayingView(presenter: presenter),
    );
  }
}
