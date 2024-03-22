import 'package:flutter/material.dart';

class HomeState extends ChangeNotifier {

  String title = '';
  HomePageView pageView = HomePageView.itemsList;

  void notify() {
    notifyListeners();
  }
}

enum HomePageView { itemsList, itemEditor }
