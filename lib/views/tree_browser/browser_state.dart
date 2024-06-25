import 'package:flutter/material.dart';

import 'package:todotree/model/tree_node.dart';

class BrowserState extends ChangeNotifier {
  String title = '';
  List<TreeNode> items = [];
  bool atRoot = false;
  Set<int> selectedIndexes = {};
  ScrollController scrollController = ScrollController();
  bool cursorNavigator = false;
  bool cursorNavigatorCollapsed = true;

  void notify() {
    notifyListeners();
  }
}
