import 'package:flutter/foundation.dart';

class Account {
  String id;
  String firstName;
  String lastName;
  String email;
  String avatar;
  final DateTime createdAt;
  DateTime updatedAt;

  Account({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.createdAt,
    this.avatar,
    this.updatedAt,
  });

  get fullName => lastName.isNotEmpty ? "$firstName $lastName" : firstName;

  get initials => RegExp(r'\S+').allMatches(fullName).fold('',
      (acc, match) => acc + fullName.substring(match.start, match.start + 1));

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
