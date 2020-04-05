import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/group.dart';
import '../utils/constants.dart';

class ApiError extends Error {
  final String message;

  ApiError(this.message);

  @override
  String toString() => 'ApiError:${this.message}';
}

class Api {
  static final Api _instance = Api._internal();
  static final BaseOptions baseOptions = BaseOptions(
    baseUrl: kReleaseMode
        ? 'https://sliceit.herokuapp.com/api/v1'
        : 'http://192.168.178.111:3000/api/v1',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    connectTimeout: 5000,
    receiveTimeout: 3000,
    contentType: 'application/json',
  );
  final Dio _dio = new Dio(baseOptions)..transformer = FlutterTransformer();
  final Dio _refreshDio = new Dio(baseOptions)
    ..transformer = FlutterTransformer();
  final _storage = FlutterSecureStorage();
  String accessToken;

  factory Api() {
    return _instance;
  }

  Api._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options) async {
          if (accessToken != null) {
            options.headers['Authorization'] = "Bearer $accessToken";
          }
          return options;
        },
        onResponse: (Response response) async {
          return response;
        },
        onError: (DioError e) async {
          if (e.response?.statusCode == 401) {
            RequestOptions options = e.response.request;
            String authorizationHeader = "Bearer $accessToken";

            // If the token has been updated, repeat directly.
            if (authorizationHeader != null &&
                authorizationHeader != options.headers['Authorization']) {
              options.headers['Authorization'] = authorizationHeader;
              return _dio.request(options.path, options: options);
            }

            String refreshToken = await _storage.read(key: REFRESH_TOKEN_KEY);

            if (refreshToken != null) {
              try {
                // Lock to block the incoming request until the token updated
                _dio.lock();
                _dio.interceptors.responseLock.lock();
                _dio.interceptors.errorLock.lock();

                // request new tokens & store them
                final refreshResponse = await _refreshDio.post('/auth/refresh',
                    data: {'refreshToken': refreshToken});
                await _storeTokens(
                  accessToken: refreshResponse.data['accessToken'],
                  refreshToken: refreshResponse.data['refreshToken'],
                );

                // update auth header with the new access token
                accessToken = refreshResponse.data['accessToken'];
                options.headers['Authorization'] =
                    refreshResponse.data['accessToken'];

                // unlock dio
                _dio.unlock();
                _dio.interceptors.responseLock.unlock();
                _dio.interceptors.errorLock.unlock();

                // repeat the request with a new options
                return _dio.request(options.path, options: options);
              } on DioError catch (err) {
                switch (err.type) {
                  case DioErrorType.RESPONSE:
                    // TODO: FORCELOGOUT
                    return err;
                  default:
                    return null;
                }
              } catch (err) {
                // TODO: FORCELOGOUT
                return err;
              }
            }
          }

          return e;
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {'email': email, 'password': password},
      );
      await _storeTokens(
          accessToken: response.data['accessToken'],
          refreshToken: response.data['refreshToken']);
      accessToken = response.data['accessToken'];
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(_getErrorMessage(e.response.data));
      } else {
        throw e;
      }
    }
  }

  Future<Map<String, dynamic>> register({
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String password,
  }) async {
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
      await _storeTokens(
          accessToken: response.data['accessToken'],
          refreshToken: response.data['refreshToken']);
      accessToken = response.data['accessToken'];
      return response.data;
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(_getErrorMessage(e.response.data));
      } else {
        throw e;
      }
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _dio.post(
        "/auth/forgot-password",
        data: {'email': email},
      );
      return true;
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(_getErrorMessage(e.response.data));
      } else {
        throw e;
      }
    }
  }

  Future<List<Group>> fetchGroups(
      {int page = 1, List<dynamic> results = const []}) async {
    try {
      int limit = 50;
      int offset = page * limit;
      Response<Map<String, dynamic>> response =
          await _dio.get("/groups?page=$page&limit=$limit&offset=$offset");
      int nextPage = response.data['next'] != null ? page + 1 : null;
      List<dynamic> data = results + response.data['groups'];
      if (nextPage != null) {
        return fetchGroups(page: nextPage, results: data);
      } else {
        return Group.parseGroups(data);
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(_getErrorMessage(e.response.data));
      } else {
        throw e;
      }
    }
  }

  Future<Group> createGroup({String name, String currency}) async {
    try {
      final response = await _dio.post(
        "/groups",
        data: {
          'name': name,
          'currency': currency,
        },
      );
      return Group.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(_getErrorMessage(e.response.data));
      } else {
        throw e;
      }
    }
  }

  Future<Group> updateGroup({String groupId, name, currency}) async {
    try {
      final response = await _dio.patch(
        "/groups/$groupId",
        data: {
          'name': name,
          'currency': currency,
        },
      );
      return Group.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(_getErrorMessage(e.response.data));
      } else {
        throw e;
      }
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    try {
      await _dio.delete(
        "/groups/$groupId",
      );
      return true;
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(_getErrorMessage(e.response.data));
      } else {
        throw e;
      }
    }
  }

  Future<void> _storeTokens(
      {@required String accessToken, @required String refreshToken}) async {
    await _storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
    await _storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
  }

  String _getErrorMessage(dynamic result) {
    return (result['errors'] as List).map((error) => error['msg']).join(', ');
  }
}
