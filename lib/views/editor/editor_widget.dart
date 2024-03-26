import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/error_handler.dart';
import 'editor_controller.dart';
import 'editor_state.dart';

class EditorWidget extends StatelessWidget {
  EditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final editorController = Provider.of<EditorController>(context, listen: false);

    return Column(
      children: [
        TextField(
          controller: editorState.editTextController,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Text',
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                handleError(() {
                  editorController.saveNode();
                });
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                handleError(() {
                  editorController.cancelEdit();
                });
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}
