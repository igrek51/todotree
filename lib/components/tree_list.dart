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
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have 0 favorites:'),
        ),
        for (var item in appState.items)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(item.name),
            onTap: () {
            },
          ),
      ],
    );
  }
}