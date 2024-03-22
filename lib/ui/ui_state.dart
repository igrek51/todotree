import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../tree/tree_node.dart';

class UiState extends ChangeNotifier {

  String title = 'Dupa123';

  void setTitle(String title) {
    this.title = title;
    notifyListeners();
  }

  var items = <TreeNode>[];

  void notify() {
    notifyListeners();
  }
}