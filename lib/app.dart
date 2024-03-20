import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/home_page.dart';
import 'app_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'ToDo Tree',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: Color(0xFF134DA3),
            primary: Color(0xFF1564C0),
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
