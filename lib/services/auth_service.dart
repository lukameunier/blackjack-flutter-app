import 'package:blackjack/services/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService with ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  final DatabaseService _dbService = DatabaseService();

  Future<void> signUp(String email, String password, String username) async {
    try {
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      final user = response.user;
      if (user == null) {
        throw AuthException('No user returned by Supabase');
      }

      // Création du profil lié à l’utilisateur
      await _dbService.createProfile(user.id, username);

      notifyListeners();
    } on AuthException catch (e) {
      debugPrint('AuthService (signUp) AuthException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService (signUp) Error: $e');
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);

      notifyListeners();
    } on AuthException catch (e) {
      debugPrint('AuthService (signIn) AuthException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService (signIn) Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('AuthService (signOut) Error: $e');
    } finally {
      // Dans tous les cas, on notifie pour que l’UI repasse sur LoginScreen
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return _dbService.getProfile(user.id);
  }

  bool isLoggedIn() {
    return _client.auth.currentUser != null;
  }
}
