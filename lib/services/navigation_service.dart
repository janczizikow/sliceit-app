import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  NavigationService._internal();

  factory NavigationService() {
    return _instance;
  }

  GlobalKey<NavigatorState> _navigationKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  bool pop() {
    return _navigationKey.currentState.pop();
  }

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return _navigationKey.currentState
        .pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> replace(String routeName) {
    return _navigationKey.currentState.pushReplacementNamed(routeName);
  }

  Future<dynamic> reset({dynamic arguments}) {
    return _navigationKey.currentState
        .pushNamedAndRemoveUntil('/', (_) => false, arguments: arguments);
  }
}
