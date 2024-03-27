import 'package:todotree/model/tree_node.dart';
import 'package:todotree/views/editor/editor_state.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/views/home/home_state.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';

class EditorController {
  HomeState homeState;
  EditorState editorState;

  late BrowserController browserController;
  
  TreeTraverser treeTraverser;
  
  EditorController(this.homeState, this.editorState, this.treeTraverser);

  void saveNode() {
    if (editorState.editedNode != null) {
      saveEditedNode();
    } else if (editorState.newItemPosition != null) {
      saveNewNode();
    }
    treeTraverser.unsavedChanges = true;
  }

  void saveEditedNode() {
    final newName = editorState.editTextController.text;
    editorState.editedNode?.name = newName;
    treeTraverser.focusNode = editorState.editedNode;
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

  void cancelEdit() {
    treeTraverser.focusNode = null;
    homeState.pageView = HomePageView.treeBrowser;
    homeState.notify();
    editorState.editTextController.clear();
    editorState.notify();
  }
}