import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/info_service.dart';
import '../services/logger.dart';
import '../views/editor/editor_controller.dart';
import '../views/home/home_controller.dart';
import '../views/tree_browser/browser_controller.dart';
import 'factory.dart';
import '../views/home/home_widget.dart';

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
    ];

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'ToDo Tree',
        scaffoldMessengerKey: scaffoldMessengerKey,
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
        home: HomeWidget(),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
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
    switch(state) {
      case AppLifecycleState.resumed:
        logger.debug('App resumed');
      case AppLifecycleState.inactive:
        logger.debug('App inactive');
        widget.appFactory.appLifecycle.onInactive();
      case AppLifecycleState.paused:
        logger.debug('App paused');
      case AppLifecycleState.detached:
        logger.debug('App detached');
      case AppLifecycleState.hidden:
        logger.debug('App hidden');
    }
  }
}
