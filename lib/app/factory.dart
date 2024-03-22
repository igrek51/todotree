import 'package:todotreev2/views/editor/editor_controller.dart';

import '../services/tree_traverser.dart';
import '../views/home/home_state.dart';
import '../views/tree_browser/browser_controller.dart';
import '../views/tree_browser/browser_state.dart';
import '../views/home/home_controller.dart';
import '../views/editor/editor_state.dart';

class AppFactory {
  late final HomeState homeState;
  late final BrowserState browserState;
  late final EditorState editorState;

  late final HomeController homeController;
  late final BrowserController browserController;
  late final EditorController editorController;

  late final TreeTraverser treeTraverser;

  AppFactory() {
    homeState = HomeState();
    browserState = BrowserState();
    editorState = EditorState();
    treeTraverser = TreeTraverser();
    browserController = BrowserController(homeState, browserState, editorState, treeTraverser);
    editorController = EditorController(homeState, editorState, treeTraverser, () => browserController);
    homeController = HomeController(homeState, treeTraverser);
    print('AppFactory created');
  }
}
