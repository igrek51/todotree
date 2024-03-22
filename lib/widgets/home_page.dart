import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tree_list.dart';
import 'titlebar.dart';

class AppHomePage extends StatelessWidget {
  const AppHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TitleBar(),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.onSecondary,
                  child: TreeList(),
                ),
              ),
            ],
          );
        }
      ),
    );
    final statusBarColor = Theme.of(context).colorScheme.inversePrimary;
    return SafeArea(
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: Brightness.light,
        ),
        child: scaffold,
      ),
    );
  }
}