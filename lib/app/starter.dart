import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';

import 'package:todotree/app/factory.dart';
import 'package:todotree/util/errors.dart';
import 'package:todotree/services/logger.dart';

void startupApp(AppFactory app) async {
  try {
    _resizeWindow();
    await app.treeTraverser.load();
    app.browserController.init();
    kickstartApp(app);
    logger.info('App initialized');

  } catch (error, stackTrace) {
    reportError(error, stackTrace, 'Startup failed');
  }
}

void _resizeWindow() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setSize(Size(450, 800));
  }
}

void kickstartApp(AppFactory app) {
  const kickstartVar = String.fromEnvironment('KICKSTART', defaultValue: '0');
  if (kickstartVar != '1') return;
  logger.debug('Kickstarting app...');
  // Initialization steps go here
}
