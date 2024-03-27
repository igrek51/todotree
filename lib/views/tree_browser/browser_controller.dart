import 'package:todotree/services/clipboard_manager.dart';
import 'package:todotree/services/error_handler.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/services/logger.dart';
import 'package:todotree/views/editor/editor_controller.dart';
import 'package:todotree/views/editor/editor_state.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/util/strings.dart';
import 'package:todotree/views/home/home_state.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';

class BrowserController {
  HomeState homeState;
  BrowserState browserState;
  EditorState editorState;

  late EditorController editorController;

  TreeTraverser treeTraverser;
  ClipboardManager clipboardManager;

  BrowserController(this.homeState, this.browserState, this.editorState,
      this.treeTraverser, this.clipboardManager);

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

  void populateItems() {
    for (int i = 0; i < 10; i++) {
      treeTraverser.addChildToCurrent(TreeNode.textNode(randomName()));
    }
    renderItems();
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

  bool goBack() {
    ensureNoSelectionMode();
    try {
      treeTraverser.goBack();
      renderAll();
      return true;
    } on NoSuperItemException {
      return false; // Can't go any higher
    }
  }

  void goStepUp() {
    ensureNoSelectionMode();
    try {
      treeTraverser.goUp();
      renderAll();
    } on NoSuperItemException {
      logger.debug("Can't go any higher");
    }
  }

  void goIntoNode(TreeNode node) {
    ensureNoSelectionMode();
    if (node.type == TreeNodeType.link) {
      treeTraverser.goToLinkTarget(node);
    } else {
      treeTraverser.goTo(node);
    }
    renderAll();
  }

  void ensureNoSelectionMode() {
    if (treeTraverser.selectionMode) {
      treeTraverser.cancelSelection();
      renderItems();
    }
  }

  void addNodeAt(int position) {
    ensureNoSelectionMode();
    if (position < 0) position = treeTraverser.currentParent.size; // last
    if (position > treeTraverser.currentParent.size) {
      position = treeTraverser.currentParent.size;
    }
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

  void removeNodesAt(int position) {
    if (treeTraverser.selectionMode) {
      final nodes = treeTraverser.selectedIndexes
          .map((index) => treeTraverser.getChild(index))
          .toList();
      for (final node in nodes) {
        treeTraverser.removeFromCurrent(node);
      }
      treeTraverser.cancelSelection();
      renderItems();
      InfoService.showInfo('Nodes removed: ${nodes.length}');
    } else {
      final node = treeTraverser.getChild(position);
      removeNode(node);
    }
  }

  void runNodeMenuAction(String action, {TreeNode? node, int ?position}) {
    handleError(() {
      if (action == 'remove-nodes' && position != null) {
        removeNodesAt(position);
      } else if (action == 'edit-node' && node != null) {
        editNode(node);
      } else if (action == 'add-above' && position != null) {
        addNodeAt(position);
      } else if (action == 'select-node' && position != null) {
        selectNodeAt(position);
      } else if (action == 'select-all') {
        selectAll();
      } else if (action == 'remove-remote-node' && node != null) {
      } else if (action == 'remove-link-and-target' && node != null) {
      } else if (action == 'add-above' && position != null) {
        addNodeAt(position);
      } else if (action == 'cut' && position != null) {
        cutItemsAt(position);
      } else if (action == 'copy' && position != null) {
        copyItemsAt(position);
      } else if (action == 'paste-above' && position != null) {
        pasteAbove(position);
      } else if (action == 'paste-as-link' && position != null) {
        pasteAboveAsLink(position);
      } else if (action == 'split' && node != null) {
      } else if (action == 'push-to-remote' && node != null) {
      } else {
        logger.error('Unknown action: $action');
      }
    });
  }

  Future<void> saveAndExit() async {
    treeTraverser.goToRoot();
    renderAll();
    await treeTraverser.saveAndExit();
  }

  void onToggleSelectedNode(int position) {
    treeTraverser.toggleItemSelected(position);
    renderItems();
  }

  void selectAll() {
    treeTraverser.selectAll();
    renderItems();
  }

  void selectNodeAt(int position) {
    treeTraverser.setItemSelected(position, true);
    renderItems();
  }

  void cutItemsAt(int position) {
    final positions = treeTraverser.selectedIndexes.toSet();
    if (positions.isEmpty) {
      positions.add(position); // if nothing selected - include current item
    }
    clipboardManager.cutItems(treeTraverser, positions);
    renderItems();
  }

  void copyItemsAt(int position) {
    final positions = treeTraverser.selectedIndexes.toSet();
    if (positions.isEmpty) {
      positions.add(position); // if nothing selected - include current item
    }
    clipboardManager.copyItems(treeTraverser, positions, info: true);
    renderItems();
  }

  void pasteAbove(int position) async {
    handleError(() async {
      await clipboardManager.pasteItems(treeTraverser, position);
      renderItems();
    });
  }

  void pasteAboveAsLink(int position) {
    clipboardManager.pasteItemsAsLink(treeTraverser, position);
    renderItems();
  }

  void handleNodeTap(TreeNode node, int index) {
    if (treeTraverser.selectionMode) {
      onToggleSelectedNode(index);
    } else if (node.isLink) {
      goIntoNode(node);
    } else if (node.isLeaf) {
      editNode(node);
    } else {
      goIntoNode(node);
    }
  }
}
