import 'package:todotree/app/factory.dart';
import 'package:todotree/model/remote_node.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/views/components/textfield_dialog.dart';

class Commander {
  Commander(this.app);

  final AppFactory app;

  Future<void> promptCommand() async {
    final cmd = await TextFieldDialog.inputText('Enter command');
    if (cmd == null) return;
    switch(cmd.trim()) {
      case 'remote add':
        await _addRemote();
      default:
        InfoService.info('Unknown command: $cmd');
    }
  }

  Future<void> _addRemote() async {
    var name = await TextFieldDialog.inputText('Node name');
    if (name == null) return;
    final nodeId = await TextFieldDialog.inputText('Node ID');
    if (nodeId == null) return;
    final deviceId = await TextFieldDialog.inputText('Device ID');
    if (deviceId == null) return;

    name = name.trim();
    if (name.isEmpty) {
      return InfoService.error('Name cannot be blank.');
    }

    final remoteNode = RemoteNode.newOriginNode(name, 0, 0, nodeId, deviceId);

    app.treeTraverser.addChildToCurrent(remoteNode);
    app.browserController.renderItems();
    InfoService.info('Added Remote node: $name');
  }
}