import 'package:todotreev2/views/editor/editor_controller.dart';

import '../services/lifecycle.dart';
import '../services/logger.dart';
import '../services/tree_storage.dart';
import '../services/tree_traverser.dart';
import '../services/yaml_tree_deserializer.dart';
import '../services/yaml_tree_serializer.dart';
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
  late final YamlTreeSerializer yamlTreeSerializer;
  late final YamlTreeDeserializer yamlTreeDeserializer;
  late final TreeStorage treeStorage;
  late final AppLifecycle appLifecycle;

  AppFactory() {
    homeState = HomeState();
    browserState = BrowserState();
    editorState = EditorState();
    yamlTreeSerializer = YamlTreeSerializer();
    yamlTreeDeserializer = YamlTreeDeserializer();
    treeStorage = TreeStorage();
    treeTraverser = TreeTraverser(treeStorage);
    appLifecycle = AppLifecycle(treeStorage, treeTraverser);
    browserController = BrowserController(homeState, browserState, editorState, treeTraverser);
    editorController = EditorController(homeState, editorState, treeTraverser);
    browserController.editorController = editorController;
    editorController.browserController = browserController;
    homeController = HomeController(homeState, treeTraverser, browserController, editorController);
    logger.debug('AppFactory created');
  }
}
