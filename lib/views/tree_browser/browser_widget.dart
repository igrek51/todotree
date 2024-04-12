import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:todotree/util/collections.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/services/tree_traverser.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/views/components/explosion_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    var stack = Stack(
      children: [
        RippleIndicator(key: _rippleIndicatorKey),
        ExplosionIndicator(key: explosionIndicatorKey),
        TreeListView(rippleIndicatorKey: _rippleIndicatorKey),
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
  });

  final GlobalKey<RippleIndicatorState> rippleIndicatorKey;

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
      physics: BouncingScrollPhysics().applyTo(AlwaysScrollableScrollPhysics()),
      itemCount: browserState.items.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index < browserState.items.length) {
          final item = browserState.items[index];
          return TreeListItemWidget(
            key: Key(identityHashCode(item).toString()),
            position: index,
            treeItem: item,
            rippleIndicatorKey: rippleIndicatorKey,
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
  });

  final int position;
  final TreeNode treeItem;
  final GlobalKey<RippleIndicatorState> rippleIndicatorKey;

  @override
  State<TreeListItemWidget> createState() => TreeListItemWidgetState();
}

class TreeListItemWidgetState extends State<TreeListItemWidget> with TickerProviderStateMixin {
  late final AnimationController _offsetAnimator = AnimationController(
    value: 1,
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final AnimationController _highlightAnimator = AnimationController(
    value: 1,
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final CurvedAnimation _offsetAnimation = CurvedAnimation(parent: _offsetAnimator, curve: Curves.bounceOut);
  late final CurvedAnimation _highlightAnimation = CurvedAnimation(parent: _highlightAnimator, curve: Curves.linear);
  double animationTopOffset = 0;
  bool animatingHighlight = false;
  final _inkWellKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _inkWellKey.currentContext;
      if (context == null) return;
      final renderBox = context.findRenderObject() as RenderBox;
      final height = renderBox.size.height;
      final browserController = Provider.of<BrowserController>(context, listen: false);
      browserController.itemHeights[widget.position] = height;
    });
    super.initState();
  }

  @override
  void dispose() {
    _offsetAnimator.dispose();
    _highlightAnimator.dispose();
    super.dispose();
  }

  void _startHighlightAnimation(BrowserController browserController) {
    if (!browserController.highlightAnimationRequests.containsKey(widget.position)) return;
    animatingHighlight = true;
    browserController.highlightAnimationRequests.remove(widget.position);
    _highlightAnimator.forward(from: 0).then((value) {
      animatingHighlight = false;
      browserController.highlightAnimationDone();
    });
  }

  void _startOffsetAnimation(BrowserController browserController) {
    if (!browserController.offsetAnimationRequests.containsKey(widget.position)) return;
    animationTopOffset = browserController.offsetAnimationRequests[widget.position] ?? 0;
    browserController.offsetAnimationRequests.remove(widget.position);
    _offsetAnimator.forward(from: 0).then((value) {
      animationTopOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    _startHighlightAnimation(browserController);
    _startOffsetAnimation(browserController);

    var inkWell = AnimatedBuilder(
      animation: Listenable.merge([_offsetAnimator, _highlightAnimator]), // Listenable triggerring repainting
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            key: _inkWellKey,
            onTapUp: (TapUpDetails details) {
              widget.rippleIndicatorKey.currentState?.animate(details.globalPosition.dx, details.globalPosition.dy);
            },
            onTap: () {
              safeExecute(() async {
                await browserController.handleNodeTap(widget.treeItem, widget.position);
              });
            },
            onLongPress: () {
              showNodeOptionsDialog(context, widget.treeItem, widget.position);
            },
            child: Container(
              padding: const EdgeInsets.all(0.0),
              margin: EdgeInsets.only(top: (1 - _offsetAnimation.value) * animationTopOffset),
              decoration: BoxDecoration(
                color: animatingHighlight
                    ? const Color.fromARGB(199, 53, 156, 240).withOpacity(1 - _highlightAnimation.value)
                    : Colors.transparent,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: const Color(0x44888888),
                    width: 0.5,
                    style: BorderStyle.solid,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
              ),
              child: TreeItemRow(
                position: widget.position,
                treeItem: widget.treeItem,
                rippleIndicatorKey: widget.rippleIndicatorKey,
              ),
            ),
          ),
        );
      },
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
    required this.rippleIndicatorKey,
  });

  final int position;
  final TreeNode treeItem;
  final GlobalKey<RippleIndicatorState> rippleIndicatorKey;

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
        selectionMode ? null : buildMiddleActionButton(context, browserController),
        selectionMode ? null : buildAddButton(browserController),
      ].filterNotNull(),
    );
  }

  Widget buildLeftIcon(bool selectionMode, bool isItemSelected, BrowserController browserController) {
    if (selectionMode) {
      Widget sizedBoxChild = GestureDetector(
        onLongPress: () {
          safeExecute(() {
            browserController.onLongToggleSelectedNode(position);
          });
        },
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
      if (isItemSelected) {
        sizedBoxChild = ReorderableDragStartListener(
          index: position,
          child: sizedBoxChild,
        );
      }
      return SizedBox(
        width: 40,
        child: sizedBoxChild,
      );
    } else {
      return ReorderableDragStartListener(
        index: position,
        child: GestureDetector(
          onLongPress: () {
            safeExecute(() {
              browserController.onToggleSelectedNode(position);
            });
          },
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
              safeExecute(() {
                browserController.onToggleSelectedNode(position);
              });
            },
          ),
        ),
      );
    }
  }

  Widget buildMiddleText(BuildContext context) {
    final treeTraverser = Provider.of<TreeTraverser>(context, listen: false);
    var child = switch (true) {
      true when treeItem.isLink => Container(
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
      true when treeItem.isLeaf => Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            treeItem.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      _ => Row(
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
        )
    };
    return Expanded(child: child);
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
        var (_, centerY, w, _) = getRenderBoxCoordinates(context);
        rippleIndicatorKey.currentState?.animate(w - 32 - 32 - 32 / 2, centerY);
      },
    );
  }

  Widget buildMiddleActionButton(BuildContext context, BrowserController browserController) {
    if (treeItem.isLeaf) {
      return Tooltip(
        message: 'Go into',
        child: IconButton(
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
              var (_, centerY, w, _) = getRenderBoxCoordinates(context);
              rippleIndicatorKey.currentState?.animate(w - 32 - 32 / 2, centerY);
            });
          },
        ),
      );
    } else {
      return Tooltip(
        message: 'Edit',
        child: IconButton(
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
        ),
      );
    }
  }

  Widget buildAddButton(BrowserController browserController) {
    return Tooltip(
      message: 'Add above',
      child: IconButton(
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
      ),
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
          height: 55,
          child: Center(
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

(double, double, double, double) getRenderBoxCoordinates(BuildContext context) {
  final RenderBox renderBox = context.findRenderObject() as RenderBox;
  Offset boxGlobalPos = renderBox.localToGlobal(Offset.zero);
  final centerX = boxGlobalPos.dx + renderBox.size.width / 2;
  final centerY = boxGlobalPos.dy + renderBox.size.height / 2;
  return (centerX, centerY, renderBox.size.width, renderBox.size.height);
}
