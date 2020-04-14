import 'package:flutter/foundation.dart';

enum Status { IDLE, PENDING, RESOLVED, REJECTED }

abstract class BaseProvider extends ChangeNotifier {
  Status _status = Status.IDLE;

  get status => _status;

  set status(Status newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
