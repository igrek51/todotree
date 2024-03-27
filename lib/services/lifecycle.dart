import 'package:todotree/util/errors.dart';
import 'package:todotree/services/tree_storage.dart';
import 'package:todotree/services/tree_traverser.dart';

class AppLifecycle {
  final TreeStorage treeStorage;
  final TreeTraverser treeTraverser;

  AppLifecycle(this.treeStorage, this.treeTraverser);

  void onInactive() {
    safeExecute(() async {
      await treeTraverser.saveIfChanged();
    });
  }
}
