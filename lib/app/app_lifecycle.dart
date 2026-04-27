// Conditional imports - use the correct implementation based on platform
export 'package:todotree/app/app_lifecycle_native.dart'
    if (dart.library.html) 'package:todotree/app/app_lifecycle_web.dart';

// Note: The AppLifecycle class and safeExecute function are exported from the platform-specific implementations
