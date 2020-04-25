import 'package:flutter/foundation.dart';

class Share {
  final String userId;
  final int amount;

  Share({
    @required this.userId,
    @required this.amount,
  });

  toJson() {
    return {
      'userId': this.userId,
      'amount': this.amount,
    };
  }
}
