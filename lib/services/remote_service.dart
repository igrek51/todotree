import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todotree/model/remote_node.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/services/database/yaml_tree_deserializer.dart';
import 'package:todotree/services/database/yaml_tree_serializer.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/services/tree_traverser.dart';

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
    InfoService.info('Pushing updates…');
    await pushDeepNode(localNode);
    localNode.remoteUpdateTimestamp = localNode.localUpdateTimestamp;
    InfoService.info('Remote node updated.');
  }

  void pushUnsavedRemoteChanges() async {
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
