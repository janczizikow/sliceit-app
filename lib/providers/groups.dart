import 'package:sliceit/models/account.dart';
import 'package:sliceit/models/group.dart';
import 'package:sliceit/models/member.dart';
import 'package:sliceit/providers/base.dart';
import 'package:sliceit/services/api.dart';

class GroupsProvider extends BaseProvider {
  final Api _api;
  final List<Group> _groups = [];
  int _selectedGroupIndex = 0;
  String _selectedGroupId;

  GroupsProvider(this._api);

  set isAuthenticated(bool authenticated) {
    if (authenticated) {
      fetchGroups();
    }
  }

  List<Group> get groups {
    return _groups;
  }

  bool get isNotEmpty => groups.isNotEmpty;

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

  String memberFirstName(String userId) {
    return _groups[_selectedGroupIndex]
        .members
        .firstWhere((member) => member.userId == userId)
        .firstName;
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
      final List<Group> groups = await _api.fetchGroups();
      _groups.clear();
      _groups.addAll(groups);

      if (_groups.isNotEmpty) {
        _selectedGroupId = _groups[_selectedGroupIndex].id;
      }

      status = Status.RESOLVED;
    } catch (e) {
      status = Status.REJECTED;
      rethrow;
    }
  }

  Future<void> fetchGroup(String id) async {
    int groupIndex = _groups.indexWhere((group) => group.id == id);
    if (groupIndex != -1) {
      final Group group = await _api.fetchGroup(id);
      _groups[groupIndex] = group;
      notifyListeners();
    }
  }

  Future<void> createGroup(
      {String name, String currency, Account member}) async {
    final Group group = await _api.createGroup(name: name, currency: currency);
    _groups.add(group);
    _selectedGroupIndex = _groups.length - 1;
    _selectedGroupId = group.id;
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
    status = Status.IDLE;
  }
}
