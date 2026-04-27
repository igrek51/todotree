import 'package:flutter/services.dart';
import 'package:todotree/database/tree_storage.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/util/errors.dart';

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
    // On web, just exit (no-op since we can't minimize web)
    exitNow();
  }

  void exitNow() {
    logger.debug('Exiting (web - no-op)...');
    // On web, we can't actually exit, so just do nothing
    // SystemNavigator.pop() would not work on web anyway
  }
}
