import 'package:flutter/material.dart';

import 'tree_traverser.dart';
import '../tree/tree_node.dart';
import '../util/strings.dart';
import '../app/ui_state.dart';

class UiSupervisor {
  late UiState uiState;
  late TreeTraverser treeTraverser;
  
  UiSupervisor(this.uiState, this.treeTraverser);

  void init() {
    renderTitle();
    populateItems();
    renderItems();
  }

  void renderTitle() {
    uiState.title = treeTraverser.currentParent.name;
    uiState.notify();
  }

  void renderItems() {
    uiState.items = treeTraverser.currentParent.children.toList();
    uiState.notify();
  }

  void populateItems() {
    for (int i = 0; i < 10; i++) {
      uiState.items.add(TreeNode.textNode(randomName()));
      debugPrint('added random item');
    }
    uiState.notify();
  }

}