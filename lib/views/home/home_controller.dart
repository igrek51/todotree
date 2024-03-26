import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/views/editor/editor_controller.dart';
import 'package:todotree/views/home/home_state.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';

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
      browserController.goBack();
    } else if (homeState.pageView == HomePageView.itemEditor) {
      editorController.cancelEdit();
    }
  }
}