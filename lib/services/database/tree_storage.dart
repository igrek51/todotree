import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:todotree/app/factory.dart';

import 'package:todotree/services/database/backup_manager.dart';
import 'package:todotree/services/database/saf_helper.dart';
import 'package:todotree/services/database/yaml_tree_deserializer.dart';
import 'package:todotree/services/database/yaml_tree_serializer.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/util/errors.dart';

class TreeStorage {
  BackupManager backupManager;
  SettingsProvider settingsProvider;

  TreeStorage(this.backupManager, this.settingsProvider);

  SafHelper safHelper = SafHelper();

  Future<TreeNode> readDbTree({File? file}) async {
    File nFile = file ?? await _localDbFile;
    final String content = await _readDbString(nFile);
    if (content.isEmpty) {
      InfoService.info('No database file, initializing with a default tree.');
      return createDefaultRootNode();
    }
    final node = YamlTreeDeserializer().deserializeTree(content);
    return node;
  }

  Future<void> writeDbTree(TreeNode root) async {
    logger.debug('saving local database...');
    final String content = YamlTreeSerializer().serializeTree(root);
    File dbFile = await _writeDbString(content);
    logger.info('local database saved to ${dbFile.absolute.path}');
    await backupManager.saveLocalBackup(dbFile);

    final backupLocations = splitLocationPaths(settingsProvider.externalBackupLocation);
    if (backupLocations.isNotEmpty) {
      final stopwatch = Stopwatch()..start();
      for (final backupLocation in backupLocations) {
        await backupManager.saveExternalBackup(dbFile, content, backupLocation, safHelper);
      }
      logger.debug('External backups saved in ${stopwatch.elapsed}');
    }
  }

  Future<String> get _localPath async {
    final Directory directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get _localDbFile async {
    final String path = await _localPath;
    return File('$path/todo.yaml');
  }

  Future<File> _writeDbString(String content) async {
    final file = await _localDbFile;
    return file.writeAsString(content, flush: true);
  }

  Future<String> _readDbString(File file) async {
    try {
      if (!file.existsSync()) {
        logger.warning('database file $file does not exist, loading default tree');
        return '';
      }
      logger.debug('reading local database from ${file.absolute.path}');
      return await file.readAsString();
    } catch (error, stack) {
      throw ContextError('Failed to read file', error, stackTrace: stack);
    }
  }

  Future<void> importDatabaseUi(AppFactory app) async {
    FilePickerResult? fpickResult = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import database file',
      allowMultiple: false,
    );
    if (fpickResult == null) {
      return logger.info('file picker canceled');
    }
    File file = File(fpickResult.files.single.path!);
    await app.treeTraverser.loadFromFile(file);
    app.browserController.renderAll();
    InfoService.info('Tree loaded from ${file.absolute.path}');
  }

  Future<String> grantBackupLocationUri(String locationsString) async {
    List<String> locations = splitLocationPaths(locationsString);

    final Uri? grantedUri = await safHelper.grantFolderAccess();
    if (grantedUri == null) {
      InfoService.info('Cancelled storage permission');
      return locationsString;
    }
    final grantedUriStr = grantedUri.toString();
    if (!locations.contains(grantedUriStr)){
      locations.add(grantedUriStr);
    }
    final newLocationString = locations.join(',\n');

    InfoService.info('Storage permission granted to: $grantedUriStr');
    return newLocationString;
  }

  List<String> splitLocationPaths(String locationString) {
    return locationString.split(RegExp(r'[\n,]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}
