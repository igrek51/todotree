import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/views/editor/editor_controller.dart';
import 'package:todotree/views/home/home_state.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';

class HomeController {
  HomeState homeState;

  BrowserController browserController;
  EditorController editorController;

  TreeTraverser treeTraverser;

  HomeController(this.homeState, this.treeTraverser, this.browserController,
      this.editorController);

  Future<void> goBack() async {
    if (homeState.pageView == HomePageView.treeBrowser) {
      if (browserController.treeTraverser.selectionMode) {
        browserController.ensureNoSelectionMode();
      } else {
        browserController.goBack();
      }
    } else if (homeState.pageView == HomePageView.itemEditor) {
      await editorController.quitEditor();
    }
  }

  Future<void> goBackOrExit() async {
    if (homeState.pageView == HomePageView.treeBrowser) {
      if (browserController.treeTraverser.selectionMode) {
        browserController.ensureNoSelectionMode();
      } else {
        final goneBack = browserController.goBack();
        if (!goneBack) {
          await browserController.saveAndExit();
        }
      }
    } else if (homeState.pageView == HomePageView.itemEditor) {
      await editorController.quitEditor();
    }
  }

  Future<void> saveAndExit() async {
    if (homeState.pageView == HomePageView.treeBrowser) {
      browserController.saveAndExit();
    } else if (homeState.pageView == HomePageView.itemEditor) {
      editorController.saveNode();
      browserController.saveAndExit();
    }
  }
}
