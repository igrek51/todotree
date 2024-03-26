import 'info_service.dart';

void handleError(dynamic Function() function) {
  try {
    function();
  } catch (e) {
    InfoService.showError(e, 'Error handler');
  }
}
