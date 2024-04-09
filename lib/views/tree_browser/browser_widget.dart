import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/util/collections.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/views/components/node_menu_dialog.dart';
import 'package:todotree/views/components/rounded_badge.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';

const double _iconButtonInternalSize = 24;
const double _iconButtonPaddingVertical = 8;
const double _iconButtonPaddingHorizontal = 4;

class BrowserWidget extends StatelessWidget {
  const BrowserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final browserState = context.watch<BrowserState>();
    final browserController = Provider.of<BrowserController>(context, listen: false);

    return SlidableAutoCloseBehavior(
      child: ReorderableListView.builder(
        onReorder: (int oldIndex, int newIndex) {
          browserController.reorderNodes(oldIndex, newIndex);
        },
        buildDefaultDragHandles: false,
        scrollController: browserState.scrollController,
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return Material(
            elevation: 4.0,
            color: Color.fromARGB(90, 190, 190, 190),
            child: child,
          );
        },
        itemCount: browserState.items.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index < browserState.items.length) {
            final item = browserState.items[index];
            return TreeListItemWidget(
              key: Key(identityHashCode(item).toString()),
              position: index,
              treeItem: item,
              browserController: browserController,
            );
          } else {
            return PlusItemWidget(
              key: const Key('plus'),
            );
          }
        },
      ),
    );
  }
}

class TreeListItemWidget extends StatefulWidget {
  const TreeListItemWidget({
    super.key,
    required this.position,
    required this.treeItem,
    required this.browserController,
  });

  final int position;
  final TreeNode treeItem;
  final BrowserController browserController;

  @override
  State<TreeListItemWidget> createState() => _TreeListItemWidgetState();
}

