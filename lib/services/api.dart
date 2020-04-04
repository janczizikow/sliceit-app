import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/group.dart';

class ApiError extends Error {
  final String message;

  ApiError(this.message);

  @override
  String toString() => 'ApiError:${this.message}';
}

class Api {
  static const _baseUrl = kReleaseMode
      ? 'https://sliceit.herokuapp.com/api/v1'
      : 'http://192.168.178.111:3000/api/v1';
  static final Api _instance = Api._internal();
  var _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  factory Api() {
    return Api._internal();
  }

  Api._internal();

  get instance => _instance;

  set accessToken(String accessToken) {
    if (accessToken.isEmpty) {
      instance._headers.remove('Authorization');
    } else {
      instance._headers['Authorization'] = "Bearer $accessToken";
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        "$_baseUrl/auth/login",
        headers: instance._headers,
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
        headers: instance._headers,
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
        headers: instance._headers,
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

  Future<List<Group>> fetchGroups() async {
    // TODO: Handle pagination
    try {
      final response = await http.get(
        "$_baseUrl/groups",
        headers: instance._headers,
      );
      if (response.statusCode == 200) {
        return compute(Group.parseGroups, response.body);
      }
      throw ApiError(_getErrorMessage(jsonDecode(response.body)));
    } on http.ClientException {
      throw ApiError('Connection failed');
    }
  }

  Future<Group> createGroup({String name, String currency}) async {
    try {
      final response = await http.post(
        "$_baseUrl/groups",
        headers: instance._headers,
        body: jsonEncode({
          'name': name,
          'currency': currency,
        }),
      );
      if (response.statusCode == 201) {
        return compute(Group.parseGroup, response.body);
      } else {
        throw ApiError(_getErrorMessage(jsonDecode(response.body)));
      }
    } on http.ClientException {
      throw ApiError('Connection failed');
    }
  }

  Future<Group> updateGroup({String groupId, name, currency}) async {
    try {
      final response = await http.patch(
        "$_baseUrl/groups/$groupId",
        headers: instance._headers,
        body: jsonEncode({
          'name': name,
          'currency': currency,
        }),
      );
      if (response.statusCode == 200) {
        return compute(Group.parseGroup, response.body);
      } else {
        throw ApiError(_getErrorMessage(jsonDecode(response.body)));
      }
    } on http.ClientException {
      throw ApiError('Connection failed');
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    try {
      final response = await http.delete(
        "$_baseUrl/groups/$groupId",
        headers: instance._headers,
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        throw ApiError(_getErrorMessage(jsonDecode(response.body)));
      }
    } on http.ClientException {
      throw ApiError('Connection failed');
    }
  }
}
