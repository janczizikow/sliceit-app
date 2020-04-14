import 'package:flutter/foundation.dart';

import './base.dart';
import '../models/invite.dart';
import '../services/api.dart';

class InvitesProvider extends BaseProvider {
  final Api api;
  final Map<String, List<Invite>> _invitesByGroupId = {};

  InvitesProvider(this.api);

  get isFetching => status == Status.PENDING;

  List<Invite> byGroupId(String groupId) {
    if (_invitesByGroupId.containsKey(groupId)) {
      return _invitesByGroupId[groupId];
    }

    return [];
  }

  int byGroupIdCount(String groupId) {
    if (_invitesByGroupId.containsKey(groupId)) {
      return _invitesByGroupId[groupId].length;
    }
    return 0;
  }

  Future<void> fetchGroupInvites(String groupId) async {
    status = Status.PENDING;
    try {
      final List<Invite> groupInvites = await api.fetchGroupInvites(groupId);
      _invitesByGroupId[groupId] = groupInvites;
      status = Status.RESOLVED;
    } catch (e) {
      status = Status.REJECTED;
      throw e;
    }
  }

  Future<bool> createInvite(String groupId, String email) async {
    status = Status.PENDING;
    try {
      final Invite invite = await api.createInvite(groupId, email);
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
        await api.deleteGroupInvite(groupId, inviteId);
      } catch (err) {
        groupInvites.insert(inviteIndex, invite);
        notifyListeners();
      }
    }
  }
}
