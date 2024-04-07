import 'dart:math';

import 'package:todotree/services/app_lifecycle.dart';
import 'package:todotree/services/clipboard_manager.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/util/errors.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/util/collections.dart';
import 'package:todotree/util/numbers.dart';
import 'package:todotree/views/editor/editor_controller.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/views/home/home_state.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';

class BrowserController {
  HomeState homeState;
  BrowserState browserState;

  late EditorController editorController;

  TreeTraverser treeTraverser;
  ClipboardManager clipboardManager;
  AppLifecycle appLifecycle;
  SettingsProvider settingsProvider;

  Map<TreeNode, double> scrollCache = {};

  BrowserController(this.homeState, this.browserState, this.treeTraverser, this.clipboardManager, this.appLifecycle,
      this.settingsProvider);

  void renderAll() {
    renderItems();
    renderTitle();
  }

  void renderTitle() {
    browserState.title = treeTraverser.currentParent.name;
    browserState.atRoot = treeTraverser.currentParent.isRoot;
    browserState.notify();
  }

  void renderItems() {
    browserState.items = treeTraverser.currentParent.children.toList();
    browserState.selectedIndexes = treeTraverser.selectedIndexes.toSet();
    browserState.notify();
  }

  void editNode(TreeNode node) {
    ensureNoSelectionMode();
    if (node.type == TreeNodeType.link) {
      return InfoService.error('Can\'t edit a link');
    }
    editorController.editNode(node);
  }

  bool goBack() {
    ensureNoSelectionMode();
    try {
      treeTraverser.goBack();
      restoreScrollOffset();
      renderAll();
      return true;
    } on NoSuperItemException {
      return false; // Can't go any higher
    }
  }

  bool goStepUp() {
    ensureNoSelectionMode();
    try {
      treeTraverser.goUp();
      restoreScrollOffset();
      renderAll();
      return true;
    } on NoSuperItemException {
      return false;
    }
  }

  void restoreScrollOffset() {
    if (scrollCache.containsKey(treeTraverser.currentParent)) {
      browserState.scrollController.jumpTo(scrollCache[treeTraverser.currentParent]!);
      scrollCache.remove(treeTraverser.currentParent);
    }
  }

  void goIntoNode(TreeNode node) {
    rememberScrollOffset();
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
    editorController.addNodeAt(position);
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

  void removeOneNode(TreeNode node) {
    final originalPosition = treeTraverser.getChildIndex(node);
    treeTraverser.removeFromCurrent(node);
    renderItems();

    InfoService.snackbarAction('Removed: ${node.name}', 'UNDO', () {
      treeTraverser.addChildToCurrent(node, position: originalPosition);
      renderItems();
      InfoService.info('Node restored: ${node.name}');
    });
  }

  void removeMultipleNodes(List<int> sortedPositions) {
    List<Pair<int, TreeNode>> originalNodePositions =
        sortedPositions.map((index) => Pair(index, treeTraverser.getChild(index))).toList();
    for (final pair in originalNodePositions) {
      treeTraverser.removeFromCurrent(pair.second);
    }
    treeTraverser.cancelSelection();
    renderItems();

    InfoService.snackbarAction('Removed: ${sortedPositions.length}', 'UNDO', () {
      for (final pair in originalNodePositions) {
        treeTraverser.addChildToCurrent(pair.second, position: pair.first);
      }
      renderItems();
      InfoService.info('Nodes restored: ${originalNodePositions.length}');
    });
  }

  void removeNodesAt(int position) {
    if (treeTraverser.selectionMode) {
      List<int> sortedPositions = treeTraverser.selectedIndexes.toList()..sort();
      removeMultipleNodes(sortedPositions);
    } else {
      final node = treeTraverser.getChild(position);
      removeOneNode(node);
    }
  }

  void removeSelectedNodes() {
    List<int> sortedPositions = treeTraverser.selectedIndexes.toList()..sort();
    if (sortedPositions.isEmpty) {
      return InfoService.error('No items selected');
    }
    removeMultipleNodes(sortedPositions);
  }

  void removeLinkAndTarget(TreeNode link) {
    final originalLinkPosition = treeTraverser.getChildIndex(link);
    final target = treeTraverser.findLinkTarget(link.name);
    final targetParent = target?.parent;
    int? originalTargetPosition;
    if (target != null && targetParent != null) {
      originalTargetPosition = targetParent.children.indexOf(target).nonNegative();
      treeTraverser.removeFromParent(target, targetParent);
    }
    treeTraverser.removeFromCurrent(link);
    renderItems();

    InfoService.snackbarAction('Link & target removed: ${link.name}', 'UNDO', () {
      treeTraverser.addChildToCurrent(link, position: originalLinkPosition);
      if (target != null && targetParent != null && originalTargetPosition != null) {
        targetParent.insertAt(originalTargetPosition, target);
      }
      renderItems();
      InfoService.info('Link & target restored: ${link.name}');
    });
  }

  void runNodeMenuAction(String action, {TreeNode? node, int? position}) {
    safeExecute(() {
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
      } else if (action == 'remove-link-and-target' && node != null) {
        removeLinkAndTarget(node);
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
      } else if (action == 'split' && node != null && position != null) {
        splitNodeBySeparator(node, position);
      } else if (action == 'push-to-remote' && node != null) {
        InfoService.error('Not implemented yet');
      } else if (action == 'remove-remote-node' && node != null) {
        InfoService.error('Not implemented yet');
      } else {
        logger.error('Unknown action: $action');
      }
    });
  }

