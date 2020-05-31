import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final BaseOptions dioBaseOptions = BaseOptions(
  baseUrl: kReleaseMode
      ? 'https://www.sliceitapp.com/api/v1'
      : 'http://10.5.49.17:3000/api/v1',
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
  connectTimeout: 5000,
  receiveTimeout: 5000,
  contentType: 'application/json',
);
