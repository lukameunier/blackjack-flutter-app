import 'package:shared_preferences/shared_preferences.dart';

class WalletService {
  static const String _walletKey = 'user_wallet';
  static const double _defaultWalletAmount = 1000.0;

  Future<double> loadWallet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_walletKey) ?? _defaultWalletAmount;
  }

  Future<void> saveWallet(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(_walletKey, amount);
  }
}
