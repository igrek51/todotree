import 'package:flutter/foundation.dart';

class TreeItem {
  TreeItem(this.name);

  String name;
}

class ItemsContainer extends ChangeNotifier {
  double offset = 0;

  setOffset(double offset) {
    this.offset = offset;
    notifyListeners();
  }
}
