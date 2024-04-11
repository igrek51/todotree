import 'package:flutter/material.dart';
import 'package:todotree/services/info_service.dart';
import 'package:todotree/util/errors.dart';

class TextFieldDialog {
  static void show(
    String title,
    String initialValue,
    void Function(String) onChange,
  ) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController();
        controller.text = initialValue;
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              autofocus: true,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Value',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                safeExecute(() {
                  onChange(controller.text);
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
