import 'package:flutter/material.dart';
import 'package:todotree/app/factory.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/views/settings/settings_page.dart';

class MainMenuRunner {
  final AppFactory appFactory;

  MainMenuRunner(this.appFactory);

  List<ActionMenuItem> menuActions(BuildContext context) {
    final menuActions = <ActionMenuItem>[
      ActionMenuItem(
        id: 'go-step-up',
        name: '⬆️ Go up',
        action: () {
          appFactory.browserController.goStepUp();
        },
      ),
      ActionMenuItem(
        id: 'enter-random-item',
        name: '🎲 Enter random item',
        action: () {
          appFactory.browserController.enterRandomItem();
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
        id: 'settings',
        name: '⚙️ Settings',
        leading: Icon(Icons.settings),
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
        id: 'import-database',
        name: '📂 Import database',
        action: () async {
          await appFactory.treeStorage.importDatabaseUi(appFactory);
        },
      ),
      ActionMenuItem(
        id: 'restore-backup',
        name: '⏮️ Restore backup',
        action: () async {
          await appFactory.backupManager.restoreBackupUi(appFactory);
        },
      ),
      ActionMenuItem(
        id: 'reload',
        name: '🔄 Reload',
        action: () async {
          await appFactory.treeTraverser.load();
          appFactory.browserController.renderAll();
          InfoService.info('Database loaded');
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
        id: 'save-and-exit',
        name: '💾 Save and exit',
        action: () async {
          await appFactory.homeController.saveAndExit();
        },
      ),
      ActionMenuItem(
        id: 'exit-without-saving',
        name: '❌ Exit discarding changes',
        action: () {
          appFactory.treeTraverser.exitDiscardingChanges();
        },
      ),
    ];
    return menuActions;
  }
}

class ActionMenuItem {
  ActionMenuItem({required this.id, required this.name, required this.action, this.leading});

  String id;
  String name;
  VoidCallback action;
  Icon? leading;
}
