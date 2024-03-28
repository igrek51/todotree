import 'package:flutter/material.dart';

import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todotree/views/components/textfield_dialog.dart';

class SettingsPage extends StatefulWidget {

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  String _externalBackupLocation = '';
  String _userAuthToken = '';
  bool _firstLevelFolders = false;

  SharedPreferences? sharedPreferences;

  readSharedPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences == null) return;
    setState(() {
      _externalBackupLocation = sharedPreferences?.getString('externalBackupLocation') ?? '';
      _userAuthToken = sharedPreferences?.getString('userAuthToken') ?? '';
      _firstLevelFolders = sharedPreferences?.getBool('firstLevelFolders') ?? false;
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
              leading: Icon(Icons.token),
              title: Text('External backup location'),
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
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
