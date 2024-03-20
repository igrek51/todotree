import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'page/home.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
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