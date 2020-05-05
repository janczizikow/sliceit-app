import 'package:dio/dio.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:sliceit/models/account.dart';
import 'package:sliceit/models/expense.dart';
import 'package:sliceit/models/group.dart';
import 'package:sliceit/models/invite.dart';
import 'package:sliceit/models/share.dart';
import 'package:sliceit/providers/auth.dart';
import 'package:sliceit/utils/config.dart';
import 'package:sliceit/utils/error_message_formatter.dart';

class ApiError extends Error {
  final String message;

  ApiError(this.message);

  @override
  String toString() => 'ApiError:${this.message}';
}

class Api with ErrorMessageFormatter {
  final Dio _dio = new Dio(dioBaseOptions)..transformer = FlutterTransformer();
  Auth _authService;

  Api(this._authService) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options) async {
          String accessToken = _authService.getAccessToken();

          if (accessToken != null) {
            options.headers['Authorization'] = "Bearer $accessToken";
          }

          return options;
        },
        onResponse: (Response response) async {
          return response;
        },
        onError: (DioError e) async {
          RegExp regExp = new RegExp(r'(login|register|google)');

          if (e.response?.statusCode == 401 && e.response?.request?.path != null
              ? !regExp.hasMatch(e.response.request.path)
              : false) {
            RequestOptions options = e.response.request;
            String accessToken = _authService.getAccessToken();
            String refreshToken = _authService.getRefreshToken();
            String authorizationHeader = "Bearer $accessToken";

            // If the token has been updated, repeat directly.
            if (accessToken != null &&
                authorizationHeader != options.headers['Authorization']) {
              options.headers['Authorization'] = authorizationHeader;
              return _dio.request(options.path, options: options);
            }

            if (refreshToken != null) {
              try {
                // Lock to block the incoming request until the token updated
                _dio.lock();
                _dio.interceptors.responseLock.lock();
                _dio.interceptors.errorLock.lock();

                // request new tokens
                await _authService.refreshTokens();

                // update request auth header with the new access token
                options.headers['Authorization'] =
                    _authService.getAccessToken();

                // unlock dio
                _dio.unlock();
                _dio.interceptors.responseLock.unlock();
                _dio.interceptors.errorLock.unlock();

                // repeat the request with new options
                return _dio.request(options.path, options: options);
              } on DioError catch (err) {
                switch (err.type) {
                  case DioErrorType.RESPONSE:
                    _authService.forceLogout();
                    return null;
                  default:
                    return err;
                }
              } catch (err) {
                _authService.forceLogout();
                return err;
              } finally {
                // unlock dio
                _dio.unlock();
                _dio.interceptors.responseLock.unlock();
                _dio.interceptors.errorLock.unlock();
              }
            }
          }

          return e;
        },
      ),
    );
  }

  Future<Account> fetchAccount() async {
    try {
      final response = await _dio.get('/auth/me');
      return Account.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<Account> updateAccount({
    @required String email,
    @required String firstName,
    @required String lastName,
  }) async {
    try {
      final response = await _dio.put('/users/account', data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
      });
      return Account.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<void> postFcmRegistrationToken(String fcmToken) async {
    try {
      final response = await _dio.post('/users/fcm-token', data: {
        'fcmToken': fcmToken,
      });
      return Account.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<Account> updateNotificationSettings({
    bool notifyWhenAddedToGroup,
    bool notifyWhenExpenseAdded,
    bool notifyWhenExpenseUpdated,
    bool notifyWhenPaymentAdded,
    bool notifyWhenPaymentUpdated,
  }) async {
    try {
      final response = await _dio.patch('/users/notification-settings', data: {
        'notifyWhenAddedToGroup': notifyWhenAddedToGroup,
        'notifyWhenExpenseAdded': notifyWhenExpenseAdded,
        'notifyWhenExpenseUpdated': notifyWhenExpenseUpdated,
        'notifyWhenPaymentAdded': notifyWhenPaymentAdded,
        'notifyWhenPaymentUpdated': notifyWhenPaymentUpdated,
      });
      return Account.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> uploadAvatar(String path) async {
    FormData formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        path,
        contentType: MediaType.parse(lookupMimeType(path) ?? 'image/jpg'),
      ),
    });
    final response = await _dio.post('/users/account/avatar', data: formData);
    return response.data;
  }

  Future<bool> removeAvatar() async {
    try {
      await _dio.delete('/users/account/avatar');
      return true;
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<bool> deleteAccount() async {
    try {
      await _dio.delete('/users');
      return true;
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
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
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<List<Group>> fetchGroups(
      {int page = 1, List<dynamic> results = const []}) async {
    try {
      int limit = 50;
      Response<Map<String, dynamic>> response =
          await _dio.get("/groups?page=$page&limit=$limit");
      int nextPage = response.data['next'] != null ? page + 1 : null;
      List<dynamic> data = results + response.data['groups'];
      if (nextPage != null) {
        return fetchGroups(page: nextPage, results: data);
      } else {
        return Group.parseGroups(data);
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<Group> fetchGroup(String id) async {
    try {
      final response = await _dio.get("/groups/$id");
      return Group.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
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
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
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
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
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
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<List<Invite>> fetchGroupInvites(String groupId,
      {int page = 1, List<dynamic> results = const []}) async {
    try {
      int limit = 50;
      Response<Map<String, dynamic>> response =
          await _dio.get("/groups/$groupId/invites/?page=$page&limit=$limit");
      int nextPage = response.data['next'] != null ? page + 1 : null;
      List<dynamic> data = results + response.data['invites'];
      if (nextPage != null) {
        return fetchGroupInvites(groupId, page: nextPage, results: data);
      } else {
        return data.map<Invite>((json) => Invite.fromJson(json)).toList();
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<Invite> createInvite(String groupId, String email) async {
    try {
      final response =
          await _dio.post("/groups/$groupId/invites", data: {'email': email});
      if (response.statusCode == 204) {
        return null;
      }
      return Invite.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<bool> deleteGroupInvite(String groupId, String inviteId) async {
    try {
      await _dio.delete(
        "/groups/$groupId/invites/$inviteId",
      );
      return true;
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<List<Expense>> fetchExpensesPage(
    String groupId,
    int page, {
    int limit = 50,
  }) async {
    try {
      final response =
          await _dio.get("/groups/$groupId/expenses?page=$page&limit=$limit");
      return response.data['expenses']
          .map<Expense>((json) => Expense.fromJson(json))
          .toList();
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<Expense> createExpense({
    @required String groupId,
    @required String name,
    @required int amount,
    @required String payerId,
    @required List<Share> shares,
    @required String currency,
    @required String date,
  }) async {
    try {
      final response = await _dio.post("/groups/$groupId/expenses/", data: {
        'name': name,
        'amount': amount,
        'payerId': payerId,
        'shares': shares,
        'currency': currency,
        'date': date,
      });
      return Expense.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<Expense> createPayment({
    @required String groupId,
    @required int amount,
    @required String from,
    @required String to,
    @required String currency,
    @required String date,
  }) async {
    try {
      final response = await _dio.post("/groups/$groupId/payments/", data: {
        'amount': amount,
        'from': from,
        'to': to,
        'currency': currency,
        'date': date,
      });
      return Expense.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<Expense> updatePayment({
    @required String groupId,
    @required String expenseId,
    int amount,
    String from,
    String to,
    String currency,
    String date,
  }) async {
    try {
      final response =
          await _dio.patch("/groups/$groupId/payments/$expenseId", data: {
        'amount': amount,
        'from': from,
        'to': to,
        'currency': currency,
        'date': date,
      });
      return Expense.fromJson(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }

  Future<bool> deleteExpense({
    @required String groupId,
    @required String expenseId,
  }) async {
    try {
      await _dio.delete("/groups/$groupId/expenses/$expenseId");
      return true;
    } on DioError catch (e) {
      if (e.response != null) {
        throw ApiError(getErrorMessage(e.response.data));
      } else {
        rethrow;
      }
    }
  }
}
