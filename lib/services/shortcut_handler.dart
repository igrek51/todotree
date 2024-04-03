import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:todotree/util/errors.dart';

import 'package:todotree/views/home/home_controller.dart';

class ShortcutHandler {
  final HomeController homeController;

  ShortcutHandler(this.homeController);

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
      await homeController.goBackOrExit();
    });
  }
}
