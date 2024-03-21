import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final style = theme.textTheme.titleMedium;

    final menuActions = <ActionMenuItem>[
      ActionMenuItem(
          id: 'populate',
          name: 'Populate',
          action: () {
            appState.addRandomItem();
          }),
      ActionMenuItem(
          id: 'snackbar',
          name: 'Snackbar',
          action: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Hello, Snackbar!'),
                showCloseIcon: true,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          }),
      ActionMenuItem(
          id: 'exit',
          name: 'Exit',
          action: () {
            SystemNavigator.pop();
          }),
    ];

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

              PopupMenuButton(
                iconSize: 32,
                icon: const Icon(Icons.more_vert, size: 28),
                onSelected: (value) {
                  print('popup menu selected: $value');
                  final action = menuActions.firstWhere((element) => element.id == value);
                  action.action();
                },
                itemBuilder: (context) {
                  return menuActions.map((action) {
                    return PopupMenuItem(
                      value: action.id,
                      child: Text(action.name),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionMenuItem {
  ActionMenuItem({required this.id, required this.name, required this.action});

  String id;
  String name;
  VoidCallback action;
}
