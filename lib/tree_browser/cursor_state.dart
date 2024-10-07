import 'package:flutter/material.dart';

class CursorState extends ChangeNotifier {
  bool cursorNavigator = false;
  bool cursorNavigatorCollapsed = true;

  void notify() {
    notifyListeners();
  }
}
