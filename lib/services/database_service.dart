import 'package:blackjack/main.dart';
import 'package:flutter/foundation.dart';

/// Ce service centralise TOUS les appels à la base de données Supabase (sauf l'auth).
/// C'est notre "Repository".
class DatabaseService {
  /// Crée un profil utilisateur dans la table `profiles`.
  Future<void> createProfile(String userId, String username) async {
    final updates = {
      'id': userId,
      'username': username,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await supabase.from('profiles').upsert(updates);
    } catch (e) {
      debugPrint('DatabaseService (createProfile) Error: $e');
      rethrow;
    }
  }

  /// Récupère le profil d'un utilisateur par son ID.
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return data;
    } catch (e) {
      debugPrint('DatabaseService (getProfile) Error: $e');
      return null;
    }
  }

  // --- On ajoutera ici les autres fonctions --- 
  // Future<void> updateUserWallet(String userId, double newAmount) async { ... }
  // ... etc.
}
