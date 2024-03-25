import 'package:flutter/material.dart';

import '../../model/tree_node.dart';

class BrowserState extends ChangeNotifier {

  String title = '';
  List<TreeNode> items = [];
  bool selectionMode = false;

  void notify() {
    notifyListeners();
  }
}
