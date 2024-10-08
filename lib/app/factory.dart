import 'package:todotree/database/backup_manager.dart';
import 'package:todotree/services/remote_service.dart';
import 'package:todotree/settings/settings_provider.dart';
import 'package:todotree/services/shortcut_handler.dart';
import 'package:todotree/editor/editor_controller.dart';
import 'package:todotree/services/clipboard_manager.dart';
import 'package:todotree/app/app_lifecycle.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/services/main_menu_runner.dart';
import 'package:todotree/database/tree_storage.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/database/yaml_tree_deserializer.dart';
import 'package:todotree/database/yaml_tree_serializer.dart';
import 'package:todotree/home/home_state.dart';
import 'package:todotree/tree_browser/browser_controller.dart';
import 'package:todotree/tree_browser/browser_state.dart';
import 'package:todotree/home/home_controller.dart';
import 'package:todotree/editor/editor_state.dart';
import 'package:todotree/tree_browser/cursor_state.dart';

class AppFactory {
  late final HomeState homeState;
  late final BrowserState browserState;
  late final EditorState editorState;
  late final CursorState cursorState;

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
  late final SettingsProvider settingsProvider;
  late final ShortcutHandler shortcutHandler;
  late final RemoteService remoteService;

  AppFactory();

  void create() {
    settingsProvider = SettingsProvider();
    homeState = HomeState();
    browserState = BrowserState();
    editorState = EditorState();
    cursorState = CursorState();
    yamlTreeSerializer = YamlTreeSerializer();
    yamlTreeDeserializer = YamlTreeDeserializer();
    backupManager = BackupManager();
    treeStorage = TreeStorage(backupManager, settingsProvider);
    clipboardManager = ClipboardManager();
    treeTraverser = TreeTraverser(treeStorage);
    remoteService = RemoteService(settingsProvider, treeTraverser);
    appLifecycle = AppLifecycle(treeStorage, treeTraverser);
    browserController = BrowserController(
        homeState, browserState, treeTraverser, clipboardManager, appLifecycle, settingsProvider, remoteService);
    editorController = EditorController(homeState, editorState, treeTraverser, clipboardManager, remoteService);
    editorController.browserController = browserController;
    browserController.editorController = editorController;
    homeController = HomeController(homeState, treeTraverser, browserController, editorController);
    mainMenuRunner = MainMenuRunner(this);
    shortcutHandler = ShortcutHandler(homeController, editorController);
    logger.debug('AppFactory created');
  }
}
