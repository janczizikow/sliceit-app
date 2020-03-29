import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiError extends Error {
  final String message;

  ApiError(this.message);
}

// TODO: Convert to a singleton?
class Api {
  static const _baseUrl = kReleaseMode
      ? 'https://sliceit.herokuapp.com/api/v1'
      : 'http://192.168.178.111:3000/api/v1';
  var _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  set accessToken(String accessToken) {
    if (accessToken.isEmpty) {
      _headers.remove('Authorization');
    } else {
      _headers['Authorization'] = "Bearer $accessToken";
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        "$_baseUrl/auth/login",
        headers: _headers,
        body: jsonEncode(
          {'email': email, 'password': password},
        ),
      );
      var result = await compute(jsonDecode, response.body);
      if (response.statusCode == 200) {
        return result;
      } else {
        throw ApiError(_getErrorMessage(result));
      }
    } on http.ClientException {
      throw ApiError('Connection failed');
    }
  }

  Future<Map<String, dynamic>> register({
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String password,
  }) async {
    try {
      final response = await http.post(
        "$_baseUrl/auth/register",
        headers: _headers,
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );
      var result = await compute(jsonDecode, response.body);
      if (response.statusCode == 200) {
        return result;
      } else {
        throw ApiError(_getErrorMessage(jsonDecode(response.body)));
      }
    } on http.ClientException {
      throw ApiError('Connection failed');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      final response = await http.post(
        "$_baseUrl/auth/forgot-password",
        headers: _headers,
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 201) {
        return true;
      }
      throw ApiError(_getErrorMessage(jsonDecode(response.body)));
    } on http.ClientException {
      throw ApiError('Connection failed');
    }
  }

  String _getErrorMessage(dynamic result) {
    return (result['errors'] as List).map((error) => error['msg']).join(', ');
  }
}
