import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/ui_state.dart';

class ItemEditor extends StatelessWidget {
  ItemEditor({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<UiState>();

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Text',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            appState.appState = AppState.itemsList;
            appState.notify();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}