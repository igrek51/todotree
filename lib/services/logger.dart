class Logger {

  void log(String message) {
    print(message);
  }

  void error(String message, [Object? error]) {
    if (error != null) {
      log('[ERROR] $message: $error');
    } else {
      log('[ERROR] $message');
    }
  }

  void warning(String message) {
    log('[warn] $message');
  }

  void info(String message) {
    log('[info] $message');
  }

  void debug(String message) {
    log('[debug] $message');
  }
}

final logger = Logger();
