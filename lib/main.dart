import 'dart:async';

import 'package:flutter/material.dart';

import 'package:todotree/app/starter.dart';
import 'package:todotree/app/app.dart';
import 'package:todotree/app/factory.dart';
import 'package:todotree/util/errors.dart';

void main() async {
  runZonedGuarded(() {
    final appFactory = AppFactory();
    startupApp(appFactory);
    runApp(AppWidget(appFactory: appFactory));

  }, (error, stackTrace) {
    reportError(error, stackTrace, 'Uncaught exception');
  });
}
