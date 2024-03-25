import 'package:flutter/material.dart';

class NodeMenuDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose an action'),
      contentPadding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('Remove'),
            onTap: () {
              Navigator.pop(context, 'remove-node');
            },
          ),
          ListTile(
            title: Text('Edit'),
            onTap: () {
              Navigator.pop(context, 'edit-node');
            },
          ),
        ],
      ),
    );
  }
}
