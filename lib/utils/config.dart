import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

final BaseOptions dioBaseOptions = BaseOptions(
  baseUrl: kReleaseMode
      ? 'https://sliceit.herokuapp.com/api/v1'
      : 'http://192.168.178.111:3000/api/v1',
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
  connectTimeout: 5000,
  receiveTimeout: 5000,
  contentType: 'application/json',
);
