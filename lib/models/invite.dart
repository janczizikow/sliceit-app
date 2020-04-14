import 'package:flutter/foundation.dart';

@immutable
class Invite {
  final String id;
  final String email;
  final String groupId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invite({
    @required this.id,
    @required this.email,
    @required this.groupId,
    @required this.createdAt,
    this.updatedAt,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'],
      email: json['email'],
      groupId: json['groupId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
