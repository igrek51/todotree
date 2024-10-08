import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:todotree/database/tree_storage.dart';

import 'package:todotree/settings/settings_provider.dart';
import 'package:todotree/components/textfield_dialog.dart';
import 'package:todotree/tree_browser/cursor_state.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _externalBackupLocation = '';
  String _userAuthToken = '';
  bool _firstLevelFolders = false;
  bool _slidableActions = false;
  bool swipeNavigation = false;
  bool largeFont = false;
  bool cursorNavigator = false;
  bool showSaveAndGoInside = false;
  bool showAddNodeButton = false;
  bool showAltNodeButton = false;
  bool slidableMoreAction = false;

  SettingsProvider settingsProvider = SettingsProvider();

  readSharedPrefs() async {
    await settingsProvider.init();
    setState(() {
      _externalBackupLocation = settingsProvider.externalBackupLocation;
      _userAuthToken = settingsProvider.userAuthToken;
      _firstLevelFolders = settingsProvider.firstLevelFolders;
      _slidableActions = settingsProvider.slidableActions;
      swipeNavigation = settingsProvider.swipeNavigation;
      largeFont = settingsProvider.largeFont;
      cursorNavigator = settingsProvider.cursorNavigator;
      showSaveAndGoInside = settingsProvider.showSaveAndGoInside;
      showAddNodeButton = settingsProvider.showAddNodeButton;
      showAltNodeButton = settingsProvider.showAltNodeButton;
      slidableMoreAction = settingsProvider.slidableMoreAction;
    });
  }

  @override
  void initState() {
    super.initState();
    readSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    final treeStorage = Provider.of<TreeStorage>(context, listen: false);
    final cursorState = Provider.of<CursorState>(context, listen: false);
    final settingsList = SettingsList(
      sections: [
        SettingsSection(
          title: Text('Common'),
          tiles: <SettingsTile>[
            SettingsTile.switchTile(
              leading: Icon(Icons.folder),
              title: Text('First level folders'),
              description: Text('Always go inside first-level nodes on tap even if they\'re empty'),
              initialValue: _firstLevelFolders,
              onToggle: (value) {
                settingsProvider.firstLevelFolders = value;
                setState(() {
                  _firstLevelFolders = value;
                });
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.swipe),
              title: Text('Slide menu'),
              description: Text('Slide left or right to perform quick actions on nodes. Exclusive with "Swipe navigation"'),
              initialValue: _slidableActions,
              onToggle: (value) {
                settingsProvider.slidableActions = value;
                setState(() {
                  _slidableActions = value;
                });
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.swipe_right_alt),
              title: Text('Swipe navigation'),
              description: Text('Swipe right to go inside the node. Swipe left to go back. Exclusive with "Swipe menu"'),
              initialValue: swipeNavigation,
              onToggle: (value) {
                settingsProvider.swipeNavigation = value;
                setState(() {
                  swipeNavigation = value;
                });
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.font_download),
              title: Text('Large font'),
              description: Text('Enlarge font size'),
              initialValue: largeFont,
              onToggle: (value) {
                settingsProvider.largeFont = value;
                setState(() {
                  largeFont = value;
                });
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.navigation),
              title: Text('Cursor Navigator'),
              description: Text('Traverse with a one-hand navigator pad.'),
              initialValue: cursorNavigator,
              onToggle: (value) {
                settingsProvider.cursorNavigator = value;
                setState(() {
                  cursorNavigator = value;
                });
                cursorState.cursorNavigator = value;
                cursorState.notify();
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.save),
              title: Text('Save & Go Inside'),
              description: Text('Show Save & Go Inside button in the editor'),
              initialValue: showSaveAndGoInside,
              onToggle: (value) {
                settingsProvider.showSaveAndGoInside = value;
                setState(() {
                  showSaveAndGoInside = value;
                });
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.settings),
              title: Text('Button: Add node above'),
              description: Text('Show "Add above" button for each node. Otherwise, show it after sliding node sideways.'),
              initialValue: showAddNodeButton,
              onToggle: (value) {
                settingsProvider.showAddNodeButton = value;
                setState(() {
                  showAddNodeButton = value;
                });
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.settings),
              title: Text('Button: Alternative node action'),
              description: Text('Show alternative action button for each node. Otherwise, show it after sliding node sideways.'),
              initialValue: showAltNodeButton,
              onToggle: (value) {
                settingsProvider.showAltNodeButton = value;
                setState(() {
                  showAltNodeButton = value;
                });
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.settings),
              title: Text('Slidable more action'),
              description: Text('Show three dots as a slidable action for each node.'),
              initialValue: slidableMoreAction,
              onToggle: (value) {
                settingsProvider.slidableMoreAction = value;
                setState(() {
                  slidableMoreAction = value;
                });
              },
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.token),
              title: Text('User Auth Token (for development)'),
              value: Text(_userAuthToken),
              onPressed: (BuildContext context) {
                TextFieldDialog.show(
                  'User Auth Token',
                  _userAuthToken,
                  (String value) {
                    settingsProvider.userAuthToken = value;
                    setState(() {
                      _userAuthToken = value;
                    });
                  },
                );
              },
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.backup),
              title: Text('External backup locations (comma-separated, folder paths)'),
              value: Text(_externalBackupLocation),
              onPressed: (BuildContext context) {
                TextFieldDialog.show(
                  'External backup locations',
                  _externalBackupLocation,
                  (String value) {
                    settingsProvider.externalBackupLocation = value;
                    setState(() {
                      _externalBackupLocation = value;
                    });
                  },
                );
              },
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.perm_device_info),
              title: Text('Grant permission to a new backup folder'),
              onPressed: (BuildContext context) async {
                final newLocations = await treeStorage.grantBackupLocationUri(settingsProvider.externalBackupLocation);
                settingsProvider.externalBackupLocation = newLocations;
                setState(() {
                  _externalBackupLocation = newLocations;
                });
              },
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings'),
      ),
      body: Center(
        child: settingsList,
      ),
    );
  }
}
