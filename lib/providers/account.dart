import './base.dart';
import '../models/account.dart';
import '../services/api.dart';

class AccountProvider extends BaseProvider {
  final Api api;
  Account _account;

  AccountProvider(this.api);

  Account get account => _account;

  String get fullName => account?.fullName ?? '';

  String get initials => account?.initials ?? '';

  bool get hasAvatar => account?.avatar != null;

  Future<void> fetchAccount() async {
    Account account = await api.fetchAccount();
    _account = account;
    notifyListeners();
  }

  Future<void> updateAccount(
      {String email, String firstName, String lastName}) async {
    Account account = await api.updateAccount(
      email: email ?? _account.email,
      firstName: firstName ?? _account.firstName,
      lastName: lastName ?? _account.lastName,
    );
    _account = account;
    notifyListeners();
  }

  Future<void> uploadAvatar(String path) async {
    status = Status.PENDING;

    try {
      final response = await api.uploadAvatar(path);
      if (response['status']) {
        _account.avatar = response['data']['url'];
        status = Status.RESOLVED;
      } else {
        status = Status.REJECTED;
      }
    } catch (e) {
      status = Status.REJECTED;
    }
  }

  Future<void> removeAvatar() async {
    await api.removeAvatar();
    _account.avatar = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await api.deleteAccount();
    _account = null;
    notifyListeners();
  }
}
