import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todotree/services/error_handler.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/views/components/node_menu_dialog.dart';
import 'package:todotree/views/components/rounded_badge.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';

class BrowserWidget extends StatelessWidget {
  const BrowserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final browserState = context.watch<BrowserState>();
    final browserController =
        Provider.of<BrowserController>(context, listen: false);

    final reorderableList = ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        browserController.reorderNodes(oldIndex, newIndex);
      },
      buildDefaultDragHandles: false,
      children: <Widget>[
        for (final (index, item) in browserState.items.indexed)
          TreeListItemWidget(
            key: Key(identityHashCode(item).toString()),
            index: index,
            treeItem: item,
          ),
        PlusItemWidget(
          key: const Key('plus'),
        ),
      ],
    );
    return reorderableList;
  }
}

class TreeListItemWidget extends StatelessWidget {
  const TreeListItemWidget({
    super.key,
    required this.index,
    required this.treeItem,
  });

  final int index;
  final TreeNode treeItem;

  @override
  Widget build(BuildContext context) {
    final browserController =
        Provider.of<BrowserController>(context, listen: false);
    final browserState = context.watch<BrowserState>();
    final selectionMode = browserState.selectedIndexes.isNotEmpty;
    final isItemSelected = browserState.selectedIndexes.contains(index);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          handleError(() {
            browserController.handleNodeTap(treeItem, index);
          });
        },
        onLongPress: () {
          showNodeOptionsDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                color: const Color(0x55AAAAAA),
                width: 0.5,
                style: BorderStyle.solid,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
          ),
          child: Row(
            children: [
              buildLeftIcon(selectionMode, isItemSelected, browserController),
              buildMiddleText(context),
              buildMoreActionButton(context),
              buildMiddleActionButton(context),
              buildAddAction(browserController),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLeftIcon(bool selectionMode, bool isItemSelected,
      BrowserController browserController) {
    if (selectionMode) {
      return Checkbox(
        value: isItemSelected,
        onChanged: (bool? value) {
          handleError(() {
            browserController.onToggleSelectedNode(index);
          });
        },
      );
    } else {
      return ReorderableDragStartListener(
        index: index,
        child: IconButton(
          iconSize: 30,
          icon: const Icon(Icons.reorder, size: 26),
          onPressed: () {
            browserController.onToggleSelectedNode(index);
          },
        ),
      );
    }
  }

  Widget buildMiddleText(BuildContext context) {
    if (treeItem.isLink) {
      final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            treeTraverser.displayLinkName(treeItem),
            style: TextStyle(
              color: Color(0xFFD2D2D2),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    } else if (treeItem.isLeaf) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(treeItem.name),
        ),
      );
    } else {
      return Expanded(
        child: Row(
          children: [
            Expanded(
              child: Text(
                treeItem.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 5),
            RoundedBadge(text: treeItem.size.toString()),
          ],
        ),
      );
    }
  }

  Widget buildMiddleActionButton(BuildContext context) {
    final browserController =
        Provider.of<BrowserController>(context, listen: false);
    if (treeItem.isLeaf) {
      return IconButton(
        iconSize: 30,
        icon: const Icon(Icons.arrow_right, size: 26),
        onPressed: () {
          handleError(() {
            browserController.goIntoNode(treeItem);
          });
        },
      );
    } else {
      return IconButton(
        iconSize: 30,
        icon: const Icon(Icons.edit, size: 26),
        onPressed: () {
          handleError(() {
            browserController.editNode(treeItem);
          });
        },
      );
    }
  }

  Widget buildMoreActionButton(BuildContext context) {
    return IconButton(
      iconSize: 30,
      icon: const Icon(Icons.more_vert, size: 26),
      onPressed: () {
        showNodeOptionsDialog(context);
      },
    );
  }

  Widget buildAddAction(BrowserController browserController) {
    return IconButton(
      iconSize: 30,
      icon: const Icon(Icons.add, size: 26),
      onPressed: () {
        handleError(() {
          browserController.addNodeAt(index);
        });
      },
    );
  }

  void showNodeOptionsDialog(BuildContext context) {
    final browserController =
        Provider.of<BrowserController>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NodeMenuDialog.buildForNode(context, treeItem, index);
      },
    ).then((value) {
      if (value != null) {
        browserController.runNodeMenuAction(value,
            node: treeItem, position: index);
      }
    });
  }
}

class PlusItemWidget extends StatelessWidget {
  const PlusItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final browserController =
        Provider.of<BrowserController>(context, listen: false);
    final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          handleError(() {
            browserController.addNodeToTheEnd();
          });
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return NodeMenuDialog.buildForPlus(context);
            },
          ).then((value) {
            if (value != null) {
              final plusPosition = treeTraverser.currentParent.size;
              browserController.runNodeMenuAction(value,
                  position: plusPosition);
            }
          });
        },
        child: SizedBox(
          height: 50,
          child: Center(
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
