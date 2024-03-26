import 'package:todotreev2/services/info_service.dart';

import '../model/tree_node.dart';
import 'tree_storage.dart';

class TreeTraverser {
  TreeStorage treeStorage;

  TreeNode rootNode = cRootNode;
  TreeNode currentParent = cRootNode;
  bool unsavedChanges = false;
  TreeNode? focusNode;
  Set<int> selectedIndexes = {};

  TreeTraverser(this.treeStorage);

  void reset() {
    rootNode = cRootNode;
    currentParent = rootNode;
    unsavedChanges = false;
    focusNode = null;
    selectedIndexes.clear();
  }

  Future<void> load() async {
    reset();
    final value = await treeStorage.readDbTree();
    rootNode = value;
    currentParent = value;
  }

  Future<void> save() async {
    await treeStorage.writeDbTree(rootNode);
    unsavedChanges = false;
  }

  Future<void> saveIfChanged() async {
    if (!unsavedChanges) return;
    save();
  }

  List<TreeNode> get childNodes => currentParent.children;

  bool isPositionBeyond(int position) =>
      position >= currentParent.children.length;

  bool isItemAtPosition(int position) =>
      position >= 0 && position < currentParent.size;

  TreeNode getChild(int position) => currentParent.getChild(position);

  void addChildToCurrent(TreeNode item, {int? position}) {
    final nPosision = position ?? currentParent.size;
    item.parent = currentParent;
    unsavedChanges = true;
    currentParent.insertAt(nPosision, item);
    focusNode = item;
  }

  void removeFromCurrentAt(int position) {
    if (isItemAtPosition(position)) {
      currentParent.removeAt(position);
      unsavedChanges = true;
      focusNode = null;
    }
  }

  void removeFromCurrent(TreeNode item) {
    currentParent.remove(item);
    unsavedChanges = true;
    focusNode = null;
  }

  void removeFromParent(TreeNode item, TreeNode parent) {
    parent.remove(item);
    unsavedChanges = true;
  }

  void goUp() {
    focusNode = currentParent;
    if (currentParent == rootNode) {
      throw NoSuperItemException();
    } else {
      if (currentParent.parent != null) {
        currentParent = currentParent.parent!;
      } else {
        throw ArgumentError('null parent');
      }
    }
  }

  void goInto(int childIndex) {
    final item = currentParent.getChild(childIndex);
    goTo(item);
  }

  void goTo(TreeNode child) {
    focusNode = currentParent;
    currentParent = child;
  }

  void goToRoot() {
    currentParent = rootNode;
    focusNode = null;
  }

  void goToLinkTarget(TreeNode link) {
    final target = findLinkTarget(link.name);
    if (target == null) {
      InfoService.showInfo('Link is broken: ${link.displayTargetPath}');
    } else {
      goTo(target);
    }
  }

  bool get selectionMode => selectedIndexes.isNotEmpty;

  void cancelSelection() {
    selectedIndexes.clear();
  }

  void setItemSelected(int position, bool selected) {
    if (selected) {
      selectedIndexes.add(position);
    } else {
      selectedIndexes.remove(position);
    }
  }

  bool isItemSelected(int position) => selectedIndexes.contains(position);

  void toggleItemSelected(int position) {
    setItemSelected(position, !isItemSelected(position));
  }

  void selectAll() {
    selectedIndexes.clear();
    for (var i = 0; i < currentParent.size; i++) {
      selectedIndexes.add(i);
    }
  }

  TreeNode? findLinkTarget(String targetPath) {
    final paths = targetPath.split('\t');
    TreeNode current = rootNode;
    for (final path in paths) {
      final found = current.findChildByName(path, lenient: true);
      if (found == null) return null;
      current = found;
    }
    return current;
  }

  String displayLinkName(TreeNode link) {
    final target = findLinkTarget(link.name);
    if (target == null) {
      return link.displayTargetPath;
    } else {
      return target.name;
    }
  }
}

class NoSuperItemException implements Exception {
  NoSuperItemException();
}
