import 'package:collection/collection.dart';

import '../util/strings.dart';

class TreeNode {
  TreeNode({
    required this.name,
    this.parent,
    this.children = const [],
    this.type = TreeNodeType.text,
    this.targetData = '',
  });

  String name;
  TreeNode? parent;
  List<TreeNode> children;
  TreeNodeType type;
  String targetData;

  static TreeNode rootNode() {
    return TreeNode(name: '/', type: TreeNodeType.text);
  }

  static TreeNode textNode(String text) {
    return TreeNode(name: text, type: TreeNodeType.text);
  }

  static TreeNode linkNode(String targetData, String name) {
    return TreeNode(name: name, targetData: targetData, type: TreeNodeType.link);
  }

  bool get isText => type == TreeNodeType.text;
  bool get isLink => type == TreeNodeType.link;
  bool get isRemote => type == TreeNodeType.remote;
  bool get isRoot => parent == null;

  int get size => children.length;
  bool get isEmpty => children.isEmpty;

  TreeNode getChild(int index) {
    if (index < 0) throw Exception('Invalid position: index < 0');
    if (index >= children.length) throw Exception('Invalid position: index >= items size (${children.length})');
    return children[index];
  }

  TreeNode? getChildOrNull(int index) {
    if (index < 0 || index >= children.length) return null;
    return children[index];
  }

  int getChildIndex(TreeNode item) {
    return children.indexOf(item); // -1 if item is not found
  }

  int get indexInParent {
    if (parent == null) return -1;
    return parent!.getChildIndex(this);
  }

  TreeNode? get lastChild {
    if (children.isEmpty) return null;
    return children.last;
  }

  TreeNode? findChildByName(String name, {bool lenient = false}) {
    for (final child in children) { // find by exact name
      if (child.isText && child.name == name) return child;
    }
    if (!lenient) return null;
    final deemojinator = DeEmojinator(); // find by simplified name
    final expectedSimplified = deemojinator.simplify(name);
    return children.firstWhereOrNull((it) {
      return it.isText && deemojinator.simplify(it.name) == expectedSimplified;
    });
  }

  void add(TreeNode item) {
    item.parent = this;
    children.add(item);
  }

  void insertAt(int index, TreeNode item) {
    item.parent = this;
    children.insert(index, item);
  }

  void removeAt(int index) {
    children.removeAt(index);
  }

  void remove(TreeNode item) {
    children.remove(item);
  }

  int removeItself() {
    if (parent == null) return -1;
    final indexInParent = parent!.getChildIndex(this);
    if (indexInParent == -1) return -1;
    parent!.removeAt(indexInParent);
    return indexInParent;
  }

  List<String> pathNames() { // parent names except root
    final names = <String>[];
    TreeNode? currentNode = this;
    while (true) {
      if (currentNode == null || currentNode.parent == null) break;
      names.add(currentNode.name);
      currentNode = currentNode.parent;
    }
    names.reversed;
    return names;
  }

  @override
  String toString() {
    return 'TreeNode{name: $name, type: $type, children: ${children.length}}';
  }
}

enum TreeNodeType { text, link, remote }

final TreeNode cRootNode = TreeNode.rootNode();
