import 'package:flutter/material.dart';

import 'package:todotree/app/starter.dart';
import 'package:todotree/app/app.dart';
import 'package:todotree/app/factory.dart';

void main() async {
  final appFactory = AppFactory();
  startupApp(appFactory);
  runApp(AppWidget(appFactory: appFactory));
}
