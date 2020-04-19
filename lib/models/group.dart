import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import './member.dart';

class Group {
  final String id;
  final String creatorId;
  String name;
  String currency;
  bool isDeleted;
  List<Member> members;
  final DateTime createdAt;
  DateTime updatedAt;

  Group({
    @required this.id,
    @required this.name,
    @required this.creatorId,
    this.currency,
    this.isDeleted = false,
    this.members = const [],
    @required this.createdAt,
    this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      creatorId: json['creatorId'],
      name: json['name'],
      currency: json['currency'],
      isDeleted: json['isDeleted'],
      members: json.containsKey('members')
          ? json['members']
              .map<Member>((member) => Member.fromJson(member))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  static List<Group> parseGroups(List<dynamic> json) {
    final List<Group> result =
        json.map<Group>((json) => Group.fromJson(json)).toList();
    return result;
  }

  String memberFirstNameByUserId(String userId) {
    return members.firstWhere((member) => member.userId == userId).firstName;
  }
}
