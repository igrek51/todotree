import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../services/logger.dart';
import '../tree/tree_node.dart';

class TreeList extends StatelessWidget {
  const TreeList({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    final reorderableList = ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {},
      buildDefaultDragHandles: false,
      children: <Widget>[
        for (final (index, item) in appState.items.indexed)
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          logger.debug('Item tap');
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
              icon: const Icon(Icons.edit, size: 26),
              onPressed: () {
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