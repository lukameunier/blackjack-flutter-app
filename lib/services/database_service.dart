import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createProfile(String userId, String username) async {
    final updates = {
      'id': userId,
      'username': username,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await _client.from('profiles').upsert(updates);
    } catch (e) {
      debugPrint('DatabaseService (createProfile) Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return data;
    } catch (e) {
      debugPrint('DatabaseService (getProfile) Error: $e');
      return null;
    }
  }

  Future<double> getUserWallet(String userId) async {
    try {
      final profile = await getProfile(userId);

      if (profile == null) {
        throw Exception('Profile not found for user $userId');
      }

      final wallet = profile['wallet'];
      if (wallet == null) {
        throw Exception('Wallet is missing in profile (DB inconsistency)');
      }

      return (wallet as num).toDouble();
    } catch (e) {
      debugPrint('DatabaseService (getUserWallet) Error: $e');
      rethrow;
    }
  }

  Future<void> updateUserWallet(String userId, double newAmount) async {
    try {
      await _client
          .from('profiles')
          .update({'wallet': newAmount})
          .eq('id', userId);
    } catch (e) {
      debugPrint('DatabaseService (updateUserWallet) Error: $e');
      rethrow;
    }
  }
}
