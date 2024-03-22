import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../views/editor/editor_controller.dart';
import '../views/home/home_controller.dart';
import '../views/tree_browser/browser_controller.dart';
import 'factory.dart';
import '../views/home/home_widget.dart';

class AppWidget extends StatelessWidget {
  AppWidget({super.key, required this.appFactory});

  final AppFactory appFactory;

  @override
  Widget build(BuildContext context) {
    final providers = [
      ChangeNotifierProvider(create: (context) => appFactory.homeState),
      ChangeNotifierProvider(create: (context) => appFactory.browserState),
      ChangeNotifierProvider(create: (context) => appFactory.editorState),
      Provider<HomeController>(create: (context) => appFactory.homeController),
      Provider<BrowserController>(create: (context) => appFactory.browserController),
      Provider<EditorController>(create: (context) => appFactory.editorController),
    ];

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'ToDo Tree',
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
}
