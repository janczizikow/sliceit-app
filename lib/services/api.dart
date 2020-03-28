import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiError extends Error {
  final String message;

  ApiError(this.message);
}

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
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return result;
      } else {
        final message =
            (result['errors'] as List).map((error) => error['msg']).join(', ');
        throw ApiError(message);
      }
    } on http.ClientException {
      throw ApiError('Connection failed');
    }
  }
}
