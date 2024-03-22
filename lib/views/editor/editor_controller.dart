import '../editor/editor_state.dart';
import '../../services/tree_traverser.dart';
import '../home/home_state.dart';
import '../tree_browser/browser_controller.dart';

class EditorController {
  HomeState homeState;
  EditorState editorState;
  TreeTraverser treeTraverser;
  BrowserController Function() browserControllerProvider;
  
  EditorController(this.homeState, this.editorState, this.treeTraverser, this.browserControllerProvider);

  void init() {
  }

  void saveEditedNode() {
    final newName = editorState.editTextController.text;
    editorState.editedNode?.name = newName;
    editorState.editTextController.clear();
    homeState.pageView = HomePageView.itemsList;
    browserControllerProvider().renderItems();
  }
}