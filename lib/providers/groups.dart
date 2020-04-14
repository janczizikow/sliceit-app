import 'package:flutter/foundation.dart';
import './base.dart';
import '../services/api.dart';
import '../models/group.dart';

class GroupsProvider extends BaseProvider {
  final Api api;
  final List<Group> _groups = [];
  int _selectedGroupIndex = 0;
  int _lastFetchedTimestamp;

  GroupsProvider({
    @required this.api,
    @required bool isAuthenticated,
    List<Group> prev = const [],
  }) {
    if (isAuthenticated) {
      fetchGroups();
    }
    _groups.addAll(prev);
  }

  List<Group> get groups {
    return _groups;
  }

  bool get hasGroups => groups.isNotEmpty;

  bool get needsSync {
    return _lastFetchedTimestamp == null;
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
      _groups.addAll(groups);
      _lastFetchedTimestamp = DateTime.now().millisecondsSinceEpoch;
      status = Status.RESOLVED;
    } catch (e) {
      status = Status.REJECTED;
      throw e;
    }
  }

  Future<void> createGroup({String name, String currency}) async {
    final Group group = await api.createGroup(name: name, currency: currency);
    _groups.add(group);
    _selectedGroupIndex = _groups.length - 1;
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
    notifyListeners();
  }

  void reset() {
    _groups.clear();
    _selectedGroupIndex = 0;
    _lastFetchedTimestamp = null;
    status = Status.IDLE;
  }
}
