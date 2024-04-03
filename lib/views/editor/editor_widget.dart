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

    final textField = TextField(
      controller: editorState.editTextController,
      autofocus: true,
      keyboardType: editorState.numericKeyboard ? TextInputType.number : TextInputType.multiline,
      maxLines: null,
      focusNode: editorState.textEditFocus,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Text',
      ),
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
      ),
    );

    final rowSaveAuxBtns = [
      FlatButton(
        icon: Icon(Icons.check),
        label: '& Add',
        onPressed: () {
          safeExecute(() {
            editorController.saveAndAddNext();
          });
        },
      ),
      FlatButton(
        icon: Icon(Icons.check),
        label: '& Enter',
        onPressed: () {
          safeExecute(() {
            editorController.saveAndEnter();
          });
        },
      ),
    ];
    final rowSaveBtns = [
      FlatButton(
        icon: Icon(Icons.check),
        label: 'Save',
        expandHeight: true,
        onPressed: () {
          safeExecute(() {
            editorController.saveNode();
          });
        },
      ),
      FlatButton(
        icon: Icon(Icons.cancel),
        label: 'Cancel',
        expandHeight: true,
        onPressed: () {
          safeExecute(() {
            editorController.cancelEdit();
          });
        },
      ),
    ];
    final rowCursorBtns = [
      FlatButton(
        icon: Icon(Icons.skip_previous_rounded),
        onPressed: () {
          safeExecute(() {
            editorController.jumpCursorToStart();
          });
        },
      ),
      FlatButton(
        icon: Icon(Icons.keyboard_arrow_left_rounded),
        onPressed: () {
          safeExecute(() {
            editorController.moveCursorLeft();
          });
        },
      ),
      FlatButton(
        icon: Icon(Icons.select_all),
        onPressed: () {
          safeExecute(() {
            editorController.selectAll();
          });
        },
      ),
      FlatButton(
        icon: Icon(Icons.keyboard_arrow_right_rounded),
        onPressed: () {
          safeExecute(() {
            editorController.moveCursorRight();
          });
        },
      ),
      FlatButton(
        icon: Icon(Icons.skip_next_rounded),
        onPressed: () {
          safeExecute(() {
            editorController.jumpCursorToEnd();
          });
        },
      ),
    ];
    final rowClipboardBtns = [
      FlatButton(
        icon: Icon(Icons.copy),
        onPressed: () {
          safeExecute(() {
            editorController.copyToClipboard();
          });
        },
      ),
      FlatButton(
        icon: Icon(Icons.paste),
        onPressed: () {
          safeExecute(() async {
            await editorController.pasteFromClipboard();
          });
        },
      ),
      FlatButton(
        icon: Icon(Icons.backspace),
        onPressed: () {
          safeExecute(() {
            editorController.keyBackspace();
          });
        },
      ),
      FlatButton(
        icon: Transform.flip(
          flipX: true,
          child: const Icon(Icons.backspace),
        ),
        onPressed: () {
          safeExecute(() {
            editorController.keyDelete();
          });
        },
      ),
    ];
    final rowToolkitBtns = [
      FlatButton(
        label: 'HH:mm',
        onPressed: () {
          safeExecute(() {});
        },
      ),
      FlatButton(
        label: 'dd.MM',
        onPressed: () {
          safeExecute(() {});
        },
      ),
      FlatButton(
        label: '-',
        onPressed: () {
          safeExecute(() {});
        },
      ),
      FlatButton(
        label: ':',
        onPressed: () {
          safeExecute(() {});
        },
      ),
      FlatButton(
        label: '123',
        onPressed: () {
          safeExecute(() {
            editorController.toggleNumericKeyboard(context);
          });
        },
      ),
    ];

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              textField,
              Row(children: rowCursorBtns),
              Row(children: rowClipboardBtns),
              Row(children: rowToolkitBtns),
              Row(children: rowSaveAuxBtns),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rowSaveBtns,
                ),
              ),
            ],
          ),
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
    this.flex = 1,
    this.expandHeight = false,
  });

  final String? label;
  final Widget? icon;
  final VoidCallback onPressed;
  final int flex;
  final bool expandHeight;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (icon == null && label == null) {
      throw ArgumentError('icon and label cannot be null at the same time');
    } else if (icon != null && label != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[icon!, SizedBox(width: 3), Flexible(child: Text(label!))],
      );
    } else if (icon != null) {
      child = icon!;
    } else {
      child = Text(label!);
    }
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color.fromARGB(255, 60, 60, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 10.0),
            minimumSize: Size.fromHeight(55.0),
          ),
          onPressed: () {
            onPressed();
          },
          child: child,
        ),
      ),
    );
  }
}
