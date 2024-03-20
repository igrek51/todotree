import 'package:flutter/material.dart';

import 'tree/tree_item.dart';

class AppState extends ChangeNotifier {
  String title = 'Dupa123';

  void setTitle(String title) {
    this.title = title;
    notifyListeners();
  }

  var items = <TreeItem>[];

  void addItem(String name) {
    items.add(TreeItem(name));
    notifyListeners();
  }
}