import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final style = theme.textTheme.titleMedium;

    return Material(
      elevation: 5,
      child: Container(
        height: 70,
        alignment: Alignment.center,
        color: theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Icon(Icons.arrow_back),
              Icon(Icons.save),
              Expanded(
                child: Text(appState.title, style: style),
              ),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  appState.addRandomItem();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}