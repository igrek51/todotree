import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/settings/settings_provider.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/services/main_menu_runner.dart';
import 'package:todotree/components/rounded_badge.dart';
import 'package:todotree/home/home_controller.dart';
import 'package:todotree/home/home_state.dart';
import 'package:todotree/tree_browser/browser_state.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final browserState = context.watch<BrowserState>();
    final homeState = context.watch<HomeState>();
    final homeController = Provider.of<HomeController>(context, listen: false);
    final mainMenuRunner = Provider.of<MainMenuRunner>(context, listen: false);

    return Container(
      height: 60,
      alignment: Alignment.center,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: !browserState.atRoot || homeState.pageView == HomePageView.itemEditor,
              child: IconButton(
                iconSize: 56,
                padding: EdgeInsets.all(12),
                icon: const Icon(
                  Icons.arrow_back,
                  size: 32,
                  color: Colors.white,
                ),
                onPressed: () {
                  safeExecute(() async {
                    await homeController.goBack();
                  });
                },
              ),
            ),
            IconButton(
              iconSize: 56,
              padding: EdgeInsets.all(12),
              icon: const Icon(
                Icons.save,
                size: 32,
                color: Colors.white,
              ),
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
              iconSize: 52,
              padding: EdgeInsets.all(10),
              icon: const Icon(
                Icons.more_vert,
                size: 32,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return mainMenuRunner.menuActions(context).map((action) {
                  return PopupMenuItem(
                    value: action.id,
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      action.name,
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  );
                }).toList();
              },
              onSelected: (value) {
                final action = mainMenuRunner.menuActions(context).firstWhere((element) => element.id == value);
                safeExecute(() {
                  action.action();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, BrowserState browserState) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final fontSize = switch (settingsProvider.largeFont) {
      true => 18.0,
      false => 16.0,
    };
    if (browserState.selectedIndexes.isNotEmpty) {
      return Text(
        '${browserState.selectedIndexes.length} selected',
        overflow: TextOverflow.fade,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      );
    }
    List<Widget> rowChildren = [
      Flexible(
        child: Text(
          browserState.title,
          overflow: TextOverflow.fade,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    ];
    if (browserState.items.isNotEmpty) {
      rowChildren.add(SizedBox(width: 4));
      rowChildren.add(RoundedBadge(text: browserState.items.length.toString()));
    }
    return Row(
      children: rowChildren,
    );
  }
}
