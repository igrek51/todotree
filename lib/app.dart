import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/page_home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
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
        home: AppScaffold(),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppHomePage(),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String currentPass = 'Dupa123';

  void getNext() {
    const allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    currentPass = String.fromCharCodes(Iterable.generate(
      10, (_) => allowedChars.codeUnitAt(random.nextInt(allowedChars.length))));
    notifyListeners();
  }

  var favorites = <String>[];

  void toggleFavorite() {
    if (favorites.contains(currentPass)) {
      favorites.remove(currentPass);
    } else {
      favorites.add(currentPass);
    }
    notifyListeners();
  }

  void deleteWord(String word) {
    favorites.remove(word);
    notifyListeners();
  }
}