import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotreev2/services/changes_history.dart';

import 'components/home_page.dart';
import 'app_state.dart';
import 'tree/tree_item.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final providers = [
    ChangeNotifierProvider(create: (context) => AppState()),
    ChangeNotifierProvider(create: (context) => ItemsContainer()),
    Provider<ChangesHistory>(create: (context) => ChangesHistory()),
  ];

  @override
  Widget build(BuildContext context) {
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
        home: AppHomePage(),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
