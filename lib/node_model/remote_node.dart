import 'package:todotree/node_model/tree_node.dart';

class RemoteNode extends TreeNode {
  RemoteNode({
    required super.name,
    required this.localUpdateTimestamp,
    required this.remoteUpdateTimestamp,
    required this.nodeId,
    required this.deviceId,
  }) : super(
          type: TreeNodeType.remote,
        );

  int localUpdateTimestamp;
  int remoteUpdateTimestamp;
  String nodeId;
  String deviceId;

  static RemoteNode newOriginNode(
      String name, int localUpdateTimestamp, int remoteUpdateTimestamp, String nodeId, String deviceId) {
    return RemoteNode(
        name: name,
        localUpdateTimestamp: localUpdateTimestamp,
        remoteUpdateTimestamp: remoteUpdateTimestamp,
        nodeId: nodeId,
        deviceId: deviceId);
  }

  updateChange() {
    localUpdateTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}

class RemoteNodeDto {
  RemoteNodeDto({
    required this.nodeId,
    required this.localUpdateTimestamp,
    required this.remoteUpdateTimestamp,
    required this.deviceId,
    required this.childrenYaml,
  });

  String nodeId;
  int localUpdateTimestamp;
  int remoteUpdateTimestamp;
  String deviceId;
  String childrenYaml;

  factory RemoteNodeDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String nodeId,
        'local_update_timestamp': int localUpdateTimestamp,
        'remote_update_timestamp': int remoteUpdateTimestamp,
        'device_id': String deviceId,
        'children_yaml': String childrenYaml,
      } =>
        RemoteNodeDto(
          nodeId: nodeId,
          localUpdateTimestamp: localUpdateTimestamp,
          remoteUpdateTimestamp: remoteUpdateTimestamp,
          deviceId: deviceId,
          childrenYaml: childrenYaml,
        ),
      _ => throw const FormatException('Failed to parse RemoteNodeDto from JSON.'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': nodeId,
      'local_update_timestamp': localUpdateTimestamp,
      'remote_update_timestamp': remoteUpdateTimestamp,
      'device_id': deviceId,
      'children_yaml': childrenYaml,
    };
  }
}
