import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';

import '../model/tree_node.dart';
import '../services/logger.dart';
import 'factory.dart';

void startupApp(AppFactory app) async {
  _resizeWindow();
  await app.treeTraverser.load();
  app.homeController.init();
  app.browserController.init();
  app.editorController.init();
  kickstartApp(app);
  logger.info('App initialized');
}

void _resizeWindow() async {
  if (!kIsWeb && Platform.isLinux) {
    WidgetsFlutterBinding.ensureInitialized();
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