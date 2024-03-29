import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/views/editor/editor_controller.dart';
import 'package:todotree/views/editor/editor_state.dart';

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
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onPressed: () {
                safeExecute(() {
                  editorController.saveNode();
                });
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                safeExecute(() {
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
