import '../../services/logger.dart';
import '../editor/editor_controller.dart';
import '../editor/editor_state.dart';
import '../../services/tree_traverser.dart';
import '../../model/tree_node.dart';
import '../../util/strings.dart';
import '../home/home_state.dart';
import '../tree_browser/browser_state.dart';

class BrowserController {
  HomeState homeState;
  BrowserState browserState;
  EditorState editorState;

  late EditorController editorController;

  TreeTraverser treeTraverser;
  
  BrowserController(this.homeState, this.browserState, this.editorState, this.treeTraverser);

  void init() {
    renderItems();
    renderTitle();
  }

  void renderTitle() {
    browserState.title = treeTraverser.currentParent.name;
    browserState.notify();
  }

  void renderItems() {
    browserState.items = treeTraverser.currentParent.children.toList();
    browserState.notify();
  }

  void addRandomItem() {
    final name = randomName();
    treeTraverser.addChildToCurrent(TreeNode.textNode(name));
    print('Added item: $name');
    renderItems();
  }

  void populateItems() {
    for (int i = 0; i < 10; i++) {
      addRandomItem();
    }
  }

  void editNode(TreeNode node) {
    editorState.newItemPosition = null;
    editorState.editedNode = node;
    editorState.editTextController.text = node.name;
    editorState.notify();
    homeState.pageView = HomePageView.itemEditor;
    homeState.notify();
  }

  void goUp() {
    try {
      treeTraverser.goUp();
      renderItems();
      renderTitle();
    } on NoSuperItemException {
      logger.debug("Can't go higher than root");
    }
  }

  void goIntoNode(TreeNode node) {
    treeTraverser.goTo(node);
    renderItems();
    renderTitle();
  }

  void cancelSelectionMode() {
    if (browserState.selectionMode) {
      browserState.selectionMode = false;
      browserState.notify();
    }
  }

  void addNodeAt(int position) {
    cancelSelectionMode();
    if (position < 0) position = treeTraverser.currentParent.size; // last
    if (position > treeTraverser.currentParent.size) position = treeTraverser.currentParent.size;
    editorState.newItemPosition = position;
    editorState.editedNode = null;
    editorState.editTextController.text = '';
    editorState.notify();
    homeState.pageView = HomePageView.itemEditor;
    homeState.notify();
  }

  void addNodeToTheEnd() {
    addNodeAt(treeTraverser.currentParent.size);
  }

  void reorderNodes(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final newList = treeTraverser.currentParent.children.toList();
    if (newIndex >= newList.length) newIndex = newList.length - 1;
    if (newIndex == oldIndex) return;
    if (newIndex < oldIndex) {
      final node = newList.removeAt(oldIndex);
      newList.insert(newIndex, node);
    } else {
      final node = newList.removeAt(oldIndex);
      newList.insert(newIndex, node);
    }
    treeTraverser.currentParent.children = newList;
    renderItems();
    logger.debug('Reordered nodes: $oldIndex -> $newIndex');
  }
}