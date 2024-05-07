import 'dart:io';

import 'package:flutter/services.dart';
import 'package:todotree/util/errors.dart';
import 'package:todotree/services/database/tree_storage.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/util/logger.dart';

class AppLifecycle {
  final TreeStorage treeStorage;
  final TreeTraverser treeTraverser;

  AppLifecycle(this.treeStorage, this.treeTraverser);

  static const minimizeChannel = MethodChannel('minimize_channel');

  void onInactive() {
    safeExecute(() async {
      await treeTraverser.saveIfChanged();
    });
  }

  Future<void> minimizeApp() async {
    if (Platform.isAndroid) {
      try {
        await _minimizeNative();
      } on MissingPluginException catch (e) {
        logger.error('MissingPluginException: $e');
        exitNow();
      }
    } else {
      exitNow();
    }
  }

  Future<void> _minimizeNative() async {
    try {
      await minimizeChannel.invokeMethod<bool>('minimize');
      logger.info('app minimized');
    } on PlatformException catch (e) {
      logger.error('failed to minimize native app: PlatformException: $e');
      exitNow();
    }
  }

  void exitNow() {
    logger.debug('Exiting...');
    SystemNavigator.pop();
  }
}
