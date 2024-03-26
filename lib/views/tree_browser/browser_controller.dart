import '../../services/error_handler.dart';
import '../../services/info_service.dart';
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
    renderAll();
  }

  void renderAll() {
    renderItems();
    renderTitle();
  }

  void renderTitle() {
    browserState.title = treeTraverser.currentParent.name;
    browserState.notify();
  }

  void renderItems() {
    browserState.items = treeTraverser.currentParent.children.toList();
    browserState.selectedIndexes = treeTraverser.selectedIndexes.toSet();
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
    ensureNoSelectionMode();
    editorState.newItemPosition = null;
    editorState.editedNode = node;
    editorState.editTextController.text = node.name;
    editorState.notify();
    homeState.pageView = HomePageView.itemEditor;
    homeState.notify();
  }

  void goUp() {
    ensureNoSelectionMode();
    try {
      treeTraverser.goUp();
      renderAll();
    } on NoSuperItemException {
      logger.debug("Can't go higher than root");
    }
  }

  void goIntoNode(TreeNode node) {
    ensureNoSelectionMode();
    treeTraverser.goTo(node);
    renderAll();
  }

  void ensureNoSelectionMode() {
    if (treeTraverser.anythingSelected) {
      treeTraverser.cancelSelection();
      renderItems();
    }
  }

  void addNodeAt(int position) {
    ensureNoSelectionMode();
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
    treeTraverser.unsavedChanges = true;
    renderItems();
    logger.debug('Reordered nodes: $oldIndex -> $newIndex');
  }

  void removeNode(TreeNode node) {
    treeTraverser.removeFromCurrent(node);
    renderItems();
    InfoService.showInfo('Node removed: ${node.name}');
  }

  void runNodeMenuAction(String action, TreeNode node) {
    handleError(() {
      switch (action) {
        case 'remove-node':
          removeNode(node);
        case 'edit-node':
          editNode(node);
        default:
          logger.debug('Unknown action: $action');
      }
    });
  }

  void saveAndExit() {
    treeTraverser.saveIfChanged();
    treeTraverser.goToRoot();
    renderAll();
  }

  void onToggleSelectedNode(int position) {
    treeTraverser.toggleItemSelected(position);
    renderItems();
  }
}