import '../../model/tree_node.dart';
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

  void saveNode() {
    if (editorState.editedNode != null) {
      saveEditedNode();
    } else if (editorState.newItemPosition != null) {
      saveNewNode();
    }
  }

  void saveEditedNode() {
    final newName = editorState.editTextController.text;
    editorState.editedNode?.name = newName;
    browserController.renderItems();
    homeState.pageView = HomePageView.treeBrowser;
    homeState.notify();
    editorState.editTextController.clear();
    editorState.notify();
  }

  void saveNewNode() {
    final newName = editorState.editTextController.text;
    final newNode = TreeNode.textNode(newName);
    treeTraverser.addChildToCurrent(newNode, position: editorState.newItemPosition);
    browserController.renderItems();
    homeState.pageView = HomePageView.treeBrowser;
    homeState.notify();
    editorState.editTextController.clear();
    editorState.notify();
  }
}