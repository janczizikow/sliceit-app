import 'package:flutter/foundation.dart';
import 'package:sliceit/models/share.dart';

class Expense {
  final String id;
  final String name;
  final int amount;
  final String currency;
  final DateTime date;
  final bool isPayment;
  bool isDeleted;
  final String payerId;
  final String groupId;
  final List<Share> shares;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    @required this.id,
    @required this.name,
    @required this.amount,
    @required this.currency,
    @required this.payerId,
    @required this.groupId,
    @required this.shares,
    @required this.createdAt,
    @required this.date,
    this.updatedAt,
    this.isPayment = false,
    this.isDeleted = false,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      currency: json['currency'],
      payerId: json['payerId'],
      groupId: json['groupId'],
      isPayment: json['isPayment'],
      isDeleted: json['isDeleted'],
      shares: SharesList.fromJson(json['shares']).shares,
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
