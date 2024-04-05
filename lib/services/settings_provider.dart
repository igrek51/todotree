import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  SharedPreferences? sharedPreferences;

  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> getSharedPrefs() async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    return sharedPreferences!;
  }

  String get externalBackupLocation {
    return sharedPreferences?.getString('externalBackupLocation') ?? '';
  }

  String get userAuthToken {
    return sharedPreferences?.getString('userAuthToken') ?? '';
  }

  bool get firstLevelFolders {
    return sharedPreferences?.getBool('firstLevelFolders') ?? true;
  }

  bool get slidableActions {
    return sharedPreferences?.getBool('slidableActions') ?? true;
  }
}