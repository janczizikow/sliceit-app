import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sliceit/providers/base.dart';

import './base.dart';
import '../services/api.dart';
import '../utils/constants.dart';

class Auth extends BaseProvider {
  final _storage = FlutterSecureStorage();
  final Api _api = Api();
  String _accessToken;

  bool get isAuthenticated => _accessToken != null;
  bool get isFetching => status == Status.PENDING;

  Future<void> restoreTokens() async {
    String accessToken = await _storage.read(key: ACCESS_TOKEN_KEY);

    if (accessToken != _accessToken) {
      _api.accessToken = accessToken;
      _accessToken = accessToken;
      notifyListeners();
    }
  }

  Future<void> login({String email, String password}) async {
    status = Status.PENDING;

    try {
      final res = await _api.login(email, password);
      _accessToken = res['accessToken'];
      status = Status.RESOLVED;
    } catch (err) {
      status = Status.REJECTED;
      throw err;
    }
  }

  Future<void> register({
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String password,
  }) async {
    status = Status.PENDING;

    try {
      final res = await _api.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      _accessToken = res['accessToken'];
      status = Status.RESOLVED;
    } catch (err) {
      status = Status.REJECTED;
      throw err;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _accessToken = null;
    _api.accessToken = null;
    status = Status.IDLE;
  }
}
