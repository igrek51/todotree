import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  SharedPreferences? sharedPreferences;

  Future<SharedPreferences> getSharedPrefs() async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    return sharedPreferences!;
  }

  Future<String> get externalBackupLocation async {
    return (await getSharedPrefs()).getString('externalBackupLocation') ?? '';
  }

  Future<String> get userAuthToken async {
    return (await getSharedPrefs()).getString('userAuthToken') ?? '';
  }

  Future<bool> get firstLevelFolders async {
    return (await getSharedPrefs()).getBool('firstLevelFolders') ?? false;
  }
}