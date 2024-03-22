import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ui_supervisor.dart';
import 'factory.dart';
import '../widgets/home_page.dart';

class AppWidget extends StatelessWidget {
  AppWidget({super.key, required this.appFactory});

  final AppFactory appFactory;

  @override
  Widget build(BuildContext context) {
    final providers = [
      ChangeNotifierProvider(create: (context) => appFactory.uiState),
      Provider<UiSupervisor>(create: (context) => appFactory.uiSupervisor),
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
        home: AppHomePage(),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
