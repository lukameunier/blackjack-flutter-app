import 'package:blackjack/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  WalletService({DatabaseService? databaseService})
    : _dbService = databaseService ?? DatabaseService();

  final SupabaseClient _client = Supabase.instance.client;
  final DatabaseService _dbService;

  Future<double> loadWallet() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Cannot load wallet: no authenticated user');
    }

    return _dbService.getUserWallet(user.id);
  }

  Future<void> saveWallet(double amount) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Cannot save wallet: no authenticated user');
    }

    await _dbService.updateUserWallet(user.id, amount);
  }
}
