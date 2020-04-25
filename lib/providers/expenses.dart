import 'package:flutter/foundation.dart';
import 'package:sliceit/models/expense.dart';
import 'package:sliceit/models/share.dart';
import 'package:sliceit/providers/base.dart';
import 'package:sliceit/services/api.dart';

class ExpensesProvider extends BaseProvider {
  final Api _api;
  final Map<String, List<Expense>> _expensesByGroupId = {};

  ExpensesProvider(this._api);

  List<Expense> byGroupId(String groupId) {
    if (_expensesByGroupId.containsKey(groupId)) {
      return _expensesByGroupId[groupId];
    }

    return [];
  }

  int countByGroupId(String groupId) {
    if (_expensesByGroupId.containsKey(groupId)) {
      return _expensesByGroupId[groupId].length;
    }
    return 0;
  }

  Future<List<Expense>> fetchExpensesPage(String groupId, int page) async {
    status = Status.PENDING;

    try {
      final List<Expense> groupExpenses =
          await _api.fetchExpensesPage(groupId, page);
      if (_expensesByGroupId.containsKey(groupId)) {
        if (page == 1) {
          _expensesByGroupId[groupId] = groupExpenses;
        } else {
          _expensesByGroupId[groupId].addAll(groupExpenses);
        }
      } else {
        _expensesByGroupId[groupId] = groupExpenses;
      }
      status = Status.RESOLVED;
      return groupExpenses;
    } catch (e) {
      status = Status.REJECTED;
      rethrow;
    }
  }

  Future<void> createExpense({
    @required String groupId,
    @required String name,
    @required int amount,
    @required String payerId,
    @required List<Share> shares,
    @required String currency,
    @required String date,
  }) async {
    print(shares);
    status = Status.PENDING;
    try {
      final Expense expense = await _api.createExpense(
        groupId: groupId,
        name: name,
        amount: amount,
        shares: shares,
        payerId: payerId,
        currency: currency,
        date: date,
      );
      if (_expensesByGroupId.containsKey(groupId)) {
        _expensesByGroupId[groupId].insert(0, expense);
      } else {
        _expensesByGroupId[groupId] = [expense];
      }
      // TODO: Apply balance to the group!
      status = Status.RESOLVED;
    } catch (e) {
      status = Status.REJECTED;
      rethrow;
    }
  }

  Future<void> createPayment({
    @required String groupId,
    @required int amount,
    @required String from,
    @required String to,
    @required String currency,
    @required String date,
  }) async {
    status = Status.PENDING;
    try {
      final Expense payment = await _api.createPayment(
        groupId: groupId,
        amount: amount,
        from: from,
        to: to,
        currency: currency,
        date: date,
      );
      if (_expensesByGroupId.containsKey(groupId)) {
        _expensesByGroupId[groupId].insert(0, payment);
      } else {
        _expensesByGroupId[groupId] = [payment];
      }
      // TODO: Apply balance to the group!
      status = Status.RESOLVED;
    } catch (e) {
      status = Status.REJECTED;
      rethrow;
    }
  }

//  TODO: reset
  void reset() {
    _expensesByGroupId.clear();
  }
}
