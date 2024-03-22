import '../../services/tree_traverser.dart';
import 'home_state.dart';

class HomeController {
  HomeState homeState;
  TreeTraverser treeTraverser;
  
  HomeController(this.homeState, this.treeTraverser);

  void init() {
    renderTitle();
  }

  void renderTitle() {
    homeState.title = treeTraverser.currentParent.name;
    homeState.notify();
  }
}