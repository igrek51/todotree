import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app/ui_state.dart';
import 'item_editor.dart';
import 'tree_list.dart';
import 'title_bar.dart';

class AppHomePage extends StatelessWidget {
  const AppHomePage({super.key});

  @override
  Widget build(BuildContext context) {

    final appState = context.watch<UiState>();
    Widget bodyContent;
    if (appState.appState == AppState.itemsList) {
      bodyContent = TreeList();
    } else {
      bodyContent = ItemEditor();
    }

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
                  child: bodyContent,
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