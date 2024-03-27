import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';
import 'package:todotree/services/logger.dart';
import 'package:todotree/util/collections.dart';

const int _localBackupLastVersions = 10;
const int _localBackupLastDays = 14;

class BackupManager {

  final DateFormat formatter = DateFormat('yyyy-MM-dd_HH_mm_ss');
  final RegExp localBackupRegex = RegExp('backup_(\\d{4}-\\d{2}-\\d{2}_\\d{2}_\\d{2}_\\d{2})\\.yaml');

  Future<void> saveLocalBackup(File srcFile) async {
    Directory localBackupsDir = await _localBackupsDir;
    final timestamp = formatter.format(DateTime.now());
    final String backupFileName = '${localBackupsDir.path}/backup_$timestamp.yaml';
    await srcFile.copy(backupFileName);
    await _removeOldBackups(localBackupsDir);
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
    List<_LocalBackup> removalBackups = await _getLocalBackups(localBackupsDir);
    removalBackups = removalBackups.dropLast(_localBackupLastVersions);
    
    for (int i = 0; i < _localBackupLastDays; i++) {
      final DateTime saveDay = DateTime.now().subtract(Duration(days: i));
      // retain newest backup from that day
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

  Future<List<_LocalBackup>> _getLocalBackups(Directory localBackupsDir) async {
    return localBackupsDir
        .listSync()
        .map((e) => File(e.path))
        .where((f) => f.name.startsWith('backup_') && _parseBackupTime(f.name) != null)
        .map((f) => _LocalBackup(f, _parseBackupTime(f.name)!))
        .sortedBy((e) => e.time)
        .toList();
  }

  DateTime? _parseBackupTime(String name) {
    final match = localBackupRegex.firstMatch(name);
    if (match == null) return null;
    return formatter.parse(match.group(1)!);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _LocalBackup {
  final File file;
  final DateTime time;

  _LocalBackup(this.file, this.time);
}

extension FileExtention on FileSystemEntity {
  String get name {
    return path.split('/').last;
  }
}
