import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api.dart';

class Auth with ChangeNotifier {
  static const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';
  static const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
  final _storage = FlutterSecureStorage();
  final Api _api = Api();
  String _accessToken;
  String _refreshToken;

  get isAuthenticated {
    return _accessToken != null;
  }

  Future<void> restoreTokens() async {
    String accessToken = await _storage.read(key: ACCESS_TOKEN_KEY);
    String refreshToken = await _storage.read(key: REFRESH_TOKEN_KEY);

    if (accessToken != _accessToken || refreshToken != _refreshToken) {
      _api.accessToken = accessToken;
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      notifyListeners();
    }
  }

  Future<void> login({String email, String password}) async {
    try {
      final res = await _api.login(email, password);
      await _storage.write(key: ACCESS_TOKEN_KEY, value: res['accessToken']);
      await _storage.write(key: REFRESH_TOKEN_KEY, value: res['refreshToken']);
      _accessToken = res['accessToken'];
      _refreshToken = res['refreshToken'];
      _api.accessToken = res['accessToken'];
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> register({
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String password,
  }) async {
    try {
      final res = await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      await _storage.write(key: ACCESS_TOKEN_KEY, value: res['accessToken']);
      await _storage.write(key: REFRESH_TOKEN_KEY, value: res['refreshToken']);
      _accessToken = res['accessToken'];
      _refreshToken = res['refreshToken'];
      _api.accessToken = res['accessToken'];
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: ACCESS_TOKEN_KEY);
    await _storage.delete(key: REFRESH_TOKEN_KEY);
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }
}
