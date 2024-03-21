class TreeItem {
  TreeItem(this.name);

  String name;
  TreeItem? _parent;
  List<TreeItem> children = [];
  String typeName = 'text';
}
