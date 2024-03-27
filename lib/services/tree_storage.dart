import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:todotree/services/backup_manager.dart';
import 'package:todotree/services/yaml_tree_deserializer.dart';
import 'package:todotree/services/yaml_tree_serializer.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/services/logger.dart';
import 'package:todotree/util/errors.dart';

class TreeStorage {
  BackupManager backupManager;

  TreeStorage(this.backupManager);

  Future<TreeNode> readDbTree({File? file}) async {
    File nFile = file ?? await _localDbFile;
    final String content = await _readDbString(nFile);
    if (content.isEmpty) {
      logger.warning('empty database file, returning empty tree');
      return TreeNode.rootNode();
    }
    final node = YamlTreeDeserializer().deserializeTree(content);
    return node;
  }

  Future<void> writeDbTree(TreeNode root) async {
    logger.debug('saving local database...');
    final String content = YamlTreeSerializer().serializeTree(root);
    final file = await _writeDbString(content);
    logger.info('local database saved to ${file.absolute.path}');
    await backupManager.saveLocalBackup(file);
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
        logger.warning('database file $file does not exist, loading empty');
        return '';
      }
      logger.debug('reading local database from ${file.absolute.path}');
      return await file.readAsString();
    } catch (error, stack) {
      throw ContextError('Failed to read file', error, stackTrace: stack);
    }
  }
}
