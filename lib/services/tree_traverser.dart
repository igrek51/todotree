import '../model/tree_node.dart';
import 'tree_storage.dart';

class TreeTraverser {

  TreeStorage treeStorage;

  TreeNode rootNode = cRootNode;
  TreeNode currentParent = cRootNode;
  bool changesMade = false;
  TreeNode? focusNode;

  TreeTraverser(this.treeStorage);

  void reset() {
    rootNode = cRootNode;
    currentParent = rootNode;
    changesMade = false;
    focusNode = null;
  }

  Future<void> load() async {
    final value = await treeStorage.readDbTree();
    rootNode = value;
    currentParent = value;
  }

  List<TreeNode> get childNodes => currentParent.children;

  bool isPositionBeyond(int position) => position >= currentParent.children.length;

  bool isItemAtPosition(int position) => position >= 0 && position < currentParent.size;

  TreeNode getChild(int position) => currentParent.getChild(position);

  void addChildToCurrent(TreeNode item, {int? position}) {
    final nPosision = position ?? currentParent.size;
    item.parent = currentParent;
    changesMade = true;
    currentParent.insertAt(nPosision, item);
    focusNode = item;
  }

  void removeFromCurrentAt(int position) {
    if (isItemAtPosition(position)) {
      currentParent.removeAt(position);
      changesMade = true;
      focusNode = null;
    }
  }

  void removeFromCurrent(TreeNode item) {
    currentParent.remove(item);
    changesMade = true;
    focusNode = null;
  }

  void removeFromParent(TreeNode item, TreeNode parent) {
    parent.remove(item);
    changesMade = true;
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
}

class NoSuperItemException implements Exception {
  NoSuperItemException();
}
