import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todotreev2/services/ui_supervisor.dart';

import '../app/ui_state.dart';
import '../services/info_service.dart';
import '../services/logger.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium;
    
    final appState = context.watch<UiState>();
    final uiSupervisor = Provider.of<UiSupervisor>(context);

    final menuActions = <ActionMenuItem>[
      ActionMenuItem(
          id: 'populate',
          name: 'Populate',
          action: () {
            uiSupervisor.populateItems();
          }),
      ActionMenuItem(
          id: 'snackbar',
          name: 'Snackbar',
          action: () {
            InfoService.showInfo(context, 'Hello, Snackbar!');
          }),
      ActionMenuItem(
          id: 'exit',
          name: 'Exit',
          action: () {
            SystemNavigator.pop();
          }),
    ];

    return Material(
      elevation: 20,
      child: Container(
        height: 65,
        alignment: Alignment.center,
        color: theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.arrow_back, size: 28),
                onPressed: () {
                },
              ),
              
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.save, size: 28),
                onPressed: () {
                },
              ),

              Expanded(
                child: Text(appState.title, style: style),
              ),

              PopupMenuButton(
                iconSize: 32,
                icon: const Icon(Icons.more_vert, size: 28),
                onSelected: (value) {
                  logger.debug('popup menu selected: $value');
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
