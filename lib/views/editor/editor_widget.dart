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
    final editorController =
        Provider.of<EditorController>(context, listen: false);

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
            FlatButton(label: 'Save', onPressed: () {
              safeExecute(() {
                editorController.saveNode();
              });
            }),
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

class FlatButton extends StatelessWidget {
  const FlatButton({
    super.key,
    this.label,
    this.icon,
    required this.onPressed,
  });

  final String? label;
  final Icon? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (icon == null && label == null) {
      throw ArgumentError('icon and label cannot be null at the same time');
    } else if (icon != null && label != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          icon!,
          SizedBox(width: 3),
          Flexible(child: Text(label!))
        ],
      );
    } else if (icon != null) {
      child = icon!;
    } else {
      child = Text(label!);
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 60, 60, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      onPressed: () {
        onPressed();
      },
      child: child,
    );
  }
}
