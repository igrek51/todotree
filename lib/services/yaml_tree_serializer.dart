import 'package:yaml_writer/yaml_writer.dart';

import '../model/tree_node.dart';
import 'logger.dart';

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
    if (node.type == TreeNodeType.remote) {
      content['name'] = node.name;
    } else if (node.type == TreeNodeType.text) {
      content['name'] = node.name;
    } else if (node.type == TreeNodeType.link) {
      content['target'] = node.targetData;
      if (node.name != '') {
        content['name'] = node.name;
      }
    }
  }
}