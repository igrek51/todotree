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
    if (response.statusCode != 200) {
      throw Exception('HTTP response ${response.statusCode} for URL $url: ${response.body}');
    }
    Iterable jsons = json.decode(response.body);
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
}
