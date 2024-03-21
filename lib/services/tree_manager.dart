import 'package:flutter/foundation.dart';

class ItemsContainer extends ChangeNotifier {
  double offset = 0;

  setOffset(double offset) {
    this.offset = offset;
    notifyListeners();
  }
}
