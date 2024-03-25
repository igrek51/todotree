import '../../services/tree_traverser.dart';
import '../editor/editor_controller.dart';
import '../tree_browser/browser_controller.dart';
import 'home_state.dart';

class HomeController {
  HomeState homeState;

  BrowserController browserController;
  EditorController editorController;
  
  TreeTraverser treeTraverser;
  
  HomeController(this.homeState, this.treeTraverser, this.browserController, this.editorController);

  void init() {
  }
  
  void goBack() {
    if (homeState.pageView == HomePageView.treeBrowser) {
      browserController.goUp();
    } else if (homeState.pageView == HomePageView.itemEditor) {
      editorController.cancelEdit();
    }
  }
}