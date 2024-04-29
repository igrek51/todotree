import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todotree/app/factory.dart';
import 'package:todotree/services/clipboard_manager.dart';
import 'package:todotree/services/database/tree_storage.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/services/main_menu_runner.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/views/editor/editor_controller.dart';
import 'package:todotree/views/home/home_controller.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';
import 'package:todotree/views/home/home_widget.dart';

class AppWidget extends StatefulWidget {
  AppWidget({super.key, required this.appFactory});

  final AppFactory appFactory;

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final providers = [
      ChangeNotifierProvider(create: (context) => widget.appFactory.homeState),
      ChangeNotifierProvider(create: (context) => widget.appFactory.browserState),
      ChangeNotifierProvider(create: (context) => widget.appFactory.editorState),
      Provider<HomeController>(create: (context) => widget.appFactory.homeController),
      Provider<BrowserController>(create: (context) => widget.appFactory.browserController),
      Provider<EditorController>(create: (context) => widget.appFactory.editorController),
      Provider<TreeTraverser>(create: (context) => widget.appFactory.treeTraverser),
      Provider<ClipboardManager>(create: (context) => widget.appFactory.clipboardManager),
      Provider<MainMenuRunner>(create: (context) => widget.appFactory.mainMenuRunner),
      Provider<SettingsProvider>(create: (context) => widget.appFactory.settingsProvider),
      Provider<TreeStorage>(create: (context) => widget.appFactory.treeStorage),
      Provider<AppFactory>(create: (context) => widget.appFactory),
    ];

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'ToDo Tree',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        navigatorKey: navigatorKey,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: Color(0xFF134DA3),
            primary: Color(0xFF1564C0),
            inversePrimary: Color(0xFF134DA3),
            secondary: Color(0xFF6E9AE9),
          ),
        ),
        themeMode: ThemeMode.dark,
        home: HomeWidget(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    logger.debug('App state created');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // on Android's activity stop: inactive, hidden, paused
    // on Android's notification bar swipe: inactive
    switch(state) {
      case AppLifecycleState.resumed:
        logger.debug('App resumed');
      case AppLifecycleState.inactive:
        logger.debug('App inactive');
      case AppLifecycleState.paused:
        logger.debug('App paused');
        widget.appFactory.appLifecycle.onInactive();
      case AppLifecycleState.detached:
        logger.debug('App detached');
      case AppLifecycleState.hidden:
        logger.debug('App hidden');
    }
  }
}
