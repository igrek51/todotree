import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todotree/node_model/remote_node.dart';
import 'package:todotree/node_model/tree_node.dart';
import 'package:todotree/database/yaml_tree_deserializer.dart';
import 'package:todotree/database/yaml_tree_serializer.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/settings/settings_provider.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/util/logger.dart';

class RemoteService {
  SettingsProvider settingsProvider;
  TreeTraverser treeTraverser;

  RemoteService(this.settingsProvider, this.treeTraverser);

  final String todoApiBase = 'https://todo.igrek.dev/api/v1';
  final String authTokenHeader = 'X-Auth-Token';

  Future<RemoteNode> fetchRemoteNode(RemoteNode localNode) async {
    final dto = await fetchRemoteNodeDto(localNode);
    final remoteNode = RemoteNode.newOriginNode(localNode.name, dto.remoteUpdateTimestamp,
        dto.remoteUpdateTimestamp, localNode.nodeId, localNode.deviceId);
    final yamlNode = YamlTreeDeserializer().deserializeTree(dto.childrenYaml);
    for (final child in yamlNode.children) {
      remoteNode.add(child);
    }
    return remoteNode;
  }

  Future<RemoteNodeDto> fetchRemoteNodeDto(RemoteNode localNode) async {
    if (localNode.nodeId.isEmpty) {
      throw Exception('Remote node has no node_id');
    }
    final url = '$todoApiBase/deep/node/${localNode.nodeId}';
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        authTokenHeader: settingsProvider.userAuthToken,
      },
    );
    if (response.statusCode >= 300) {
      throw Exception('HTTP response ${response.statusCode} for URL $url: ${response.body}');
    }
    String body = Utf8Decoder().convert(response.bodyBytes);
    dynamic json = jsonDecode(body);
    final dto = RemoteNodeDto.fromJson(json);
    return dto;
  }

  Future<void> pushDeepNode(RemoteNode localNode) async {
    if (localNode.nodeId.isEmpty) {
      throw Exception('Remote node has no node_id');
    }
    final url = '$todoApiBase/deep/node/${localNode.nodeId}';
    final childrenYaml = YamlTreeSerializer().serializeTree(localNode);
    final payload = {
      'id': localNode.nodeId,
      'local_update_timestamp': localNode.localUpdateTimestamp,
      'remote_update_timestamp': localNode.remoteUpdateTimestamp,
      'device_id': localNode.deviceId,
      'children_yaml': childrenYaml,
    };
    final http.Response response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        authTokenHeader: settingsProvider.userAuthToken,
      },
      body: json.encode(payload),
    );
    if (response.statusCode >= 300) {
      throw Exception('HTTP response ${response.statusCode} for URL $url: ${response.body}');
    }
  }

  Future<void> updateRemoteNode(RemoteNode localNode) async {
    logger.info('Pushing updates to remote…');
    await pushDeepNode(localNode);
    localNode.remoteUpdateTimestamp = localNode.localUpdateTimestamp;
    InfoService.info('Changes saved to remote.');
  }

  void checkUnsavedRemoteChanges() async {
    TreeNode node = treeTraverser.currentParent;
    while (true) {
      final parent = node.parent;
      if (node.isRemote && node is RemoteNode) {
        node.updateChange();
        await updateRemoteNode(node);
        return;
      } else if (parent == null) {
        return;
      } else {
        node = parent;
      }
    }
  }
}
