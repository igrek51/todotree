import 'package:flutter/material.dart';

import 'package:todotree/model/tree_node.dart';

class BrowserState extends ChangeNotifier {
  String title = '';
  List<TreeNode> items = [];
  bool atRoot = false;
  Set<int> selectedIndexes = {};
  ScrollController scrollController = ScrollController();

  void notify() {
    notifyListeners();
  }
}
