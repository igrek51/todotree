import '../editor/editor_controller.dart';
import '../editor/editor_state.dart';
import '../../services/tree_traverser.dart';
import '../../model/tree_node.dart';
import '../../util/strings.dart';
import '../home/home_state.dart';
import '../tree_browser/browser_state.dart';

class BrowserController {
  HomeState homeState;
  BrowserState browserState;
  EditorState editorState;

  late EditorController editorController;

  TreeTraverser treeTraverser;
  
  BrowserController(this.homeState, this.browserState, this.editorState, this.treeTraverser);

  void init() {
    renderItems();
    renderTitle();
  }

  void renderTitle() {
    browserState.title = treeTraverser.currentParent.name;
    browserState.notify();
  }

  void renderItems() {
    browserState.items = treeTraverser.currentParent.children.toList();
    browserState.notify();
  }

  void addRandomItem() {
    final name = randomName();
    treeTraverser.addChild(TreeNode.textNode(name));
    print('Added item: $name');
    renderItems();
  }

  void populateItems() {
    for (int i = 0; i < 10; i++) {
      addRandomItem();
    }
  }

  void editNode(TreeNode node) {
    editorState.editTextController.text = node.name;
    editorState.editedNode = node;
    editorState.notify();
    homeState.pageView = HomePageView.itemEditor;
    homeState.notify();
  }

  void goUp() {
    try {
      treeTraverser.goUp();
      renderItems();
      renderTitle();
    } on NoSuperItemException {
      // Can't go higher than root
    }
  }

  void goIntoNode(TreeNode node) {
    treeTraverser.goTo(node);
    renderItems();
    renderTitle();
  }
}