import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, Platform;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idb_shim/idb_browser.dart';

class LocalStorage {
  static LocalStorage? _instance;
  static SharedPreferences? _prefs;
  static bool _webInitialized = false;
  static IdbFactory? _idbFactory;
  static Database? _idbDatabase;
  
  static LocalStorage get instance => _instance ??= LocalStorage._();
  
  LocalStorage._();

  bool get isWeb => kIsWeb;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isDesktop => !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);
  
  Future<void> initialize() async {
    if (isWeb && !_webInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _idbFactory = getIdbFactory();
      if (_idbFactory != null && IdbFactory.supported) {
        await _openDatabase();
      } else {
        _idbFactory = null;
      }
      _webInitialized = true;
    }
  }

  Future<void> _openDatabase() async {
    if (_idbDatabase != null || _idbFactory == null) return;
    _idbDatabase = await _idbFactory!.open(
      'todotree',
      version: 1,
      onUpgradeNeeded: (VersionChangeEvent e) {
        final db = e.database;
        if (!db.objectStoreNames.contains('files')) {
          db.createObjectStore('files', keyPath: 'name');
        }
      },
    );
  }

  StorageFile getFile(String filename) {
    if (isWeb) {
      return _WebStorageFile(filename);
    }
    return _NativeStorageFile(filename);
  }

  Future<String> readFileContent(String filename) async {
    final file = getFile(filename);
    return file.readAsString();
  }

  Future<void> writeFileContent(String filename, String content) async {
    final file = getFile(filename);
    await file.writeAsString(content);
  }

  Future<bool> fileExists(String filename) async {
    final file = getFile(filename);
    return file.exists();
  }

  Future<String?> getPreference(String key) async {
    if (isWeb && _prefs != null) {
      return _prefs!.getString(key);
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setPreference(String key, String value) async {
    if (isWeb && _prefs != null) {
      await _prefs!.setString(key, value);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}

abstract class StorageFile {
  final String name;
  StorageFile(this.name);
  String get path => name;
  
  Future<bool> exists();
  Future<String> readAsString();
  Future<void> writeAsString(String contents);
}

class _NativeStorageFile implements StorageFile {
  final String name;
  
  _NativeStorageFile(this.name);
  
  Future<String> get _path async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, name);
  }
  
  @override
  String get path => name;
  
  @override
  Future<bool> exists() async {
    final f = File(await _path);
    return f.exists();
  }
  
  @override
  Future<String> readAsString() async {
    final f = File(await _path);
    if (!await f.exists()) {
      return '';
    }
    return f.readAsString();
  }
  
  @override
  Future<void> writeAsString(String contents) async {
    final f = File(await _path);
    await f.writeAsString(contents, flush: true);
  }
}

class _WebStorageFile implements StorageFile {
  final String name;
  
  _WebStorageFile(this.name);
  
  @override
  String get path => name;
  
  @override
  Future<bool> exists() async {
    if (LocalStorage._idbDatabase == null) return false;
    final txn = LocalStorage._idbDatabase!.transaction('files', 'readonly');
    final store = txn.objectStore('files');
    final result = await store.getObject(name);
    await txn.completed;
    return result != null;
  }
  
@override
  Future<String> readAsString() async {
    if (LocalStorage._idbDatabase == null) return '';
    final txn = LocalStorage._idbDatabase!.transaction('files', 'readonly');
    final store = txn.objectStore('files');
    final result = await store.getObject(name);
    await txn.completed;
    if (result == null) return '';
    final map = result as Map<String, dynamic>;
    return map['content'] as String? ?? '';
  }

  @override
  Future<void> writeAsString(String contents) async {
    if (LocalStorage._idbDatabase == null) return;
    final txn = LocalStorage._idbDatabase!.transaction('files', 'readwrite');
    final store = txn.objectStore('files');
    await store.put(<String, dynamic>{'name': name, 'content': contents});
    await txn.completed;
  }
}