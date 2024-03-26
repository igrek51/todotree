class ContextError implements Exception {
  final String contextMessage;
  final dynamic innerError;

  ContextError(this.contextMessage, this.innerError);

  @override
  String toString() {
    return '$contextMessage: $innerError';
  }
}