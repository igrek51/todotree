import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../tree/tree_node.dart';

class UiState extends ChangeNotifier {

  String title = '';
  List<TreeNode> items = [];
  AppState appState = AppState.itemsList;
  TextEditingController editTextController = TextEditingController();
  TreeNode? editedNode;

  void notify() {
    notifyListeners();
  }
}

enum AppState { itemsList, itemEditor }
