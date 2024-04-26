import 'package:flutter/material.dart';

class HomeState extends ChangeNotifier {

  HomePageView pageView = HomePageView.treeBrowser;

  void notify() {
    notifyListeners();
  }
}

enum HomePageView { treeBrowser, itemEditor }
