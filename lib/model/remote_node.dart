class RemoteNode {
  RemoteNode({
    required this.id,
    required this.name,
    required this.createTimestamp,
    this.deviceId,
  });

  String id;
  String name;
  int createTimestamp;
  String? deviceId;

  factory RemoteNode.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': String id,
        'content': String content,
        'create_timestamp': int createTimestamp,
        'device_id': String? deviceId,
      } =>
        RemoteNode(
          id: id,
          name: content,
          createTimestamp: createTimestamp,
          deviceId: deviceId,
        ),
      _ => throw const FormatException('Failed to parse RemoteNode from JSON.'),
    };
  }

  static List<RemoteNode> fromJsons(Iterable<dynamic> jsons) {
    return jsons.map((json) => RemoteNode.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': name,
      'create_timestamp': createTimestamp,
      'device_id': deviceId,
    };
  }
}
