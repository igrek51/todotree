import 'package:todotree/services/error_handler.dart';
import 'package:todotree/services/tree_storage.dart';
import 'package:todotree/services/tree_traverser.dart';

class AppLifecycle {
  final TreeStorage treeStorage;
  final TreeTraverser treeTraverser;

  AppLifecycle(this.treeStorage, this.treeTraverser);

  void onInactive() {
    handleError(() async {
      await treeTraverser.saveIfChanged();
    });
  }
}
