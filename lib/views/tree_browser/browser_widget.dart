import 'dart:async';

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

    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        browserController.reorderNodes(oldIndex, newIndex);
      },
      buildDefaultDragHandles: false,
      scrollController: browserState.scrollController,
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
  }
}

class TreeListItemWidget extends StatefulWidget {
  const TreeListItemWidget({
    super.key,
    required this.index,
    required this.treeItem,
  });

  final int index;
  final TreeNode treeItem;

  @override
  State<TreeListItemWidget> createState() => _TreeListItemWidgetState();
}

class _TreeListItemWidgetState extends State<TreeListItemWidget> {
  bool highlighted = false;
  bool animationStarted = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    setState(() {
      highlighted = true;
      animationStarted = true;
    });
    _timer = Timer(Duration(milliseconds: 100), () {
      setState(() {
        highlighted = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final browserController =
        Provider.of<BrowserController>(context, listen: false);
    final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
    final browserState = context.watch<BrowserState>();
    final selectionMode = browserState.selectedIndexes.isNotEmpty;
    final isItemSelected = browserState.selectedIndexes.contains(widget.index);
    final shouldBeHighlighted = treeTraverser.focusNode == widget.treeItem;

    if (shouldBeHighlighted && !animationStarted) {
      _startAnimation();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          handleError(() {
            browserController.handleNodeTap(widget.treeItem, widget.index);
          });
        },
        onLongPress: () {
          showNodeOptionsDialog(context);
        },
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          padding: const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            color: highlighted
                ? Color.fromARGB(199, 53, 156, 240)
                : Colors.transparent,
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
            browserController.onToggleSelectedNode(widget.index);
          });
        },
      );
    } else {
      return ReorderableDragStartListener(
        index: widget.index,
        child: IconButton(
          iconSize: 30,
          icon: const Icon(Icons.reorder, size: 26),
          onPressed: () {
            browserController.onToggleSelectedNode(widget.index);
          },
        ),
      );
    }
  }

  Widget buildMiddleText(BuildContext context) {
    if (widget.treeItem.isLink) {
      final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            treeTraverser.displayLinkName(widget.treeItem),
            style: TextStyle(
              color: Color(0xFFD2D2D2),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    } else if (widget.treeItem.isLeaf) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(widget.treeItem.name),
        ),
      );
    } else {
      return Expanded(
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.treeItem.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 5),
            RoundedBadge(text: widget.treeItem.size.toString()),
          ],
        ),
      );
    }
  }

  Widget buildMiddleActionButton(BuildContext context) {
    final browserController =
        Provider.of<BrowserController>(context, listen: false);
    if (widget.treeItem.isLeaf) {
      return IconButton(
        iconSize: 30,
        icon: const Icon(Icons.arrow_right, size: 26),
        onPressed: () {
          handleError(() {
            browserController.goIntoNode(widget.treeItem);
          });
        },
      );
    } else {
      return IconButton(
        iconSize: 30,
        icon: const Icon(Icons.edit, size: 26),
        onPressed: () {
          handleError(() {
            browserController.editNode(widget.treeItem);
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
          browserController.addNodeAt(widget.index);
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
        return NodeMenuDialog.buildForNode(context, widget.treeItem, widget.index);
      },
    ).then((value) {
      if (value != null) {
        browserController.runNodeMenuAction(value,
            node: widget.treeItem, position: widget.index);
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
