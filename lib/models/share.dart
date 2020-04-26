import 'package:flutter/foundation.dart';

class Share {
  final String userId;
  final int amount;

  Share({
    @required this.userId,
    @required this.amount,
  });

  factory Share.fromJson(dynamic json) {
    return Share(
      userId: json['userId'],
      amount: json['amount'],
    );
  }

  toJson() {
    return {
      'userId': this.userId,
      'amount': this.amount,
    };
  }
}

class SharesList {
  final List<Share> shares;

  SharesList({this.shares});

  factory SharesList.fromJson(List<dynamic> json) {
    List<Share> shares = new List<Share>();
    shares = json.map((i) => Share.fromJson(i)).toList();

    return new SharesList(shares: shares);
  }
}
