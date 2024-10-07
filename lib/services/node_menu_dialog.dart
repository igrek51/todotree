import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todotree/node_model/tree_node.dart';
import 'package:todotree/services/clipboard_manager.dart';

class NodeMenuDialog {
  static Widget buildForNode(BuildContext context, TreeNode item, int position) {
    final actionChildren = buildNodeActions(context, item, position);
    return AlertDialog(
      title: Text(item.displayName),
      titleTextStyle: TextStyle(fontSize: 18.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 16.0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actionChildren,
        ),
      ),
    );
  }

  static Widget buildForPlus(BuildContext context) {
    final actionChildren = buildPlusActions(context);
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 16.0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actionChildren,
        ),
      ),
    );
  }
}

// actions handled by BrowserController.runNodeMenuAction
List<Widget> buildNodeActions(BuildContext context, TreeNode item, int position) {
  final clipboardManager = Provider.of<ClipboardManager>(context, listen: false);
  final actions = <Widget>[];

  actions.add(ListTile(
    title: Text('➕ Add above'),
    onTap: () {
      Navigator.pop(context, 'add-above');
    },
  ));
  actions.add(ListTile(
    title: Text('❌ Remove'),
    onTap: () {
      Navigator.pop(context, 'remove-nodes');
    },
  ));
  if (item.isLink) {
    actions.add(ListTile(
      title: Text('🗑️ Remove link and target'),
      onTap: () {
        Navigator.pop(context, 'remove-link-and-target');
      },
    ));
  }
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
  if (item.isLink) {
    actions.add(ListTile(
      title: Text('🔍 Locate linked target'),
      onTap: () {
        Navigator.pop(context, 'locate-link');
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
    title: Text('➡️ Go inside'),
    onTap: () {
      Navigator.pop(context, 'go-inside');
    },
  ));
  if (item.type == TreeNodeType.text && (item.displayName.contains(',') || item.displayName.contains('\n'))) {
    actions.add(ListTile(
      title: Text('🔪 Split'),
      onTap: () {
        Navigator.pop(context, 'split');
      },
    ));
  }

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
