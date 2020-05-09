import 'dart:convert';

import 'package:flutter/foundation.dart';

class Member with ChangeNotifier {
  final String id;
  final String userId;
  final String groupId;
  final String firstName;
  final String lastName;
  final String avatar;
  int _balance;

  Member({
    @required this.id,
    @required this.userId,
    @required this.groupId,
    @required this.firstName,
    @required this.lastName,
    this.avatar,
    int balance = 0,
  }) {
    this._balance = balance;
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      userId: json['user']['id'],
      groupId: json['groupId'],
      firstName: json['user']['firstName'],
      lastName: json['user']['lastName'],
      avatar: json['user']['avatar'],
      balance: json['balance'],
    );
  }

  get fullName => lastName.isNotEmpty ? "$firstName $lastName" : firstName;

  get initials => RegExp(r'\S+').allMatches(fullName).fold('',
      (acc, match) => acc + fullName.substring(match.start, match.start + 1));

  get balance => _balance;

  set balance(int bal) {
    _balance = bal;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'groupId': groupId,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'balance': _balance,
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap());
  }

  Member copy() {
    return Member(
      id: id,
      userId: userId,
      groupId: groupId,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
      balance: _balance,
    );
  }
}
