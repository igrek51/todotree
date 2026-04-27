import 'package:flutter/material.dart';

import 'package:todotree/app/factory.dart';
import 'package:todotree/util/errors.dart';
import 'package:todotree/util/logger.dart';

// Conditional imports - will use the correct implementation based on platform
import 'package:todotree/app/starter_native.dart'
    if (dart.library.html) 'package:todotree/app/starter_web.dart'
    as starter_platform;

Future<void> startupApp(AppFactory app) async {
  try {
    // Initialize storage first (especially important for web with IndexedDB)
    await app.initializeStorage();
    
    // Initialize window manager (native stub on native, no-op on web)
    WidgetsFlutterBinding.ensureInitialized();
    await starter_platform.initializeWindowManager();
    
    await app.settingsProvider.init();
    await app.treeTraverser.load();
    app.browserController.renderAll();
    app.shortcutHandler.init();

    kickstartApp(app);
    logger.info('App initialized');
  } catch (error, stackTrace) {
    reportError(error, stackTrace, 'Startup failed');
  }
}

void kickstartApp(AppFactory app) {
  const kickstartVar = String.fromEnvironment('KICKSTART', defaultValue: '0');
  if (kickstartVar != '1') return;
  logger.debug('Kickstarting app...');
}
