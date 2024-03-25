import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_manager/window_manager.dart';

import '../services/logger.dart';
import 'factory.dart';

void startupApp(AppFactory app) async {
  _resizeWindow();
  app.homeController.init();
  app.browserController.init();
  app.editorController.init();
  logger.info('App initialized');
}

void _resizeWindow() async {
  if (!kIsWeb && Platform.isLinux) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    await windowManager.setSize(Size(450, 800));
  }
}