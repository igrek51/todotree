import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/util/collections.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/views/components/highlight_indicator.dart';
import 'package:todotree/views/components/node_menu_dialog.dart';
import 'package:todotree/views/components/ripple_indicator.dart';
import 'package:todotree/views/components/rounded_badge.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';

const double _iconButtonInternalSize = 24;
const double _iconButtonPaddingVertical = 8;
const double _iconButtonPaddingHorizontal = 4;

class BrowserWidget extends StatefulWidget {
  const BrowserWidget({super.key});

  @override
  State<BrowserWidget> createState() => _BrowserWidgetState();
}

class _BrowserWidgetState extends State<BrowserWidget> {
  final GlobalKey<RippleIndicatorState> _rippleIndicatorKey = GlobalKey<RippleIndicatorState>();
  final GlobalKey<HighlightIndicatorState> _highlightIndicatorKey = GlobalKey<HighlightIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    var stack = Stack(
      children: [
        RippleIndicator(key: _rippleIndicatorKey),
        HighlightIndicator(key: _highlightIndicatorKey),
        TreeListView(rippleIndicatorKey: _rippleIndicatorKey, highlightIndicatorKey: _highlightIndicatorKey),
      ],
    );

    if (!settingsProvider.slidableActions) {
      return stack;
    }
    return SlidableAutoCloseBehavior(
      child: stack,
    );
  }
}

class TreeListView extends StatelessWidget {
  const TreeListView({
    super.key,
    required this.rippleIndicatorKey,
    required this.highlightIndicatorKey,
  });

  final GlobalKey<RippleIndicatorState> rippleIndicatorKey;
  final GlobalKey<HighlightIndicatorState> highlightIndicatorKey;

  @override
  Widget build(BuildContext context) {
    final browserState = context.watch<BrowserState>();
    final browserController = Provider.of<BrowserController>(context, listen: false);

    return ReorderableListView.builder(
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
            rippleIndicatorKey: rippleIndicatorKey,
            highlightIndicatorKey: highlightIndicatorKey,
          );
        } else {
          return PlusItemWidget(
            key: const Key('plus'),
          );
        }
      },
    );
  }
}

class TreeListItemWidget extends StatefulWidget {
  const TreeListItemWidget({
    super.key,
    required this.position,
    required this.treeItem,
    required this.rippleIndicatorKey,
    required this.highlightIndicatorKey,
  });

  final int position;
  final TreeNode treeItem;
  final GlobalKey<RippleIndicatorState> rippleIndicatorKey;
  final GlobalKey<HighlightIndicatorState> highlightIndicatorKey;

  @override
  State<TreeListItemWidget> createState() => _TreeListItemWidgetState();
}

class _TreeListItemWidgetState extends State<TreeListItemWidget> {
  double animationTopOffset = 0;
  Timer? _timer;
  final _inkWellKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _inkWellKey.currentContext;
      if (context == null) return;
      final box = context.findRenderObject() as RenderBox;
      final height = box.size.height;
      final browserController = Provider.of<BrowserController>(context, listen: false);
      browserController.itemHeights[widget.position] = height;

      Offset globalPosition = box.localToGlobal(Offset.zero);

      final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
      final browserState = Provider.of<BrowserState>(context, listen: false);

      if (browserState.animationsStarted[widget.position] ?? true) return;
      final shouldBeHighlighted = treeTraverser.focusNode == widget.treeItem;
      if (!shouldBeHighlighted) return;

      browserState.animationsStarted[widget.position] = true;

      if (shouldBeHighlighted) {
        widget.highlightIndicatorKey.currentState?.animate(globalPosition.dx, globalPosition.dy, box.size.width, box.size.height);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // void _startAnimation(BrowserState browserState, BrowserController browserController, TreeTraverser treeTraverser) {
  //   if (browserState.animationsStarted[widget.position] ?? true) return;
  //   final shouldBeHighlighted = treeTraverser.focusNode == widget.treeItem;
  //   const shouldBeMoved = false; // (browserController.topOffsetAnimations[widget.position] ?? 0) != 0;
  //   if (!shouldBeHighlighted && !shouldBeMoved) return;

  //   browserState.animationsStarted[widget.position] = true;
  //   setState(() {
  //     if (shouldBeHighlighted) {
  //       highlighted = true;
  //     }
  //     // if (shouldBeMoved) {
  //     //   animationTopOffset = browserController.topOffsetAnimations[widget.position] ?? 0;
  //     // }
  //   });
  //   _timer = Timer(Duration(milliseconds: 10), () {
  //     browserController.topOffsetAnimations[widget.position] = 0;
  //     setState(() {
  //       highlighted = false;
  //       animationTopOffset = 0;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    // _startAnimation(browserState, browserController, treeTraverser);

    var inkWell = InkWell(
      key: _inkWellKey,
      onTap: () {
        safeExecute(() async {
          await browserController.handleNodeTap(widget.treeItem, widget.position);
        });
      },
      onTapUp: (TapUpDetails details) {
        widget.rippleIndicatorKey.currentState?.startRipple(details.globalPosition.dx, details.globalPosition.dy);
      },
      onLongPress: () {
        showNodeOptionsDialog(context, widget.treeItem, widget.position);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        padding: const EdgeInsets.all(0.0),
        margin: EdgeInsets.only(top: animationTopOffset),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: const Color(0x44888888),
              width: 0.5,
              style: BorderStyle.solid,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
        child: TreeItemRow(position: widget.position, treeItem: widget.treeItem),
      ),
    );

    if (!settingsProvider.slidableActions) {
      return inkWell;
    }

    return Slidable(
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
  }
}

class TreeItemRow extends StatelessWidget {
  const TreeItemRow({
    super.key,
    required this.position,
    required this.treeItem,
  });

  final int position;
  final TreeNode treeItem;

  @override
  Widget build(BuildContext context) {
    final browserState = context.watch<BrowserState>();
    final selectionMode = browserState.selectedIndexes.isNotEmpty;
    final isItemSelected = browserState.selectedIndexes.contains(position);
    final browserController = Provider.of<BrowserController>(context, listen: false);

    return Row(
      children: [
        buildLeftIcon(selectionMode, isItemSelected, browserController),
        buildMiddleText(context),
        buildMoreActionButton(context),
        selectionMode ? null : buildMiddleActionButton(context),
        selectionMode ? null : buildAddButton(browserController),
      ].filterNotNull(),
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
              browserController.onToggleSelectedNode(position);
            });
          },
        ),
      );
    } else {
      return ReorderableDragStartListener(
        index: position,
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
            browserController.onToggleSelectedNode(position);
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            treeTraverser.displayLinkName(treeItem),
            style: TextStyle(
              color: Color(0xFFD2D2D2),
              fontSize: 18,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      );
    } else if (treeItem.isLeaf) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            treeItem.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
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
                  treeItem.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3),
            RoundedBadge(text: treeItem.size.toString()),
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
        showNodeOptionsDialog(context, treeItem, position);
      },
    );
  }

  Widget buildMiddleActionButton(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context, listen: false);
    if (treeItem.isLeaf) {
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
            browserController.goIntoNode(treeItem);
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
            browserController.editNode(treeItem);
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
          browserController.addNodeAt(position);
        });
      },
    );
  }
}


void showNodeOptionsDialog(BuildContext context, TreeNode treeItem, int position) {
  final browserController = Provider.of<BrowserController>(context, listen: false);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return NodeMenuDialog.buildForNode(context, treeItem, position);
    },
  ).then((value) {
    if (value != null) {
      browserController.runNodeMenuAction(value, node: treeItem, position: position);
    }
  });
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
