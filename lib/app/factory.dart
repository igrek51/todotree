import '../services/tree_traverser.dart';
import 'ui_state.dart';
import '../services/ui_supervisor.dart';

class AppFactory {
  late final UiState uiState;
  late final TreeTraverser treeTraverser;
  late final UiSupervisor uiSupervisor;

  AppFactory() {
    uiState = UiState();
    treeTraverser = TreeTraverser();
    uiSupervisor = UiSupervisor(uiState, treeTraverser);
    print('AppFactory created');
  }
}
