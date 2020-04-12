import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api.dart';
import '../utils/constants.dart';

class Auth with ChangeNotifier {
  final _storage = FlutterSecureStorage();
  final Api _api = Api();
  String _accessToken;
  bool _isFetching = false;

  get isAuthenticated => _accessToken != null;

  get isFetching => _isFetching;

  Future<void> restoreTokens() async {
    String accessToken = await _storage.read(key: ACCESS_TOKEN_KEY);
    if (accessToken != _accessToken) {
      _api.accessToken = accessToken;
      _accessToken = accessToken;
      notifyListeners();
    }
  }

  Future<void> login({String email, String password}) async {
    try {
      _isFetching = true;
      notifyListeners();
      final res = await _api.login(email, password);
      _isFetching = false;
      _accessToken = res['accessToken'];
      notifyListeners();
    } catch (err) {
      _isFetching = false;
      notifyListeners();
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
      _isFetching = true;
      notifyListeners();
      final res = await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      _isFetching = false;
      _accessToken = res['accessToken'];
      notifyListeners();
    } catch (err) {
      _isFetching = false;
      notifyListeners();
      throw err;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _accessToken = null;
    _api.accessToken = null;
    notifyListeners();
  }
}
