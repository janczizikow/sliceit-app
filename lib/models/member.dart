import 'package:flutter/foundation.dart';

class Member {
  final String id;
  final String userId;
  final String groupId;
  final String firstName;
  final String lastName;
  final String avatar;
  int balance;

  Member({
    @required this.id,
    @required this.userId,
    @required this.groupId,
    @required this.firstName,
    @required this.lastName,
    this.avatar,
    this.balance = 0,
  });

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
}
