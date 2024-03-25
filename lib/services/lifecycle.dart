import 'tree_storage.dart';
import 'tree_traverser.dart';

class AppLifecycle {
  final TreeStorage treeStorage;
  final TreeTraverser treeTraverser;

  AppLifecycle(this.treeStorage, this.treeTraverser);

  void onInactive() {
    treeTraverser.save();
  }

}