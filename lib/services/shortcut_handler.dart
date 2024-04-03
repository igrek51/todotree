import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:todotree/util/errors.dart';
import 'package:todotree/views/editor/editor_controller.dart';

import 'package:todotree/views/home/home_controller.dart';
import 'package:todotree/views/home/home_state.dart';

class ShortcutHandler {
  final HomeController homeController;
  final EditorController editorController;

  ShortcutHandler(this.homeController, this.editorController);

  bool get isEnabled => !kIsWeb && Platform.isAndroid;

  void handleVolumeUp() {
    if (!isEnabled) return;
    safeExecute(() async {
      await homeController.saveAndExit();
    });
  }

  void handleVolumeDown() {
    if (!isEnabled) return;
    safeExecute(() async {
      if (homeController.homeState.pageView == HomePageView.treeBrowser) {
        await homeController.goBackOrExit();
      } else if (homeController.homeState.pageView == HomePageView.itemEditor) {
        editorController.saveNode();
      }
    });
  }
}
