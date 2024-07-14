import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/util/collections.dart';
import 'package:todotree/util/errors.dart';
import 'package:todotree/views/editor/editor_controller.dart';
import 'package:todotree/views/editor/editor_state.dart';

class EditorWidget extends StatelessWidget {
  EditorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = context.watch<EditorState>();
    final editorController = Provider.of<EditorController>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

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
        fontSize: 19,
        fontFamily: 'RobotoMono',
      ),
      onSubmitted: (value) => editorController.concludeNumericInput(),
    );

    final rowCursorBtns = [
      FlatButton(
        icon: Icon(Icons.skip_previous_rounded),
        onPressed: () {
          editorController.jumpCursorToStart();
        },
      ),
      FlatButton(
        icon: Icon(Icons.keyboard_arrow_left_rounded),
        onPressed: () {
          editorController.moveCursorLeft();
        },
      ),
      FlatButton(
        icon: Icon(Icons.select_all),
        tooltip: 'Select all',
        onPressed: () {
          editorController.selectAll();
        },
      ),
      FlatButton(
        icon: Icon(Icons.keyboard_arrow_right_rounded),
        onPressed: () {
          editorController.moveCursorRight();
        },
      ),
      FlatButton(
        icon: Icon(Icons.skip_next_rounded),
        onPressed: () {
          editorController.jumpCursorToEnd();
        },
      ),
    ];

    final rowClipboardBtns = [
      FlatButton(
        icon: Icon(Icons.copy),
        onPressed: () {
          editorController.copyToClipboard();
        },
      ),
      FlatButton(
        icon: Icon(Icons.paste),
        onPressed: () async {
          await editorController.pasteFromClipboard();
        },
      ),
      FlatButton(
        icon: Icon(Icons.backspace),
        onPressed: () {
          editorController.keyBackspace();
        },
      ),
      FlatButton(
        icon: Transform.flip(
          flipX: true,
          child: const Icon(Icons.backspace),
        ),
        onPressed: () {
          editorController.keyDelete();
        },
      ),
    ];

    final rowToolkitBtns = [
      FlatButton(
        label: '.',
        tooltip: 'Insert dot',
        onPressed: () {
          editorController.insertDot();
        },
      ),
      FlatButton(
        label: ':',
        tooltip: 'Insert colon',
        onPressed: () {
          editorController.insertColon();
        },
      ),
      FlatButton(
        label: '-',
        tooltip: 'Insert dash',
        onPressed: () {
          editorController.insertDash();
        },
      ),
      FlatButton(
        icon: Icon(Icons.keyboard),
        label: editorState.numericKeyboard ? 'ABC' : '123',
        tooltip: 'Toggle numeric / alphabetical keyboard',
        onPressed: () {
          editorController.toggleNumericKeyboard(context);
        },
      ),
    ];

    final rowSaveAuxBtns = [
      FlatButton(
        icon: Icon(Icons.cancel),
        label: 'Cancel',
        onPressed: () {
          editorController.cancelEdit();
        },
      ),
      settingsProvider.showSaveAndGoInside
          ? FlatButton(
              icon: Icon(Icons.check),
              label: '& Go Inside',
              tooltip: 'Save and enter into this item',
              onPressed: () {
                editorController.saveAndEnter();
              },
            )
          : null,
      FlatButton(
        icon: Icon(Icons.check),
        label: '& Next',
        tooltip: 'Save and add a next item right after',
        onPressed: () {
          editorController.saveAndAddNext();
        },
      ),
    ].filterNotNull();

    final rowSaveBtns = [
      FlatButton(
        icon: Icon(Icons.check),
        label: 'Save',
        expandHeight: true,
        onPressed: () {
          editorController.saveNode();
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
    this.tooltip = '',
  });

  final String? label;
  final Widget? icon;
  final dynamic Function() onPressed;
  final int flex;
  final bool expandHeight;
  final String tooltip;

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

    Widget button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 60, 60, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        minimumSize: Size.fromHeight(50.0),
      ),
      onPressed: () {
        safeExecute(onPressed);
      },
      child: child,
    );

    if (tooltip.isNotEmpty) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(2.0),
        child: button,
      ),
    );
  }
}
