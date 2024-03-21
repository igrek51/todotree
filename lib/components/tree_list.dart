import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../services/logger.dart';
import '../tree/tree_item.dart';

class TreeList extends StatelessWidget {
  const TreeList({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return ListView(
      children: [
        for (var item in appState.items)
          TreeListItemWidget(
            treeItem: item,
          ),
        PlusItemWidget(),
      ],
    );
  }
}

class TreeListItemWidget extends StatelessWidget {
  const TreeListItemWidget({
    super.key,
    required this.treeItem,
  });

  final TreeItem treeItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          iconSize: 30,
          icon: const Icon(Icons.reorder, size: 26),
          onPressed: () {
          },
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add),
          ],
        ),
      ),
    );
  }
}