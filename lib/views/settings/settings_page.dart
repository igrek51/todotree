import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/views/components/textfield_dialog.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _externalBackupLocation = '';
  String _userAuthToken = '';
  bool _firstLevelFolders = false;
  bool _slidableActions = true;

  SharedPreferences? sharedPreferences;
  SettingsProvider settingsProvider = SettingsProvider();

  readSharedPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences == null) return;
    await settingsProvider.init();
    setState(() {
      _externalBackupLocation = settingsProvider.externalBackupLocation;
      _userAuthToken = settingsProvider.userAuthToken;
      _firstLevelFolders = settingsProvider.firstLevelFolders;
      _slidableActions = settingsProvider.slidableActions;
    });
  }

  @override
  void initState() {
    super.initState();
    readSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    final settingsList = SettingsList(
      sections: [
        SettingsSection(
          title: Text('Common'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.backup),
              title: Text('External backup locations (comma-separated)'),
              value: Text(_externalBackupLocation),
              onPressed: (BuildContext context) {
                TextFieldDialog.show(
                  'External backup location',
                  _externalBackupLocation,
                  (String value) {
                    sharedPreferences?.setString('externalBackupLocation', value);
                    setState(() {
                      _externalBackupLocation = value;
                    });
                  },
                );
              },
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.token),
              title: Text('User Auth Token'),
              value: Text(_userAuthToken),
              onPressed: (BuildContext context) {
                TextFieldDialog.show(
                  'User Auth Token',
                  _userAuthToken,
                  (String value) {
                    sharedPreferences?.setString('userAuthToken', value);
                    setState(() {
                      _userAuthToken = value;
                    });
                  },
                );
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.folder),
              title: Text('First level folders'),
              description: Text('Treat first-level nodes as folders'),
              initialValue: _firstLevelFolders,
              onToggle: (value) {
                sharedPreferences?.setBool('firstLevelFolders', value);
                setState(() {
                  _firstLevelFolders = value;
                });
              },
            ),
            SettingsTile.switchTile(
              leading: Icon(Icons.folder),
              title: Text('Swipe menu'),
              description: Text('Slide left or right to perform quick actions on nodes'),
              initialValue: _slidableActions,
              onToggle: (value) {
                sharedPreferences?.setBool('slidableActions', value);
                setState(() {
                  _slidableActions = value;
                });
              },
            ),
            SettingsTile.navigation(
              leading: Icon(Icons.perm_device_info),
              title: Text('Grant storage permissions'),
              onPressed: (BuildContext context) async {
                var result1 = await Permission.manageExternalStorage.request();
                InfoService.info('Storage permission status: $result1');
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
