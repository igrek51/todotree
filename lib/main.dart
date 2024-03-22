import 'package:flutter/material.dart';
import 'package:todotreev2/app/startup.dart';

import 'app/app_widget.dart';
import 'app/factory.dart';

void main() async {
  final appFactory = AppFactory();
  startupApp(appFactory);
  runApp(AppWidget(appFactory: appFactory));
}
