import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/ui_supervisor.dart';
import 'ui/ui_state.dart';
import 'widgets/home_page.dart';
import 'services/tree_traverser.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final providers = [
    ChangeNotifierProvider(create: (context) => UiState()),
    // Provider<TreeTraverser>(create: (context) => TreeTraverser()),
    Provider<UiSupervisor>(create: (context) => UiSupervisor(context)),
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
