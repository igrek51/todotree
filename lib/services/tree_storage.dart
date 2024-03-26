import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:todotree/services/yaml_tree_deserializer.dart';
import 'package:todotree/services/yaml_tree_serializer.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/services/logger.dart';
import 'package:todotree/util/errors.dart';

class TreeStorage {

  Future<String> get _localPath async {
    final Directory directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get localDbFile async {
    final String path = await _localPath;
    return File('$path/todo.yaml');
  }

  Future<File> writeDbString(String content) async {
    final file = await localDbFile;
    return file.writeAsString(content, flush: true);
  }

  Future<String> readDbString() async {
    try {
      final file = await localDbFile;
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

  Future<TreeNode> readDbTree() async {
    final String content = await readDbString();
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
    final file = await writeDbString(content);
    logger.info('local database saved to ${file.absolute.path}');
  }
}