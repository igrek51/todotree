import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:swipe_to/swipe_to.dart';

import 'package:todotree/util/errors.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/views/components/ripple_indicator.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';
import 'package:todotree/views/tree_browser/tree_item_row.dart';

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
  double _iconButtonPaddingV = 11.0;

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

    _iconButtonPaddingV = switch (settingsProvider.largeFont) {
      true => 11.0,
      false => 9.0,
    };

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
              safeExecute(() {
                browserController.showItemOptionsDialog(widget.treeItem, widget.position);
              });
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
                iconButtonPaddingV: _iconButtonPaddingV,
              ),
            ),
          ),
        );
      },
    );

    if (settingsProvider.slidableActions) {
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
    } else if (settingsProvider.swipeNavigation) {
      return SwipeTo(
        key: UniqueKey(),
        iconOnLeftSwipe: Icons.arrow_back,
        onLeftSwipe: (details) {
          browserController.goBack();
        },
        iconOnRightSwipe: Icons.arrow_right,
        onRightSwipe: (details) {
          safeExecute(() async {
            await browserController.goIntoNode(widget.treeItem);
          });
        },
        swipeSensitivity: 5,
        child: inkWell,
      );
    }

    return inkWell;
  }
}
