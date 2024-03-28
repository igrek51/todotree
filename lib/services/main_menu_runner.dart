import 'package:flutter/material.dart';
import 'package:todotree/app/factory.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/views/settings/settings_page.dart';

class MainMenuRunner {
  final AppFactory appFactory;

  List<ActionMenuItem> _menuActions = [];

  MainMenuRunner(this.appFactory);

  List<ActionMenuItem> menuActions(BuildContext context) {
    if (_menuActions.isNotEmpty) return _menuActions;

    _menuActions = <ActionMenuItem>[
      ActionMenuItem(
        id: 'exit-without-saving',
        name: '❌ Exit discarding changes',
        action: () {
          appFactory.treeTraverser.exitDiscardingChanges();
        },
      ),
      ActionMenuItem(
        id: 'save-and-exit',
        name: '💾 Save and exit',
        action: () async {
          await appFactory.homeController.saveAndExit();
        },
      ),
      ActionMenuItem(
        id: 'save',
        name: '💾 Save',
        action: () async {
          await appFactory.treeTraverser.save();
          InfoService.info('Database saved');
        },
      ),
      ActionMenuItem(
        id: 'reload',
        name: '🔄 Reload',
        action: () {},
      ),
      ActionMenuItem(
        id: 'restore-backup',
        name: '⏮️ Restore backup',
        action: () async {
          await appFactory.backupManager.restoreBackupUi(appFactory);
        },
      ),
      ActionMenuItem(
        id: 'import-database',
        name: '📂 Import database',
        action: () async {
          await appFactory.treeStorage.importDatabaseUi(appFactory);
        },
      ),
      ActionMenuItem(
        id: 'select-all',
        name: '☑️ Select all',
        action: () {
          appFactory.browserController.selectAll();
        },
      ),
      ActionMenuItem(
        id: 'go-step-up',
        name: '⬆️ Go up',
        action: () {
          appFactory.browserController.goStepUp();
        },
      ),
      ActionMenuItem(
        id: 'open-drawer',
        name: '🗄️ Open drawer',
        action: () {},
      ),
      ActionMenuItem(
        id: 'settings',
        name: 'Settings',
        action: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(),
            ),
          );
        },
      ),
      ActionMenuItem(
        id: 'populate',
        name: 'Debug: Populate',
        action: () {
          appFactory.browserController.populateItems();
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
