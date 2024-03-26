import 'package:flutter/material.dart';

import '../../model/tree_node.dart';

class BrowserState extends ChangeNotifier {

  String title = '';
  List<TreeNode> items = [];
  Set<int> selectedIndexes = {};

  void notify() {
    notifyListeners();
  }
}
