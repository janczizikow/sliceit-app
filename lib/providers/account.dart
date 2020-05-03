import 'package:sliceit/models/account.dart';
import 'package:sliceit/providers/base.dart';
import 'package:sliceit/services/api.dart';

class AccountProvider extends BaseProvider {
  final Api _api;
  Account _account;
  String _fcmRegistrationToken;

  AccountProvider(this._api);

  Account get account => _account;

  String get fullName => account?.fullName ?? '';

  String get initials => account?.initials ?? '';

  bool get hasAvatar => account?.avatar != null;

  bool get notifyWhenAddedToGroup => account?.notifyWhenAddedToGroup ?? true;

  bool get notifyWhenExpenseAdded => account?.notifyWhenExpenseAdded ?? true;

  bool get notifyWhenExpenseUpdated =>
      account?.notifyWhenExpenseUpdated ?? true;

  bool get notifyWhenPaymentAdded => account?.notifyWhenPaymentAdded ?? true;

  bool get notifyWhenPaymentUpdated =>
      account?.notifyWhenPaymentUpdated ?? true;

  set fcmRegistrationToken(String token) {
    _fcmRegistrationToken = token;
  }

  Future<void> fetchAccount() async {
    Account account = await _api.fetchAccount();
    _account = account;
    notifyListeners();
    if (_fcmRegistrationToken.isNotEmpty &&
        account.fcmRegistrationToken != _fcmRegistrationToken) {
      _postFcmRegistrationToken();
    }
  }

  Future<void> _postFcmRegistrationToken() async {
    await _api.postFcmRegistrationToken(_fcmRegistrationToken);
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

  Future<void> updateNotificationSettings({
    bool notifyWhenAddedToGroup,
    bool notifyWhenExpenseAdded,
    bool notifyWhenExpenseUpdated,
    bool notifyWhenPaymentAdded,
    bool notifyWhenPaymentUpdated,
  }) async {
    _account.notifyWhenAddedToGroup =
        notifyWhenAddedToGroup ?? _account.notifyWhenAddedToGroup;
    _account.notifyWhenExpenseAdded =
        notifyWhenExpenseAdded ?? _account.notifyWhenExpenseAdded;
    _account.notifyWhenExpenseUpdated =
        notifyWhenExpenseUpdated ?? _account.notifyWhenExpenseUpdated;
    _account.notifyWhenPaymentAdded =
        notifyWhenPaymentAdded ?? _account.notifyWhenPaymentAdded;
    _account.notifyWhenPaymentUpdated =
        notifyWhenPaymentUpdated ?? _account.notifyWhenPaymentUpdated;
    notifyListeners();
    Account account = await _api.updateNotificationSettings(
      notifyWhenAddedToGroup: notifyWhenAddedToGroup,
      notifyWhenExpenseAdded: notifyWhenExpenseAdded,
      notifyWhenExpenseUpdated: notifyWhenExpenseUpdated,
      notifyWhenPaymentAdded: notifyWhenPaymentAdded,
      notifyWhenPaymentUpdated: notifyWhenPaymentUpdated,
    );
    _account = account;
    notifyListeners();
  }

  Future<void> uploadAvatar(String path) async {
    status = Status.PENDING;

    try {
      final response = await _api.uploadAvatar(path);
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
    await _api.removeAvatar();
    _account.avatar = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _api.deleteAccount();
    _account = null;
    notifyListeners();
  }

  void reset() {
    _account = null;
  }
}