class _TreeListItemWidgetState extends State<TreeListItemWidget> {
  bool highlighted = false;
  double animationTopOffset = 0;
  Timer? _timer;
  final key = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context == null) return;
      final box = context.findRenderObject() as RenderBox;
      final height = box.size.height;
      widget.browserController.itemHeights[widget.position] = height;
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation(BrowserState browserState, BrowserController browserController, TreeTraverser treeTraverser) {
    if (browserState.animationsStarted[widget.position] ?? true) return;
    final shouldBeHighlighted = treeTraverser.focusNode == widget.treeItem;
    const shouldBeMoved = false; // (browserController.topOffsetAnimations[widget.position] ?? 0) != 0;
    if (!shouldBeHighlighted && !shouldBeMoved) return;

    browserState.animationsStarted[widget.position] = true;
    setState(() {
      if (shouldBeHighlighted) {
        highlighted = true;
      }
      if (shouldBeMoved) {
        animationTopOffset = browserController.topOffsetAnimations[widget.position] ?? 0;
      }
    });
    _timer = Timer(Duration(milliseconds: 10), () {
      browserController.topOffsetAnimations[widget.position] = 0;
      setState(() {
        highlighted = false;
        animationTopOffset = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final browserState = context.watch<BrowserState>();
    final selectionMode = browserState.selectedIndexes.isNotEmpty;
    final isItemSelected = browserState.selectedIndexes.contains(widget.position);

    _startAnimation(browserState, browserController, treeTraverser);

    var inkWell = InkWell(
      key: key,
      onTap: () {
        safeExecute(() async {
          await browserController.handleNodeTap(widget.treeItem, widget.position);
        });
      },
      onLongPress: () {
        showNodeOptionsDialog(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        padding: const EdgeInsets.all(0.0),
        margin: EdgeInsets.only(top: animationTopOffset),
        decoration: BoxDecoration(
          color: highlighted ? Color.fromARGB(199, 53, 156, 240) : Colors.transparent,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: const Color(0x44888888),
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
            selectionMode ? null : buildMiddleActionButton(context),
            selectionMode ? null : buildAddButton(browserController),
          ].filterNotNull(),
        ),
      ),
    );

    if (!settingsProvider.slidableActions) {
      return Material(
        color: Colors.transparent,
        child: inkWell,
      );
    }

    var slidable = Slidable(
      groupTag: '0',
      key: ValueKey(widget.key),
      endActionPane: ActionPane(
        motion: BehindMotion(),
        extentRatio: 0.25,
        openThreshold: 0.2,
        closeThreshold: 0.2,
        children: [
          SlidableAction(
            padding: EdgeInsets.zero,
            onPressed: (BuildContext context) {
              safeExecute(() {
                browserController.removeOneNode(widget.treeItem);
              });
            },
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: inkWell,
    );
    return Material(
      color: Colors.transparent,
      child: slidable,
    );
  }

  Widget buildLeftIcon(bool selectionMode, bool isItemSelected, BrowserController browserController) {
    if (selectionMode) {
      return SizedBox(
        width: 40,
        child: Checkbox(
          value: isItemSelected,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (bool? value) {
            safeExecute(() {
              browserController.onToggleSelectedNode(widget.position);
            });
          },
        ),
      );
    } else {
      return ReorderableDragStartListener(
        index: widget.position,
        child: IconButton(
          icon: const Icon(
            Icons.unfold_more,
            size: _iconButtonInternalSize,
            color: Colors.white,
          ),
          padding: EdgeInsets.all(_iconButtonPaddingVertical),
          constraints: BoxConstraints(),
          style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          onPressed: () {
            browserController.onToggleSelectedNode(widget.position);
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            treeTraverser.displayLinkName(widget.treeItem),
            style: TextStyle(
              color: Color(0xFFD2D2D2),
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    } else if (widget.treeItem.isLeaf) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            widget.treeItem.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  widget.treeItem.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3),
            RoundedBadge(text: widget.treeItem.size.toString()),
          ],
        ),
      );
    }
  }

  Widget buildMoreActionButton(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.more_vert,
        size: _iconButtonInternalSize,
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(vertical: _iconButtonPaddingVertical, horizontal: _iconButtonPaddingHorizontal),
      constraints: BoxConstraints(),
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      onPressed: () {
        showNodeOptionsDialog(context);
      },
    );
  }

  Widget buildMiddleActionButton(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context, listen: false);
    if (widget.treeItem.isLeaf) {
      return IconButton(
        icon: const Icon(
          Icons.arrow_right,
          size: _iconButtonInternalSize,
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(vertical: _iconButtonPaddingVertical, horizontal: _iconButtonPaddingHorizontal),
        constraints: BoxConstraints(),
        style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        onPressed: () {
          safeExecute(() {
            browserController.goIntoNode(widget.treeItem);
          });
        },
      );
    } else {
      return IconButton(
        icon: const Icon(
          Icons.edit,
          size: _iconButtonInternalSize,
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(vertical: _iconButtonPaddingVertical, horizontal: _iconButtonPaddingHorizontal),
        constraints: BoxConstraints(),
        style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        onPressed: () {
          safeExecute(() {
            browserController.editNode(widget.treeItem);
          });
        },
      );
    }
  }

  Widget buildAddButton(BrowserController browserController) {
    return IconButton(
      icon: const Icon(
        Icons.add,
        size: _iconButtonInternalSize,
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(vertical: _iconButtonPaddingVertical, horizontal: _iconButtonPaddingHorizontal),
      constraints: BoxConstraints(),
      style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      onPressed: () {
        safeExecute(() {
          browserController.addNodeAt(widget.position);
        });
      },
    );
  }

  void showNodeOptionsDialog(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NodeMenuDialog.buildForNode(context, widget.treeItem, widget.position);
      },
    ).then((value) {
      if (value != null) {
        browserController.runNodeMenuAction(value, node: widget.treeItem, position: widget.position);
      }
    });
  }
}

class PlusItemWidget extends StatelessWidget {
  const PlusItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          safeExecute(() {
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
              browserController.runNodeMenuAction(value, position: plusPosition);
            }
          });
        },
        child: SizedBox(
          height: 45,
          child: Center(
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
