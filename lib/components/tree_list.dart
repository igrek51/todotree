import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class TreeList extends StatelessWidget {
  const TreeList({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return ListView(
      children: [
        for (var item in appState.items)
          ListTile(
            leading: Icon(Icons.reorder),
            title: Text(item.name),
            onTap: () {
            },
          ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('+'),
          onTap: () {
          },
        ),
      ],
    );
  }
}