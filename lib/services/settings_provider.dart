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
  set externalBackupLocation(String value) {
    sharedPreferences?.setString('externalBackupLocation', value);
  }

  String get userAuthToken {
    return sharedPreferences?.getString('userAuthToken') ?? '';
  }
  set userAuthToken(String value) {
    sharedPreferences?.setString('userAuthToken', value);
  }

  bool get firstLevelFolders {
    return sharedPreferences?.getBool('firstLevelFolders') ?? true;
  }
  set firstLevelFolders(bool value) {
    sharedPreferences?.setBool('firstLevelFolders', value);
  }

  bool get slidableActions {
    return sharedPreferences?.getBool('slidableActions') ?? false;
  }
  set slidableActions(bool value) {
    sharedPreferences?.setBool('slidableActions', value);
  }

  bool get swipeNavigation {
    return sharedPreferences?.getBool('swipeNavigation') ?? false;
  }
  set swipeNavigation(bool value) {
    sharedPreferences?.setBool('swipeNavigation', value);
  }

  bool get largeFont {
    return sharedPreferences?.getBool('largeFont') ?? false;
  }
  set largeFont(bool value) {
    sharedPreferences?.setBool('largeFont', value);
  }
}