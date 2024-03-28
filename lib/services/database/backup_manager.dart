import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';
import 'package:todotree/app/factory.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/util/files.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/util/collections.dart';
import 'package:todotree/views/components/options_dialog.dart';

const int _localBackupLastVersions = 10;
const int _localBackupLastDays = 14;

class BackupManager {
  final DateFormat fileDateFormat = DateFormat('yyyy-MM-dd_HH_mm_ss');
  final DateFormat displayDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final RegExp localBackupRegex =
      RegExp('backup_(\\d{4}-\\d{2}-\\d{2}_\\d{2}_\\d{2}_\\d{2})\\.yaml');

  Future<void> saveLocalBackup(File srcFile) async {
    Directory localBackupsDir = await _localBackupsDir;
    final timestamp = fileDateFormat.format(DateTime.now());
    final String backupFileName =
        '${localBackupsDir.path}/backup_$timestamp.yaml';
    await srcFile.copy(backupFileName);
    logger.debug('local backup saved to $backupFileName');
    await _removeOldBackups(localBackupsDir);
  }

  Future<void> saveExternalBackups(File srcFile, String locations) async {
    final List<String> locationList = locations
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    for (final location in locationList) {
      File bakFile;
      if (FileSystemEntity.isDirectorySync(location)) {
        bakFile = File('$location/${srcFile.name}');
      } else {
        bakFile = File(location);
      }
      await saveExternalBackup(srcFile, bakFile);
    }
  }

  Future<void> saveExternalBackup(File srcFile, File backupFile) async {
    await srcFile.copy(backupFile.absolute.path);
    logger.debug('external backup saved to ${backupFile.absolute.path}');
  }

  Future<String> get _localPath async {
    final Directory directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<Directory> get _localBackupsDir async {
    final String path = await _localPath;
    return await Directory('$path/backups').create();
  }

  Future<void> _removeOldBackups(Directory localBackupsDir) async {
    List<LocalBackup> removalBackups = await listLocalBackups(localBackupsDir);
    removalBackups = removalBackups.dropFirst(_localBackupLastVersions);

    for (int i = 0; i < _localBackupLastDays; i++) {
      final DateTime saveDay = DateTime.now().subtract(Duration(days: i));
      // retain latest backup from that day
      for (int j = 0; j < removalBackups.length; j++) {
        final backup = removalBackups[j];
        if (_isSameDay(backup.time, saveDay)) {
          removalBackups.remove(backup);
          break;
        }
      }
    }

    // remove other backups
    for (final backup in removalBackups) {
      await backup.file.delete();
      logger.info('Old backup removed: ${backup.file}');
    }
  }

  Future<List<LocalBackup>> listLocalBackups(Directory localBackupsDir) async {
    return localBackupsDir
        .listSync()
        .map((e) => File(e.path))
        .where((f) =>
            f.name.startsWith('backup_') && _parseBackupTime(f.name) != null)
        .map((f) => LocalBackup(f, _parseBackupTime(f.name)!))
        .sortedBy((e) => e.time)
        .reversed
        .toList();
  }

  DateTime? _parseBackupTime(String name) {
    final match = localBackupRegex.firstMatch(name);
    if (match == null) return null;
    return fileDateFormat.parse(match.group(1)!);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> restoreBackupUi(AppFactory app) async {
    final backups = await listLocalBackups(await _localBackupsDir);
    List<OptionItem> options = backups
        .map((e) => OptionItem(
              id: e.file.path,
              name: displayDateFormat.format(e.time),
              action: () async {
                await restoreBackup(app, e.file);
              },
            ))
        .toList();
    OptionsDialog.show('Choose local backup', options);
  }

  Future<void> restoreBackup(AppFactory app, File backupFile) async {
    await app.treeTraverser.loadFromFile(backupFile);
    app.treeTraverser.unsavedChanges = true;
    app.browserController.renderAll();
    InfoService.info('Backup restored from ${backupFile.absolute.path}');
  }
}

class LocalBackup {
  final File file;
  final DateTime time;

  LocalBackup(this.file, this.time);
}
