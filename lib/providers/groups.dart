import 'package:flutter/foundation.dart';

import '../models/group.dart';
import '../services/api.dart';

class GroupsProvider with ChangeNotifier {
  final Api _api = Api();
  List<Group> _groups = [];
  int _selectedGroupIndex = 0;
  int _lastFetchedTimestamp;

  List<Group> get groups {
    return _groups;
  }

  bool get needsSync {
    return _lastFetchedTimestamp == null;
  }

  Group get selectedGroup {
    return _groups[_selectedGroupIndex];
  }

  Group byId(String id) {
    return _groups.firstWhere((group) => group.id == id);
  }

  Future<void> fetchGroups() async {
    final List<Group> groups = await _api.fetchGroups();
    _groups = groups;
    _lastFetchedTimestamp = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  Future<void> createGroup({String name, String currency}) async {
    final Group group = await _api.createGroup(name: name, currency: currency);
    _groups.add(group);
    notifyListeners();
  }

  Future<void> updateGroup(
      {String groupId, String name, String currency}) async {
    final groupIndex = _groups.indexWhere((group) => group.id == groupId);
    if (groupIndex != -1) {
      final Group updatedGroup = await _api.updateGroup(
        groupId: groupId,
        name: name,
        currency: currency,
      );
      _groups[groupIndex] = updatedGroup;
      notifyListeners();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    await _api.deleteGroup(groupId);
    _groups.removeWhere((group) => group.id == groupId);
    notifyListeners();
  }

  void reset() {
    _groups = [];
    _lastFetchedTimestamp = null;
  }
}
