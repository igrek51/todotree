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

  void addRandomItem() {
    final name = randomName();
    treeTraverser.addChild(TreeNode.textNode(name));
    print('Added item: $name');
    renderItems();
  }

  void populateItems() {
    for (int i = 0; i < 10; i++) {
      addRandomItem();
    }
  }

  void editNode(TreeNode node) {
    uiState.editTextField = node.name;
    uiState.appState = AppState.itemEditor;
    uiState.notify();
  }
}