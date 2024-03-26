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