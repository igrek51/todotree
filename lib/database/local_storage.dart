import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:todotree/util/logger.dart';

class LocalStorage {
  static LocalStorage? _instance;
  static SharedPreferences? _prefs; // Only for preferences, not file storage
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
      _idbFactory = getIdbFactory();
      if (_idbFactory == null || !IdbFactory.supported) {
        throw Exception('IndexedDB is not supported in this browser');
      }
      try {
        await _openDatabase();
        logger.info('IndexedDB initialized successfully');
      } catch (e) {
        logger.error('Failed to initialize IndexedDB: $e');
        rethrow;
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
  @override
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
  @override
  final String name;
  
  _WebStorageFile(this.name);
  
  @override
  String get path => name;
  
  Database get _database {
    if (LocalStorage._idbDatabase == null) {
      throw Exception('IndexedDB not initialized. Call LocalStorage.instance.initialize() first.');
    }
    return LocalStorage._idbDatabase!;
  }
  
  @override
  Future<bool> exists() async {
    try {
      final txn = _database.transaction('files', 'readonly');
      final store = txn.objectStore('files');
      final result = await store.getObject(name);
      await txn.completed;
      return result != null;
    } catch (e) {
      logger.error('Error checking if file exists in IndexedDB: $e');
      rethrow;
    }
  }
  
  @override
  Future<String> readAsString() async {
    try {
      final txn = _database.transaction('files', 'readonly');
      final store = txn.objectStore('files');
      final result = await store.getObject(name);
      await txn.completed;
      if (result == null) return '';
      final map = result as Map<String, dynamic>;
      return map['content'] as String? ?? '';
    } catch (e) {
      logger.error('Error reading file from IndexedDB: $e');
      rethrow;
    }
  }

  @override
  Future<void> writeAsString(String contents) async {
    try {
      final txn = _database.transaction('files', 'readwrite');
      final store = txn.objectStore('files');
      await store.put(<String, dynamic>{'name': name, 'content': contents});
      await txn.completed;
      logger.debug('Saved to IndexedDB: $name (${contents.length} bytes)');
    } catch (e) {
      logger.error('Error writing file to IndexedDB: $e');
      rethrow;
    }
  }
}