import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/ui_state.dart';
import '../services/ui_supervisor.dart';

class ItemEditor extends StatelessWidget {
  ItemEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<UiState>();
    final uiSupervisor = Provider.of<UiSupervisor>(context);

    return Column(
      children: [
        TextField(
          controller: appState.editTextController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Text',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            uiSupervisor.saveEditedNode();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}