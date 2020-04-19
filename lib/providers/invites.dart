import 'package:flutter/foundation.dart';

import './base.dart';
import '../models/invite.dart';
import '../services/api.dart';

class InvitesProvider extends BaseProvider {
  final Api _api = Api();
  final Map<String, List<Invite>> _invitesByGroupId = {};

  get isFetching => status == Status.PENDING;

  List<Invite> byGroupId(String groupId) {
    if (_invitesByGroupId.containsKey(groupId)) {
      return _invitesByGroupId[groupId];
    }

    return [];
  }

  int countByGroupId(String groupId) {
    if (_invitesByGroupId.containsKey(groupId)) {
      return _invitesByGroupId[groupId].length;
    }
    return 0;
  }

  Future<List<Invite>> fetchGroupInvites(String groupId) async {
    final List<Invite> groupInvites = await _api.fetchGroupInvites(groupId);
    _invitesByGroupId[groupId] = groupInvites;
    notifyListeners();
    return groupInvites;
  }

  Future<bool> createInvite(String groupId, String email) async {
    status = Status.PENDING;
    try {
      final Invite invite = await _api.createInvite(groupId, email);
      if (invite != null) {
        if (_invitesByGroupId?.containsKey(groupId) ?? false) {
          _invitesByGroupId[groupId].add(invite);
        } else {
          _invitesByGroupId[groupId] = [invite];
        }
        status = Status.RESOLVED;
        return true;
      } else {
        status = Status.RESOLVED;
        return false;
      }
    } catch (e) {
      status = Status.REJECTED;
      throw e;
    }
  }

  Future<void> deleteGroupInvite({
    @required String groupId,
    @required String inviteId,
  }) async {
    if (_invitesByGroupId.containsKey(groupId)) {
      final groupInvites = _invitesByGroupId[groupId];
      final inviteIndex =
          groupInvites.indexWhere((invite) => invite.id == inviteId);
      final invite = groupInvites[inviteIndex];
      _invitesByGroupId[groupId].removeAt(inviteIndex);
      notifyListeners();
      try {
        await _api.deleteGroupInvite(groupId, inviteId);
      } catch (err) {
        groupInvites.insert(inviteIndex, invite);
        notifyListeners();
      }
    }
  }

  void reset() {
    _invitesByGroupId.clear();
    status = Status.PENDING;
  }
}
