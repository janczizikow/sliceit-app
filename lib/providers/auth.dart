import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sliceit/providers/base.dart';

import './base.dart';
import '../services/api.dart';
import '../utils/constants.dart';

class Auth extends BaseProvider {
  final _storage = FlutterSecureStorage();
  final Api api;
  String _accessToken;

  Auth(this.api);

  get isAuthenticated => _accessToken != null;
  get isFetching => status == Status.PENDING;

  Future<void> restoreTokens() async {
    String accessToken = await _storage.read(key: ACCESS_TOKEN_KEY);
    if (accessToken != _accessToken) {
      api.accessToken = accessToken;
      _accessToken = accessToken;
      notifyListeners();
    }
  }

  Future<void> login({String email, String password}) async {
    status = Status.PENDING;

    try {
      final res = await api.login(email, password);
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
      final res = await api.register(
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
    api.accessToken = null;
    status = Status.IDLE;
  }
}
