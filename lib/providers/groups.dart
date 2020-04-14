import 'package:flutter/foundation.dart';
import './base.dart';

import '../models/group.dart';
import '../models/account.dart';
import '../models/member.dart';
import '../services/api.dart';

class GroupsProvider with ChangeNotifier {
  final Api api;
  final List<Group> _groups = [];
  int _selectedGroupIndex = 0;
  // FIXME: Figure out better way of doing this
  // Not using BaseProvider class, due to notifyListeners() called after provider is disposed()
  Status _status = Status.IDLE;

  String _selectedGroupId;
  int _lastFetchedTimestamp;

  GroupsProvider({
    @required this.api,
    @required bool isAuthenticated,
  }) {
    if (isAuthenticated) {
      fetchGroups();
    }
  }

  get status => _status;

  set status(Status newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  List<Group> get groups {
    return _groups;
  }

  bool get hasGroups => groups.isNotEmpty;

  bool get needsSync {
    return _lastFetchedTimestamp == null;
  }

  List<Member> get selectedGroupMembers {
    return _selectedGroupIndex < _groups.length
        ? _groups[_selectedGroupIndex].members
        : [];
  }

  String get selectedGroupId {
    return _selectedGroupId;
  }

  Group get selectedGroup {
    return _selectedGroupIndex < _groups.length
        ? _groups[_selectedGroupIndex]
        : null;
  }

  selectGroup(String id) {
    int groupIndex = _groups.indexWhere((group) => group.id == id);
    if (groupIndex != -1) {
      _selectedGroupIndex = groupIndex;
      _selectedGroupId = id;
      notifyListeners();
    }
  }

  Group byId(String id) {
    return _groups.firstWhere((group) => group.id == id);
  }

  Future<void> fetchGroups() async {
    status = Status.PENDING;

    try {
      final List<Group> groups = await api.fetchGroups();
      _groups.clear();
      _groups.addAll(groups);
      if (_groups.isNotEmpty) {
        _selectedGroupId = _groups[_selectedGroupIndex].id;
      }
      _lastFetchedTimestamp = DateTime.now().millisecondsSinceEpoch;
      status = Status.RESOLVED;
    } catch (e) {
      status = Status.REJECTED;
      throw e;
    }
  }

  Future<void> fetchGroup(String id) async {
    int groupIndex = _groups.indexWhere((group) => group.id == id);
    if (groupIndex != -1) {
      final Group group = await api.fetchGroup(id);
      _groups[groupIndex] = group;
      notifyListeners();
    }
  }

  Future<void> createGroup(
      {String name, String currency, Account member}) async {
    final Group group = await api.createGroup(name: name, currency: currency);
    _groups.add(group);
    _selectedGroupIndex = _groups.length - 1;
    _selectedGroupId = group.id;
    notifyListeners();
  }

  Future<void> updateGroup(
      {String groupId, String name, String currency}) async {
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex != -1) {
      final Group updatedGroup = await api.updateGroup(
        groupId: groupId,
        name: name,
        currency: currency,
      );
      _groups[groupIndex] = updatedGroup;
      notifyListeners();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    await api.deleteGroup(groupId);
    _groups.removeWhere((group) => group.id == groupId);
    if (_groups.isNotEmpty) {
      _selectedGroupIndex = 0;
      _selectedGroupId = _groups[0].id;
    } else {
      _selectedGroupIndex = 0;
      _selectedGroupId = null;
    }
    notifyListeners();
  }

  void reset() {
    _groups.clear();
    _selectedGroupIndex = 0;
    _selectedGroupId = null;
    _lastFetchedTimestamp = null;
    status = Status.IDLE;
  }
}
