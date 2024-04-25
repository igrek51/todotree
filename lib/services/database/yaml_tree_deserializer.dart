import 'package:todotree/model/remote_node.dart';
import 'package:yaml/yaml.dart';

import 'package:todotree/model/tree_node.dart';
import 'package:todotree/util/logger.dart';

class YamlTreeDeserializer {

  TreeNode deserializeTree(String data) {
    final stopwatch = Stopwatch()..start();
    final YamlMap yamlDoc = loadYaml(data) as YamlMap;
    final rootNode = mapNodeToTreeItem(yamlDoc);
    logger.debug('Tree deserialized in ${stopwatch.elapsed}');
    return rootNode;
  }

  TreeNode mapNodeToTreeItem(YamlMap node) {
    final type = node['type'] as String? ?? 'text';

    TreeNode treeItem;
    switch (type) {
      case '/':
        treeItem = TreeNode.rootNode();
      case 'text':
        final name = node['name'] as String;
        treeItem = TreeNode.textNode(name);
      case 'remote':
        final name = node['name'] as String;
        final localUpdateTimestamp = (node['local_update_timestamp'] ?? 0) as int;
        final remoteUpdateTimestamp = (node['remote_update_timestamp'] ?? 0) as int;
        final nodeId = (node['node_id'] ?? 0) as String;
        final deviceId = (node['device_id'] ?? 0) as String;
        treeItem = RemoteNode.newOriginNode(name, localUpdateTimestamp, remoteUpdateTimestamp, nodeId, deviceId);
      case 'link':
        final target = node['target'] as String;
        treeItem = TreeNode.linkNode(target);
      default:
        throw Exception('Unknown item type: $type');
    }

    if (node['items'] != null) {
      final YamlList items = node['items'] as YamlList;
      for (var child in items) {
        treeItem.add(mapNodeToTreeItem(child));
      }
    }
    return treeItem;
  }
}
