import 'package:todotree/services/info_service.dart';

class ContextError implements Exception {
  final String contextMessage;
  final dynamic innerError;
  final StackTrace? stackTrace;

  ContextError(this.contextMessage, this.innerError, {this.stackTrace});

  @override
  String toString() {
    return '$contextMessage: $innerError';
  }
}

void safeExecute(dynamic Function() function) {
  if (function is Future Function()) {
    function().catchError((e) {
      InfoService.error(e, 'Error handler');
    });
  } else {
    try {
      function();
    } catch (e) {
      InfoService.error(e, 'Error handler');
    }
  }
}

void reportError(Object error, [StackTrace? stackTrace, String? contextMessage]) {
  InfoService.error(error, contextMessage);

  if (error is ContextError && error.stackTrace != null) {
    print('ContextError Stack trace:\n${error.stackTrace}');
  } else if (stackTrace != null) {
    print('Stack trace:\n$stackTrace');
  }
}