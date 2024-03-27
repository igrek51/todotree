import 'package:flutter/material.dart';

import 'package:todotree/services/logger.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();

class InfoService {

  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: true,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void showInfo(String message) {
    logger.info('UI: $message');
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        showCloseIcon: true,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void showError(Object error, [String? contextMessage]) {
    final String fullMessage;
    if (contextMessage != null) {
      fullMessage = '$contextMessage: $error';
    } else {
      fullMessage = error.toString();
    }
    logger.error(fullMessage);
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(fullMessage),
        showCloseIcon: false,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(minutes: 5),
        action: SnackBarAction(
          label: 'DETAILS',
          onPressed: () {
            showDialog(
              context: navigatorKey.currentContext!,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error Details'),
                  content: Text(fullMessage),
                  actions: <Widget>[
                    TextButton(
                      child: Text('CLOSE'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

}