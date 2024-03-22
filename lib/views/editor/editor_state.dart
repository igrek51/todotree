import 'package:flutter/material.dart';

import '../../model/tree_node.dart';

class EditorState extends ChangeNotifier {

  TextEditingController editTextController = TextEditingController();
  TreeNode? editedNode;

  void notify() {
    notifyListeners();
  }
}
