import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../services/api.dart';

enum Status { IDLE, UPLOAD, ERROR }

class AccountProvider with ChangeNotifier {
  Account _account;
  Status _avatarStatus = Status.IDLE;
  final Api _api = Api();

  Account get account => _account;

  String get fullName => account?.fullName ?? '';

  String get initials => account?.initials ?? '';

  bool get hasAvatar => account?.avatar != null;

  Status get avatarStatus => _avatarStatus;

  Future<void> fetchAccount() async {
    Account account = await _api.fetchAccount();
    _account = account;
    notifyListeners();
  }

  Future<void> updateAccount(
      {String email, String firstName, String lastName}) async {
    Account account = await _api.updateAccount(
      email: email ?? _account.email,
      firstName: firstName ?? _account.firstName,
      lastName: lastName ?? _account.lastName,
    );
    _account = account;
    notifyListeners();
  }

  Future<void> uploadAvatar(String path) async {
    _avatarStatus = Status.UPLOAD;
    notifyListeners();

    try {
      final response = await _api.uploadAvatar(path);
      if (response['status']) {
        _account.avatar = response['data']['url'];
        _avatarStatus = Status.IDLE;
      } else {
        _avatarStatus = Status.ERROR;
      }
    } catch (e) {
      _avatarStatus = Status.ERROR;
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeAvatar() async {
    await _api.removeAvatar();
    _account.avatar = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _api.deleteAccount();
    _account = null;
    notifyListeners();
  }
}