  Future<void> saveAndExit() async {
    await treeTraverser.saveIfChanged();
    appLifecycle.minimizeApp();
    treeTraverser.goToRoot();
    renderAll();
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

  void cutSelectedItems() {
    final positions = treeTraverser.selectedIndexes.toSet();
    if (positions.isEmpty) {
      return InfoService.error('No items selected');
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

  void copySelectedItems() {
    final positions = treeTraverser.selectedIndexes.toSet();
    if (positions.isEmpty) {
      return InfoService.error('No items selected');
    }
    clipboardManager.copyItems(treeTraverser, positions, info: true);
    renderItems();
  }

  void pasteAbove(int position) async {
    safeExecute(() async {
      await clipboardManager.pasteItems(treeTraverser, position);
      renderItems();
    });
  }

  void pasteAboveAsLink(int position) {
    clipboardManager.pasteItemsAsLink(treeTraverser, position);
    renderItems();
  }

  Future<void> handleNodeTap(TreeNode node, int index) async {
    if (treeTraverser.selectionMode) {
      onToggleSelectedNode(index);
    } else if (node.isLink) {
      goIntoNode(node);
    } else if (node.depth == 1 && settingsProvider.firstLevelFolders) {
      goIntoNode(node);
    } else if (node.isLeaf) {
      editNode(node);
    } else {
      goIntoNode(node);
    }
  }

  void rememberScrollOffset() {
    scrollCache[treeTraverser.currentParent] = browserState.scrollController.offset;
  }

  void splitNodeBySeparator(TreeNode node, int position) {
    final separator = node.name.contains('\n') ? '\n' : ',';
    final parts = node.name.split(separator).map((e) => e.trim()).toList();
    node.name = parts.first;
    final newNodes = parts.map((part) => TreeNode.textNode(part)).toList().dropFirst(1);
    for (final newNode in newNodes) {
      position++;
      treeTraverser.addChildToCurrent(newNode, position: position);
    }
    treeTraverser.unsavedChanges = true;
    renderItems();
    InfoService.info('Split into ${parts.length} nodes.');
  }

  void enterRandomItem() {
    final children = treeTraverser.currentParent.children;
    if (children.isEmpty) {
      return InfoService.error('No items to choose from');
    }
    final randomNode = children[Random().nextInt(children.length)];
    goIntoNode(randomNode);
    InfoService.info('Entered random item: ${randomNode.name}');
  }
}
