import 'package:todotree/services/database/backup_manager.dart';
import 'package:todotree/views/editor/editor_controller.dart';
import 'package:todotree/services/clipboard_manager.dart';
import 'package:todotree/services/app_lifecycle.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/services/main_menu_runner.dart';
import 'package:todotree/services/database/tree_storage.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/services/database/yaml_tree_deserializer.dart';
import 'package:todotree/services/database/yaml_tree_serializer.dart';
import 'package:todotree/views/home/home_state.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';
import 'package:todotree/views/home/home_controller.dart';
import 'package:todotree/views/editor/editor_state.dart';

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
  late final ClipboardManager clipboardManager;
  late final MainMenuRunner mainMenuRunner;
  late final BackupManager backupManager;

  AppFactory();

  void create() {
    homeState = HomeState();
    browserState = BrowserState();
    editorState = EditorState();
    yamlTreeSerializer = YamlTreeSerializer();
    yamlTreeDeserializer = YamlTreeDeserializer();
    backupManager = BackupManager();
    treeStorage = TreeStorage(backupManager);
    clipboardManager = ClipboardManager();
    treeTraverser = TreeTraverser(treeStorage);
    appLifecycle = AppLifecycle(treeStorage, treeTraverser);
    browserController = BrowserController(homeState, browserState, editorState, treeTraverser, clipboardManager, appLifecycle);
    editorController = EditorController(homeState, editorState, treeTraverser);
    editorController.browserController = browserController;
    homeController = HomeController(homeState, treeTraverser, browserController, editorController);
    mainMenuRunner = MainMenuRunner(this);
    logger.debug('AppFactory created');
  }
}
