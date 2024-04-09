import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:todotree/model/remote_node.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/util/collections.dart';

class RemoteService {
  SettingsProvider settingsProvider;

  RemoteService(this.settingsProvider);

  final String todoApiBase = 'https://todo.igrek.dev/api/v1';
  final String authTokenHeader = 'X-Auth-Token';

  Map<TreeNode, String> remoteItemToId = {};

  Future<List<RemoteNode>> fetchRemoteDtoNodes() async {
    final url = '$todoApiBase/todo';
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
    Iterable jsons = jsonDecode(body);
    final nodes = RemoteNode.fromJsons(jsons);

    remoteItemToId.clear();
    final List<RemoteNode> orderedNodes = nodes.sortedBy<num>((it) => it.createTimestamp);
    return orderedNodes;
  }

  Future<Pair<List<TreeNode>, List<RemoteNode>>> fetchRemoteTreeNodes() async {
    var dtos = await fetchRemoteDtoNodes();
    final textNodes = <TreeNode>[];
    for (final dto in dtos) {
      final textNode = TreeNode.textNode(dto.name);
      textNodes.add(textNode);
      remoteItemToId[textNode] = dto.id;
    }
    return Pair(textNodes, dtos);
  }

  Future<void> removeRemoteItem(TreeNode treeNode) async {
    final id = remoteItemToId[treeNode];
    if (id == null) {
      throw Exception('Unknown remote ID for $treeNode');
    }
    final url = '$todoApiBase/todo/$id';
    final http.Response response = await http.delete(
      Uri.parse(url),
      headers: {
        authTokenHeader: settingsProvider.userAuthToken,
      },
    );
    if (response.statusCode >= 300) {
      throw Exception('HTTP response ${response.statusCode} for URL $url: ${response.body}');
    }
  }

  Future<void> pushRemoteItems(List<TreeNode> treeNodes) async {
    final url = '$todoApiBase/todo/many';
    final payload = treeNodes.map((node) {
      if (!node.isText) throw Exception('Only text nodes are supported for pushing to remote');
      return {
        'id': '',
        'content': node.name,
        'create_timestamp': DateTime.now().millisecondsSinceEpoch / 1000,
        'device_id': '',
      };
    }).toList();
    final http.Response response = await http.post(
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
}
