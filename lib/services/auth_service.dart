import 'package:blackjack/main.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour gérer l'authentification et les profils utilisateurs avec Supabase.
class AuthService with ChangeNotifier {
  /// Tente de s'inscrire (signUp) avec un email et un mot de passe.
  /// Si l'inscription réussit, un profil est créé dans la table `profiles`.
  Future<void> signUp(String email, String password, String username) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Inscription réussie, on crée le profil
        await _createProfile(response.user!.id, username);
      } else {
        // Gérer le cas où l'utilisateur existe déjà mais n'est pas confirmé
        throw const AuthException(
            'User already exists. Please check your email to confirm your account.');
      }
    } on AuthException catch (e) {
      // Gérer les erreurs spécifiques à Supabase Auth
      debugPrint('AuthService (signUp) Error: ${e.message}');
      rethrow;
    } catch (e) {
      // Gérer les autres erreurs (ex: réseau)
      debugPrint('AuthService (signUp) General Error: $e');
      rethrow;
    }
  }

  /// Crée un enregistrement dans la table `profiles`.
  Future<void> _createProfile(String userId, String username) async {
    final updates = {
      'id': userId,
      'username': username,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await supabase.from('profiles').upsert(updates);
    } catch (e) {
      debugPrint('AuthService (_createProfile) Error: $e');
      rethrow;
    }
  }

  /// Tente de se connecter (signIn) avec un email et un mot de passe.
  Future<void> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      debugPrint('AuthService (signIn) Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService (signIn) General Error: $e');
      rethrow;
    }
  }

  /// Déconnecte l'utilisateur.
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('AuthService (signOut) Error: $e');
      rethrow;
    }
  }

  /// Récupère le profil de l'utilisateur actuellement connecté.
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await supabase
          .from('profiles')
          .select() // Syntaxe corrigée et définitive
          .eq('id', user.id)
          .single();
      return data;
    } catch (e) {
      debugPrint('AuthService (getCurrentProfile) Error: $e');
      return null;
    }
  }

  /// Met à jour le nom d'utilisateur.
  Future<void> updateUsername(String newUsername) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw const AuthException('User not logged in');

    try {
      await supabase
          .from('profiles')
          .update({'username': newUsername}).eq('id', user.id);
      notifyListeners(); // Notifie les écouteurs si le nom d'utilisateur change
    } catch (e) {
      debugPrint('AuthService (updateUsername) Error: $e');
      rethrow;
    }
  }

  /// Vérifie si un utilisateur est actuellement connecté.
  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }
}
