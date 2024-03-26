import 'package:todotree/services/info_service.dart';

void handleError(dynamic Function() function) {
  if (function is Future Function()) {
    function().catchError((e) {
      InfoService.showError(e, 'Error handler');
    });
  } else {
    try {
      function();
    } catch (e) {
      InfoService.showError(e, 'Error handler');
    }
  }
}
