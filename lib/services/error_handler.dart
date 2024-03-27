import 'package:todotree/services/info_service.dart';

void handleError(dynamic Function() function) {
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
