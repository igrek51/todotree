import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';

import 'package:todotree/app/factory.dart';
import 'package:todotree/util/errors.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/services/logger.dart';

void startupApp(AppFactory app) async {
  try {
    _resizeWindow();
    await app.treeTraverser.load();
    app.homeController.init();
    app.browserController.init();
    app.editorController.init();
    kickstartApp(app);
    logger.info('App initialized');
  } catch (e, s) {
    InfoService.error(Exception(e.toString()), 'Startup failed');
    if (e is ContextError && e.stackTrace != null) {
      print('ContextError Stack trace:\n${e.stackTrace}');
    } else {
      print('Stack trace:\n$s');
    }
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
  // app.treeTraverser.addChildToCurrent(TreeNode.textNode('Item 1'));
  // app.browserController.renderItems();
}
