import 'package:flutter/services.dart';

import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';

class MainMenuRunner {
  final BrowserController browserController;
  final TreeTraverser treeTraverser;

  List<ActionMenuItem> _menuActions = [];

  MainMenuRunner(this.browserController, this.treeTraverser);

  List<ActionMenuItem> get menuActions {
    if (_menuActions.isNotEmpty) return _menuActions;

    _menuActions = <ActionMenuItem>[
      ActionMenuItem(
        id: 'exit-without-saving',
        name: '❌ Exit without saving',
        action: () {
          // exit discarding changes
          SystemNavigator.pop();
        },
      ),
      ActionMenuItem(
        id: 'save-and-exit',
        name: '💾 Save and exit',
        action: () {
          treeTraverser.save();
          SystemNavigator.pop();
        },
      ),
      ActionMenuItem(
        id: 'save',
        name: '💾 Save',
        action: () {
          treeTraverser.save();
        },
      ),
      ActionMenuItem(
        id: 'reload',
        name: '🔄 Reload',
        action: () {
        },
      ),
      ActionMenuItem(
        id: 'restore-backup',
        name: '⏮️ Restore backup',
        action: () {
        },
      ),
      ActionMenuItem(
        id: 'import-database',
        name: '📂 Import database',
        action: () {
        },
      ),
      ActionMenuItem(
        id: 'select-all',
        name: '☑️ Select all',
        action: () {
          browserController.selectAll();
        },
      ),
      ActionMenuItem(
        id: 'go-step-up',
        name: '⬆️ Go up',
        action: () {
          browserController.goStepUp();
        },
      ),
      ActionMenuItem(
        id: 'open-drawer',
        name: '🗄️ Open drawer',
        action: () {
        },
      ),
      ActionMenuItem(
        id: 'populate',
        name: 'Debug: Populate',
        action: () {
          browserController.populateItems();
        },
      ),
    ];

    return _menuActions;
  }
}

class ActionMenuItem {
  ActionMenuItem({required this.id, required this.name, required this.action});

  String id;
  String name;
  VoidCallback action;
}
