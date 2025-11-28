import 'package:blackjack/main.dart';
import 'package:blackjack/services/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  Future<void> signUp(String email, String password, String username) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // On utilise maintenant le DatabaseService pour créer le profil
        await _dbService.createProfile(response.user!.id, username);
      } else {
        throw const AuthException(
            'User already exists or something went wrong.');
      }
    } on AuthException catch (e) {
      debugPrint('AuthService (signUp) Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService (signUp) General Error: $e');
      rethrow;
    }
  }

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

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('AuthService (signOut) Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // On utilise maintenant le DatabaseService pour récupérer le profil
    return _dbService.getProfile(user.id);
  }

  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  // La fonction updateUsername sera aussi déplacée dans le DatabaseService plus tard
}
