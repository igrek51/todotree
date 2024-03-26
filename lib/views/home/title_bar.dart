import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/error_handler.dart';
import '../../services/main_menu_runner.dart';
import '../tree_browser/browser_controller.dart';
import '../tree_browser/browser_state.dart';
import 'home_controller.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium;

    final browserState = context.watch<BrowserState>();
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final homeController = Provider.of<HomeController>(context, listen: false);
    final mainMenuRunner = Provider.of<MainMenuRunner>(context, listen: false);

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
                  handleError(() {
                    homeController.goBack();
                  });
                },
              ),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.save, size: 28),
                onPressed: () {
                  handleError(() {
                    browserController.saveAndExit();
                  });
                },
              ),
              Expanded(
                child: Text(browserState.title, style: style),
              ),
              PopupMenuButton(
                iconSize: 32,
                icon: const Icon(Icons.more_vert, size: 28),
                onSelected: (value) {
                  final action = mainMenuRunner.menuActions
                      .firstWhere((element) => element.id == value);
                  handleError(() {
                    action.action();
                  });
                },
                itemBuilder: (context) {
                  return mainMenuRunner.menuActions.map((action) {
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
