import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

enum PasscodeStatus {
  UNINITIALIZED,
  ENABLED,
  VERIFIED,
  DISABLED,
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
  static const PIN_KEY = 'PIN';
  static const BIOMETRIC_AUTH_KEY = 'BIOMETRIC_AUTH';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Dio _dio = new Dio(dioBaseOptions)..transformer = FlutterTransformer();
  final NavigationService _navigationService;
  final SharedPreferences _prefs;

  Auth(this._navigationService, this._prefs);

  AuthStatus _status = AuthStatus.UNAUTHENTICATED;
  PasscodeStatus _passcodeStatus = PasscodeStatus.UNINITIALIZED;
  String _accessToken;
  String _refreshToken;
  String _pin;
  bool _biometricAuthEnabled = false;
  bool disablePasscodeLock = false;
  int forceLogoutTimestamp;

  AuthStatus get status => _status;
  PasscodeStatus get passcodeStatus => _passcodeStatus;
  String getAccessToken() => _accessToken;
  String getRefreshToken() => _refreshToken;
  bool get biometricAuthEnabled => _biometricAuthEnabled;
  set biometricAuthEnabled(bool isEnabled) {
    _biometricAuthEnabled = isEnabled;
    notifyListeners();
    _prefs.setBool(BIOMETRIC_AUTH_KEY, isEnabled);
  }

  bool get isPasscodeEnabled {
    return _passcodeStatus == PasscodeStatus.ENABLED ||
        _passcodeStatus == PasscodeStatus.VERIFIED;
  }

  Future<void> initialize() async {
    _setStatus(AuthStatus.RESTORING_TOKENS);
    try {
      String accessToken = await _storage.read(key: ACCESS_TOKEN_KEY);
      String refreshToken = await _storage.read(key: REFRESH_TOKEN_KEY);
      String pin = await _storage.read(key: PIN_KEY);
      _pin = pin;
      _passcodeStatus =
          pin == null ? PasscodeStatus.DISABLED : PasscodeStatus.ENABLED;
      _biometricAuthEnabled = _prefs.getBool(BIOMETRIC_AUTH_KEY) ?? false;
      _setTokens(accessToken: accessToken, refreshToken: refreshToken);
    } catch (e) {
      _setTokens(accessToken: null, refreshToken: null);
    }
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
    try {
      await googleSignIn.disconnect();
    } catch (e) {}
    _setTokens(accessToken: null, refreshToken: null);
    _pin = null;
    _biometricAuthEnabled = false;
    _navigationService.reset();
  }

  Future<void> forceLogout() async {
    forceLogoutTimestamp = DateTime.now().millisecondsSinceEpoch;
    await logout();
  }

  Future<void> setPinCode(String pin) async {
    _pin = pin;
    _passcodeStatus =
        pin == null ? PasscodeStatus.DISABLED : PasscodeStatus.VERIFIED;
    notifyListeners();
    await _storage.write(key: PIN_KEY, value: pin);
  }

  bool checkPinCode(String pin) {
    bool isValid = _pin == pin;
    return isValid;
  }

  void pinCodeVerified() {
    _passcodeStatus = PasscodeStatus.VERIFIED;
    notifyListeners();
  }

  Future<void> clearPinCode() async {
    _pin = null;
    _passcodeStatus = PasscodeStatus.DISABLED;
    notifyListeners();
    await _storage.delete(key: PIN_KEY);
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
