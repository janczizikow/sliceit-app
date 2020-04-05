import 'dart:convert';
import 'package:flutter/foundation.dart';

class Group {
  final String id;
  String name;
  String currency;
  bool isDeleted;
  final DateTime createdAt;
  DateTime updatedAt;

  Group({
    @required this.id,
    @required this.name,
    this.currency,
    this.isDeleted = false,
    @required this.createdAt,
    this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      currency: json['currency'],
      isDeleted: json['isDeleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static List<Group> parseGroups(List<dynamic> json) {
    final List<Group> result =
        json.map<Group>((json) => Group.fromJson(json)).toList();
    return result;
  }

  static Group parseGroup(String responseBody) {
    final Map<String, dynamic> parsed =
        jsonDecode(responseBody) as Map<String, dynamic>;
    return Group.fromJson(parsed);
  }
}
