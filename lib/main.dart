import 'package:blackjack/presenters/home_page_presenter.dart';
import 'package:blackjack/services/auth_service.dart';
import 'package:blackjack/services/database_service.dart';
import 'package:blackjack/supabase_credentials.dart';
import 'package:blackjack/widgets/animated_wallet.dart';
import 'package:blackjack/widgets/login_screen.dart';
import 'package:blackjack/widgets/playing_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Blackjack',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthStateListener(),
      ),
    );
  }
}

class AuthStateListener extends StatelessWidget {
  const AuthStateListener({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) {
            return FutureBuilder<Map<String, dynamic>?>(
              future: Provider.of<AuthService>(context, listen: false)
                  .getCurrentProfile(),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                final userName = profileSnapshot.data?['username'] ?? 'Player';
                return MyHomePage(userName: userName);
              },
            );
          }
        }
        return const LoginScreen();
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
    // Ici, on pourrait charger le portefeuille du joueur depuis Supabase
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

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
                  // TODO: Connecter au portefeuille Supabase
                  return AnimatedWallet(amount: _presenter.board.player.wallet);
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _presenter,
        builder: (context, child) {
          return PlayingView(presenter: _presenter);
        },
      ),
    );
  }
}
