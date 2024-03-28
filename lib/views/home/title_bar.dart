import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/services/main_menu_runner.dart';
import 'package:todotree/views/components/rounded_badge.dart';
import 'package:todotree/views/home/home_controller.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium;

    final browserState = context.watch<BrowserState>();
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
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: !browserState.atRoot,
                child: IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: () {
                    safeExecute(() {
                      homeController.goBack();
                    });
                  },
                ),
              ),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.save, size: 28),
                onPressed: () {
                  safeExecute(() async {
                    await homeController.saveAndExit();
                  });
                },
              ),
              Expanded(
                child: _buildTitle(context, browserState),
              ),
              PopupMenuButton(
                iconSize: 32,
                icon: const Icon(Icons.more_vert, size: 28),
                onSelected: (value) {
                  final action = mainMenuRunner
                      .menuActions(context)
                      .firstWhere((element) => element.id == value);
                  safeExecute(() {
                    action.action();
                  });
                },
                itemBuilder: (context) {
                  return mainMenuRunner.menuActions(context).map((action) {
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

  Widget _buildTitle(BuildContext context, BrowserState browserState) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium;
    List<Widget> rowChildren = [
      Flexible(
        child: Text(
          browserState.title,
          style: style,
          overflow: TextOverflow.fade,
        ),
      ),
    ];
    if (browserState.items.isNotEmpty) {
      rowChildren.add(SizedBox(width: 5));
      rowChildren.add(RoundedBadge(text: browserState.items.length.toString()));
    }
    return Row(
      children: rowChildren,
    );
  }
}
