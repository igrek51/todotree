import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'browser_controller.dart';
import 'browser_state.dart';
import '../../services/logger.dart';
import '../../model/tree_node.dart';

class BrowserWidget extends StatelessWidget {
  const BrowserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final browserState = context.watch<BrowserState>();

    final reorderableList = ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {},
      buildDefaultDragHandles: false,
      children: <Widget>[
        for (final (index, item) in browserState.items.indexed)
          TreeListItemWidget(
            key: Key(item.name),
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
          browserController.editNode(treeItem);
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
            
            Expanded(
              child: Text(treeItem.name),
            ),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.more_vert, size: 26),
              onPressed: () {
              },
            ),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.arrow_right, size: 26),
              onPressed: () {
                browserController.goIntoNode(treeItem);
              },
            ),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.add, size: 26),
              onPressed: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlusItemWidget extends StatelessWidget {
  const PlusItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          logger.debug('InkWell tap');
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