import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/tree_traverser.dart';
import '../tree/tree_node.dart';
import '../util/strings.dart';
import 'ui_state.dart';

class UiSupervisor {
  // late TreeTraverser treeTraverser;
  late UiState uiState;
  
  UiSupervisor(BuildContext context) {
    // treeTraverser = Provider.of<TreeTraverser>(context);
    uiState = Provider.of<UiState>(context, listen: false);
  }

  void populateItems() {
    for (int i = 0; i < 10; i++) {
      uiState.items.add(TreeNode.textNode(randomName()));
      debugPrint('added random item');
    }
    uiState.notify();
  }

}