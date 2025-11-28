import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service qui gère TOUTES les interactions avec la base Supabase
/// (hors authentification).
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
          .maybeSingle(); // null si aucun profil

      return data;
    } catch (e) {
      debugPrint('DatabaseService (getProfile) Error: $e');
      return null;
    }
  }

  // Tu pourras rajouter ici d’autres méthodes plus tard :
  // - updateUserWallet
  // - historique des parties
  // - etc.
}
