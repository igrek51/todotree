import 'dart:io';

import 'package:flutter/services.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:todotree/util/errors.dart';
import 'package:todotree/services/database/tree_storage.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/util/logger.dart';

class AppLifecycle {
  final TreeStorage treeStorage;
  final TreeTraverser treeTraverser;

  AppLifecycle(this.treeStorage, this.treeTraverser);

  void onInactive() {
    safeExecute(() async {
      await treeTraverser.saveIfChanged();
    });
  }

  void minimizeApp() {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        MoveToBackground.moveTaskToBack();
        logger.info('app minimized');
      } on MissingPluginException catch (e) {
        logger.error('MissingPluginException: $e');
        exitNow();
      }
    } else {
      exitNow();
    }
  }

  void exitNow() {
    logger.debug('Exiting...');
    SystemNavigator.pop();
  }
}
