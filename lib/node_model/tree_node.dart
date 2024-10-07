import 'package:collection/collection.dart';

import 'package:todotree/util/strings.dart';

class TreeNode {
  TreeNode({
    required this.name,
    this.parent,
    this.type = TreeNodeType.text,
    List<TreeNode>? children,
  }) : children = children ?? [];

  String name; // text content or link's target path
  TreeNode? parent;
  List<TreeNode> children;
  TreeNodeType type;

  TreeNode clone() {
    final newChildren = children.map((child) => child.clone()).toList();
    final newNode = TreeNode(
      name: name,
      parent: parent,
      children: newChildren,
      type: type,
    );
    for (final child in newChildren) {
      child.parent = newNode;
    }
    return newNode;
  }

  static TreeNode rootNode() {
    return TreeNode(name: '/', type: TreeNodeType.text);
  }

  static TreeNode textNode(String text) {
    return TreeNode(name: text, type: TreeNodeType.text);
  }

  static TreeNode linkNode(String targetData) {
    return TreeNode(name: targetData, type: TreeNodeType.link);
  }

  bool get isText => type == TreeNodeType.text;
  bool get isLink => type == TreeNodeType.link;
  bool get isRemote => type == TreeNodeType.remote;
  bool get isRoot => parent == null;

  int get size => children.length;
  bool get isEmpty => children.isEmpty;
  bool get isLeaf => children.isEmpty;

  int get depth { // root depth is 0
    int depth = 0;
    TreeNode? currentNode = this;
    while (currentNode?.parent != null) {
      depth++;
      currentNode = currentNode?.parent;
    }
    return depth;
  }

  TreeNode getChild(int index) {
    if (index < 0) throw Exception('Invalid position: index < 0');
    if (index >= children.length) throw Exception('Invalid position: index >= items size ($index >= ${children.length})');
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

  TreeNode? findChildByName(String name, {bool lenient = true}) {
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

  List<String> pathNames() { // path names except root
    final names = <String>[];
    TreeNode? currentNode = this;
    while (true) {
      if (currentNode == null || currentNode.parent == null) break;
      names.add(currentNode.name);
      currentNode = currentNode.parent;
    }
    return names.reversed.toList();
  }

  @override
  String toString() {
    return 'TreeNode{name: $name, type: $type, children: ${children.length}}';
  }

  String get displayTargetPath => '/${name.replaceAll('\t', '/')}';

  String get displayName {
    if (type == TreeNodeType.link) {
      return displayTargetPath;
    }
    return name;
  }

  void setLinkTarget(TreeNode targetTextNode) {
    final paths = targetTextNode.pathNames();
    name = paths.join('\t');
  }
}

enum TreeNodeType { text, link, remote }

final TreeNode cRootNode = TreeNode.rootNode();

TreeNode createDefaultRootNode() {
  final root = TreeNode.rootNode();
  root.add(TreeNode.textNode('📁 Threads'));
  root.add(TreeNode.textNode('📒 Quests'));
  root.add(TreeNode.textNode('🕓 Today'));
  root.add(TreeNode.textNode('⏳ Tmp'));
  root.add(TreeNode.textNode('📜 Info'));
  root.add(TreeNode.textNode('🛒 Shopping'));
  return root;
}