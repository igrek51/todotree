import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:todotree/util/errors.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/views/editor/editor_controller.dart';

import 'package:todotree/views/home/home_controller.dart';
import 'package:todotree/views/home/home_state.dart';

class ShortcutHandler {
  final HomeController homeController;
  final EditorController editorController;

  ShortcutHandler(this.homeController, this.editorController);

  final MethodChannel _keyEventChannel = MethodChannel('keyboard_event_channel');
  bool get isEnabled => !kIsWeb && Platform.isAndroid;

  void init() {
    if (!isEnabled) return;

    _keyEventChannel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'sendKeyEvent') {
        logger.debug('Received keyboard event: ${call.method}: ${call.arguments}');
        String key = call.arguments['key'];
        _handleKeyEvent(key);
      } else {
        logger.error('Received unknown MethodCall: "${call.method}"');
      }
    });
  }

  void _handleKeyEvent(String key) {
    if (key == 'volume_up') {
      handleVolumeUp();
    } else if (key == 'volume_down') {
      handleVolumeDown();
    }
  }

  void handleVolumeUp() {
    safeExecute(() async {
      await homeController.saveAndExit();
    });
  }

  void handleVolumeDown() {
    safeExecute(() async {
      if (homeController.homeState.pageView == HomePageView.treeBrowser) {
        await homeController.goBackOrExit();
      } else if (homeController.homeState.pageView == HomePageView.itemEditor) {
        editorController.saveNode();
      }
    });
  }
}
