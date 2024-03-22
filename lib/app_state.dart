import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'tree/tree_node.dart';

class AppState extends ChangeNotifier {

  String title = 'Dupa123';

  void setTitle(String title) {
    this.title = title;
    notifyListeners();
  }

  var items = <TreeNode>[];

  void addItem(String name) {
    items.add(TreeNode.textNode(name));
    notifyListeners();
  }

  void addRandomItem() {
    const allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    final currentPass = String.fromCharCodes(Iterable.generate(
      16, (_) => allowedChars.codeUnitAt(random.nextInt(allowedChars.length))));
    items.add(TreeNode.textNode(currentPass));
    notifyListeners();
    debugPrint('added random item');
  }
}