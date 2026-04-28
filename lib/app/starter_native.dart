import 'dart:io';
import 'dart:ui';

import 'package:window_manager/window_manager.dart';
import 'package:todotree/util/logger.dart';

Future<void> initializeWindowManager() async {
  try {
    if (Platform.isLinux) {
      await windowManager.ensureInitialized();
      await windowManager.setSize(const Size(450, 800));
    }
  } catch (e) {
    logger.debug('Window manager not available: $e');
  }
}
