import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sliceit/models/tokens.dart';
import 'package:sliceit/services/navigation_service.dart';
import 'package:sliceit/utils/config.dart';
import 'package:sliceit/utils/error_message_formatter.dart';
import 'package:sliceit/utils/google_sign_in.dart';

enum AuthStatus {
  UNINITIALIZED,
  RESTORING_TOKENS,
  UNAUTHENTICATED,
  AUTHENTICATING,
  AUTHENTICATED,
}

class AuthError extends Error {
  final String message;

  AuthError(this.message);

  @override
  String toString() => 'AuthError:${this.message}';
}

class Auth with ChangeNotifier, ErrorMessageFormatter {
  static const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
  static const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Dio _dio = new Dio(dioBaseOptions)..transformer = FlutterTransformer();
  final NavigationService _navigationService;

  Auth(this._navigationService);

  AuthStatus _status = AuthStatus.UNAUTHENTICATED;
  String _accessToken;
  String _refreshToken;
  int forceLogoutTimestamp;

  AuthStatus get status => _status;
  String getAccessToken() => _accessToken;
  String getRefreshToken() => _refreshToken;

  Future<void> restoreTokens() async {
    _setStatus(AuthStatus.RESTORING_TOKENS);
    String accessToken = await _storage.read(key: ACCESS_TOKEN_KEY);
    String refreshToken = await _storage.read(key: REFRESH_TOKEN_KEY);
    _setTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> refreshTokens() async {
    final response = await _dio.post('/auth/refresh', data: {
      'refreshToken': _refreshToken,
    });
    final Tokens tokens = Tokens.fromJson(response.data);
    _setTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    _storeTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<void> login({String email, String password}) async {
    _setStatus(AuthStatus.AUTHENTICATING);

    try {
      final response = await _dio.post(
        "/auth/login",
        data: {'email': email, 'password': password},
      );
      final Tokens tokens = Tokens.fromJson(response.data);
      _setTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      _navigationService.reset();
      _storeTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    } on DioError catch (e) {
      _setStatus(AuthStatus.UNAUTHENTICATED);
      if (e.response != null) {
        throw AuthError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<void> googleLogin(String idToken) async {
    _setStatus(AuthStatus.AUTHENTICATING);

    try {
      final response =
          await _dio.post("/auth/google", data: {'idToken': idToken});
      final Tokens tokens = Tokens.fromJson(response.data);
      _setTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      _navigationService.replace('/');
      _storeTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    } on DioError catch (e) {
      _setStatus(AuthStatus.UNAUTHENTICATED);
      if (e.response != null) {
        throw AuthError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<void> register({
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String password,
  }) async {
    _setStatus(AuthStatus.AUTHENTICATING);
    try {
      final response = await _dio.post(
        "/auth/register",
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        },
      );
      final Tokens tokens = Tokens.fromJson(response.data);
      _setTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      _navigationService.reset();
      _storeTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
    } on DioError catch (e) {
      _setStatus(AuthStatus.UNAUTHENTICATED);
      if (e.response != null) {
        throw AuthError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    await googleSignIn.disconnect();
    _setTokens(accessToken: null, refreshToken: null);
    _navigationService.reset();
  }

  Future<void> forceLogout() async {
    forceLogoutTimestamp = DateTime.now().millisecondsSinceEpoch;
    await logout();
  }

  void _setStatus(AuthStatus status) {
    if (status != _status) {
      _status = status;
      notifyListeners();
    }
  }

  void _setTokens({String accessToken, String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    if (accessToken == null || refreshToken == null) {
      _setStatus(AuthStatus.UNAUTHENTICATED);
    } else {
      _setStatus(AuthStatus.AUTHENTICATED);
    }
  }

  Future<void> _storeTokens({
    @required String accessToken,
    @required String refreshToken,
  }) async {
    await _storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
    await _storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
  }
}
