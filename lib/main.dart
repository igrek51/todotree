import 'package:flutter/material.dart';
import 'package:todotreev2/app/starter.dart';

import 'app/app.dart';
import 'app/factory.dart';

void main() async {
  final appFactory = AppFactory();
  startupApp(appFactory);
  runApp(AppWidget(appFactory: appFactory));
}
