import 'package:todotree/node_model/remote_node.dart';
import 'package:yaml_writer/yaml_writer.dart';

import 'package:todotree/node_model/tree_node.dart';
import 'package:todotree/util/logger.dart';

class YamlTreeSerializer {

  String serializeTree(TreeNode root) {
    final stopwatch = Stopwatch()..start();
    final yamlWriter = YamlWriter();
    final serializable = convertToSerializableItem(root);
    final yamlDoc = yamlWriter.write(serializable);
    logger.debug('Tree serialized in ${stopwatch.elapsed}');
    return yamlDoc;
  }

  Map<String, Object> convertToSerializableItem(TreeNode node) {
    final Map<String, Object> content = {};
    
    if (node.type == TreeNodeType.link) {
      content['type'] = 'link';
    } else if (node.type == TreeNodeType.remote) {
      content['type'] = 'remote';
    }
    serializeAttributes(content, node);

    if (node.children.isNotEmpty) {
      final List<Map<String, Object>> children = [];
      for (var child in node.children) {
        children.add(convertToSerializableItem(child));
      }
      content['items'] = children;
    }

    return content;
  }

  void serializeAttributes(Map<String, Object> content, TreeNode node) {
    if (node.type == TreeNodeType.remote && node is RemoteNode) {
      content['name'] = node.name;
      content['local_update_timestamp'] = node.localUpdateTimestamp;
      content['remote_update_timestamp'] = node.remoteUpdateTimestamp;
      content['node_id'] = node.nodeId;
      content['device_id'] = node.deviceId;
    } else if (node.type == TreeNodeType.text) {
      content['name'] = node.name;
    } else if (node.type == TreeNodeType.link) {
      content['target'] = node.name;
    }
  }
}