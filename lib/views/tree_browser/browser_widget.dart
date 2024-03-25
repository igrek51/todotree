import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/node_menu_dialog.dart';
import '../components/rounded_badge.dart';
import 'browser_controller.dart';
import 'browser_state.dart';
import '../../model/tree_node.dart';

class BrowserWidget extends StatelessWidget {
  const BrowserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final browserState = context.watch<BrowserState>();
    final browserController = Provider.of<BrowserController>(context);

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
    final browserController = Provider.of<BrowserController>(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (treeItem.isLeaf) {
            browserController.editNode(treeItem);
          } else {
            browserController.goIntoNode(treeItem);
          }
        },
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: IconButton(
                iconSize: 30,
                icon: const Icon(Icons.reorder, size: 26),
                onPressed: () {
                },
              ),
            ),
            buildMiddleText(),
            buildMoreActionButton(context),
            buildMiddleActionButton(context),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.add, size: 26),
              onPressed: () {
                browserController.addNodeAt(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMiddleText() {
    if (treeItem.isLeaf) {
      return Expanded(
        child: Text(treeItem.name),
      );
    }
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

  Widget buildMiddleActionButton(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context);
    if (treeItem.isLeaf) {
      return IconButton(
        iconSize: 30,
        icon: const Icon(Icons.arrow_right, size: 26),
        onPressed: () {
          browserController.goIntoNode(treeItem);
        },
      );
    } else {
      return IconButton(
        iconSize: 30,
        icon: const Icon(Icons.edit, size: 26),
        onPressed: () {
          browserController.editNode(treeItem);
        },
      );
    }
  }

  Widget buildMoreActionButton(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context);
    return IconButton(
      iconSize: 30,
      icon: const Icon(Icons.more_vert, size: 26),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return NodeMenuDialog();
          },
        ).then((value) {
          if (value != null) {
            browserController.runNodeMenuAction(value, treeItem);
          }
        });
      },
    );
  }
}

class PlusItemWidget extends StatelessWidget {
  const PlusItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          browserController.addNodeToTheEnd();
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