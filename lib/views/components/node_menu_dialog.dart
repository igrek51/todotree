import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todotree/model/tree_node.dart';
import 'package:todotree/services/clipboard_manager.dart';

class NodeMenuDialog {
  static Widget buildForNode(
      BuildContext context, TreeNode item, int position) {
    final actionChildren = buildNodeActions(context, item, position);
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: actionChildren,
      ),
    );
  }

  static Widget buildForPlus(BuildContext context) {
    final actionChildren = buildPlusActions(context);
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: actionChildren,
      ),
    );
  }
}

// actions handled by BrowserController.runNodeMenuAction
List<Widget> buildNodeActions(
    BuildContext context, TreeNode item, int position) {
  final clipboardManager = Provider.of<ClipboardManager>(context, listen: false);
  final actions = <Widget>[];

  if (item.parent?.type != TreeNodeType.remote) {
    actions.add(ListTile(
      title: Text('❌ Remove'),
      onTap: () {
        Navigator.pop(context, 'remove-nodes');
      },
    ));
  }
  if (item.parent?.type == TreeNodeType.remote) {
    actions.add(ListTile(
      title: Text('❌ Remove from remote'),
      onTap: () {
        Navigator.pop(context, 'remove-remote-node');
      },
    ));
  }
  if (item.isLink) {
    actions.add(ListTile(
      title: Text('🗑️ Remove link and target'),
      onTap: () {
        Navigator.pop(context, 'remove-link-and-target');
      },
    ));
  }
  actions.add(ListTile(
    title: Text('✔️ Select'),
    onTap: () {
      Navigator.pop(context, 'select-node');
    },
  ));
  actions.add(ListTile(
    title: Text('☑️ Select all'),
    onTap: () {
      Navigator.pop(context, 'select-all');
    },
  ));
  actions.add(ListTile(
    title: Text('✏️ Edit'),
    onTap: () {
      Navigator.pop(context, 'edit-node');
    },
  ));
  actions.add(ListTile(
    title: Text('➕ Add above'),
    onTap: () {
      Navigator.pop(context, 'add-above');
    },
  ));
  actions.add(ListTile(
    title: Text('✂️ Cut'),
    onTap: () {
      Navigator.pop(context, 'cut');
    },
  ));
  actions.add(ListTile(
    title: Text('📄 Copy'),
    onTap: () {
      Navigator.pop(context, 'copy');
    },
  ));
  actions.add(ListTile(
    title: Text('📋 Paste above'),
    onTap: () {
      Navigator.pop(context, 'paste-above');
    },
  ));
  if (!clipboardManager.isClipboardEmpty) {
    actions.add(ListTile(
      title: Text('🔗 Paste as link'),
      onTap: () {
        Navigator.pop(context, 'paste-as-link');
      },
    ));
  }
  if (item.type == TreeNodeType.text && item.displayName.contains(',')) {
    actions.add(ListTile(
      title: Text('🔪 Split by comma'),
      onTap: () {
        Navigator.pop(context, 'split');
      },
    ));
  }
  actions.add(ListTile(
    title: Text('📤 Push to remote'),
    onTap: () {
      Navigator.pop(context, 'push-to-remote');
    },
  ));

  return actions;
}

List<Widget> buildPlusActions(BuildContext context) {
  final clipboardManager = Provider.of<ClipboardManager>(context, listen: false);
  final actions = <Widget>[];

  actions.add(ListTile(
    title: Text('☑️ Select all'),
    onTap: () {
      Navigator.pop(context, 'select-all');
    },
  ));
  actions.add(ListTile(
    title: Text('➕ Add above'),
    onTap: () {
      Navigator.pop(context, 'add-above');
    },
  ));
  actions.add(ListTile(
    title: Text('📋 Paste above'),
    onTap: () {
      Navigator.pop(context, 'paste-above');
    },
  ));
  if (!clipboardManager.isClipboardEmpty) {
    actions.add(ListTile(
      title: Text('🔗 Paste as link'),
      onTap: () {
        Navigator.pop(context, 'paste-as-link');
      },
    ));
  }

  return actions;
}
