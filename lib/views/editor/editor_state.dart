import 'package:flutter/material.dart';

import 'package:todotree/model/tree_node.dart';

class EditorState extends ChangeNotifier {

  TextEditingController editTextController = TextEditingController();
  FocusNode textEditFocus = FocusNode();
  TreeNode? editedNode;
  int? newItemPosition;
  bool numericKeyboard = false;

  void notify() {
    notifyListeners();
  }
}
