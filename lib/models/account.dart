import 'dart:convert';

import 'package:flutter/foundation.dart';

class Account {
  String id;
  String firstName;
  String lastName;
  String email;
  String avatar;
  String fcmRegistrationToken;
  bool notifyWhenAddedToGroup;
  bool notifyWhenExpenseAdded;
  bool notifyWhenExpenseUpdated;
  bool notifyWhenPaymentAdded;
  bool notifyWhenPaymentUpdated;
  final DateTime createdAt;
  DateTime updatedAt;

  Account({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.createdAt,
    this.avatar,
    this.fcmRegistrationToken,
    this.notifyWhenAddedToGroup = true,
    this.notifyWhenExpenseAdded = true,
    this.notifyWhenExpenseUpdated = true,
    this.notifyWhenPaymentAdded = true,
    this.notifyWhenPaymentUpdated = true,
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
      fcmRegistrationToken: json['fcmRegistrationToken'],
      notifyWhenAddedToGroup: json['notifyWhenAddedToGroup'],
      notifyWhenExpenseAdded: json['notifyWhenExpenseAdded'],
      notifyWhenExpenseUpdated: json['notifyWhenExpenseUpdated'],
      notifyWhenPaymentAdded: json['notifyWhenPaymentAdded'],
      notifyWhenPaymentUpdated: json['notifyWhenPaymentUpdated'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatar': avatar,
      'fcmRegistrationToken': fcmRegistrationToken,
      'notifyWhenAddedToGroup': notifyWhenAddedToGroup,
      'notifyWhenExpenseAdded': notifyWhenExpenseAdded,
      'notifyWhenExpenseUpdated': notifyWhenExpenseUpdated,
      'notifyWhenPaymentAdded': notifyWhenPaymentAdded,
      'notifyWhenPaymentUpdated': notifyWhenPaymentUpdated,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap());
  }
}
