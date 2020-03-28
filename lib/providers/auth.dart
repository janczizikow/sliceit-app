import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Auth with ChangeNotifier {
  static const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';
  static const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
  final _storage = FlutterSecureStorage();
  String _accessToken;
  String _refreshToken;

  get isAuthenticated {
    return _accessToken != null;
  }

  Future<void> restoreTokens() async {
    String accessToken = await _storage.read(key: Auth.ACCESS_TOKEN_KEY);
    String refreshToken = await _storage.read(key: Auth.REFRESH_TOKEN_KEY);

    if (accessToken != _accessToken || refreshToken != _refreshToken) {
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      notifyListeners();
    }
  }

  Future<void> login() async {
    try {
      final token = 'TEST';
      await _storage.write(key: ACCESS_TOKEN_KEY, value: token);
      _accessToken = token;
      notifyListeners();
    } catch (err) {
      // TODO: error handling
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: Auth.ACCESS_TOKEN_KEY);
      await _storage.delete(key: Auth.REFRESH_TOKEN_KEY);
      _accessToken = null;
      _refreshToken = null;
      notifyListeners();
    } catch (err) {
      // TODO: error handling
    }
  }
}
