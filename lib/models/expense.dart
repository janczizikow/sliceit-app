import 'package:flutter/foundation.dart';

class Expense {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final DateTime date;
  final bool isPayment;
  final String payerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    @required this.id,
    @required this.name,
    @required this.amount,
    @required this.currency,
    @required this.payerId,
    @required this.createdAt,
    @required this.date,
    this.updatedAt,
    this.isPayment = false,
  });
}
