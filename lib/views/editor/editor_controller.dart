import '../editor/editor_state.dart';
import '../../services/tree_traverser.dart';
import '../home/home_state.dart';
import '../tree_browser/browser_controller.dart';

class EditorController {
  HomeState homeState;
  EditorState editorState;

  late BrowserController browserController;
  
  TreeTraverser treeTraverser;
  
  EditorController(this.homeState, this.editorState, this.treeTraverser);

  void init() {
  }

  void saveEditedNode() {
    final newName = editorState.editTextController.text;
    editorState.editedNode?.name = newName;
    editorState.editTextController.clear();
    editorState.notify();
    homeState.pageView = HomePageView.treeBrowser;
    homeState.notify();
    browserController.renderItems();
  }
}