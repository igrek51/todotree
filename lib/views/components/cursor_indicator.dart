import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:todotree/model/tree_node.dart';
import 'package:todotree/util/errors.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/util/numbers.dart';
import 'package:todotree/views/components/ripple_indicator.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';

class CursorIndicator extends StatefulWidget {
  CursorIndicator({
    super.key,
    required this.rippleIndicatorKey,
  });

  final GlobalKey<RippleIndicatorState> rippleIndicatorKey;

  @override
  State<CursorIndicator> createState() => CursorIndicatorState();
}

const double cursrorDiameter = 20;
const double brakeFactor = 0.99;
const double alignFactor = 1.1;
const double velocityTransmission = 1.1;
const double dragTransmission = 1.4;
const double overscrollTransmission = 4;
const double swipeDistanceThreshold = 90.0;
const double swipeAngleThreshold = 30;
const double overscrollArea = 100;
const double touchpadHeight = 200;

class CursorIndicatorState extends State<CursorIndicator> with TickerProviderStateMixin {
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
    lowerBound: 0.0,
  );
  Offset _offset = Offset.zero;
  Offset _velocity = Offset.zero;
  GlobalKey _boxKey = GlobalKey();
  int lastTickTimestampUs = 0;
  bool dragging = false;
  Offset dragStartPos = Offset.zero;
  Offset dragDelta = Offset.zero;
  double w = 0;
  double h = 0;

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void frameTick(BuildContext context) {
    final nowUs = DateTime.now().microsecondsSinceEpoch;
    if (lastTickTimestampUs == 0) {
      lastTickTimestampUs = nowUs;
    }
    final durationUs = nowUs - lastTickTimestampUs;
    double timeScale = durationUs / 1000000.0;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (w == 0) {
      w = renderBox?.size.width ?? 0;
      _offset = Offset(w/2, _offset.dy);
    }
    w = renderBox?.size.width ?? 0;
    h = ((renderBox?.size.height ?? 0) - touchpadHeight).clampMin(0);

    final browserState = Provider.of<BrowserState>(context, listen: false);

    if (!dragging) {
      double offsetX = (_offset.dx + _velocity.dx * velocityTransmission * timeScale).clamp(0, w);
      double offsetY = (_offset.dy + _velocity.dy * velocityTransmission * timeScale).clamp(0, h);
      double velocityX = _velocity.dx * pow(1 - brakeFactor, timeScale);
      double velocityY = _velocity.dy * pow(1 - brakeFactor, timeScale);
      offsetX += (w / 2 - offsetX) * alignFactor * timeScale;

      _offset = Offset(offsetX, offsetY);
      _velocity = Offset(velocityX, velocityY);
    }

    if (browserState.scrollController.hasClients) {
      double scroll = browserState.scrollController.offset;

      final overscrollUp = overscrollArea - _offset.dy;
      if (overscrollUp > 0 && scroll > 0) {
        browserState.scrollController.jumpTo(
          scroll - overscrollUp * overscrollTransmission * timeScale,
        );
      }
      final overscrollDown = _offset.dy + overscrollArea - h;
      if (overscrollDown > 0) {
        browserState.scrollController.jumpTo(
          scroll + overscrollDown * overscrollTransmission * timeScale,
        );
      }
    }
 
    lastTickTimestampUs = nowUs;
  }

  void onTap(BrowserController browserController) {
    dragging = false;
    if (_velocity.distance > 50.0) {
      logger.debug('Gesture: TAP - stop velocity');
      _velocity = Offset.zero;
      return;
    }

    _velocity = Offset.zero;
    final (itemIndex, treeItem) = findHoveredItem(browserController);

    logger.debug('Gesture: TAP - click item: $itemIndex');
    widget.rippleIndicatorKey.currentState?.animateLocal(_offset.dx, _offset.dy);
    if (treeItem != null && itemIndex != null) {
      safeExecute(() async {
        await browserController.handleNodeTap(treeItem, itemIndex);
      });
    }
  }

  void onDragStart(DragStartDetails details) {
    dragging = true;
    dragStartPos = details.globalPosition;
  }

  void onDragUpdate(DragUpdateDetails details) {
    var dx = details.delta.dx;
    var dy = details.delta.dy;

    _offset = Offset(_offset.dx + dx * dragTransmission, _offset.dy + dy * dragTransmission);
    _velocity = Offset.zero;

    dragDelta = details.globalPosition - dragStartPos;

    lastTickTimestampUs = DateTime.now().microsecondsSinceEpoch;
    _animController.forward(from: 0);
  }

  void onDragEnd(DragEndDetails details, BrowserController browserController) {
    dragging = false;

    _velocity = details.velocity.pixelsPerSecond;

    if (dragDelta.distance >= swipeDistanceThreshold) {
      final angle = dragDelta.direction * 180.0 / pi; // [0; 180] on top, [0; -180] on bottom

      if (angle >= 180 - swipeAngleThreshold || angle <= -180 + swipeAngleThreshold) {
        logger.debug('Gesture: Swipe left');
        _velocity = Offset.zero;
        browserController.goBack();

      } else if (angle <= swipeAngleThreshold && angle >= -swipeAngleThreshold) {
        final (itemIndex, treeItem) = findHoveredItem(browserController);
        if (itemIndex != null && treeItem != null) {
          _velocity = Offset.zero;
          logger.debug('Gesture: Swipe right on item: $itemIndex');
          widget.rippleIndicatorKey.currentState?.animateLocal(_offset.dx, _offset.dy);
          safeExecute(() async {
            await browserController.goIntoNode(treeItem);
          });
        }
      }
    }
  }

  void goIntoHoveredItem(BrowserController browserController) {
    final (itemIndex, treeItem) = findHoveredItem(browserController);
    if (itemIndex != null && treeItem != null) {
      safeExecute(() async {
        await browserController.goIntoNode(treeItem);
      });
    }
  }

  void addAboveHoveredItem(BrowserController browserController) {
    final (itemIndex, treeItem) = findHoveredItem(browserController);
    if (itemIndex != null && treeItem != null) {
      safeExecute(() {
        browserController.addNodeAt(itemIndex);
      });
    } else {
      safeExecute(() {
        browserController.addNodeToTheEnd();
      });
    }
  }

  void moreOptionsOnHoveredItem(BrowserController browserController) {
    final (itemIndex, treeItem) = findHoveredItem(browserController);
    if (itemIndex != null && treeItem != null) {
      safeExecute(() {
        browserController.showItemOptionsDialog(treeItem, itemIndex);
      });
    } else {
      safeExecute(() {
        browserController.showPlusOptionsDialog();
      });
    }
  }

  (int?, TreeNode?) findHoveredItem(BrowserController browserController) {
    double scroll = 0;
    if (browserController.browserState.scrollController.hasClients) {
      scroll = browserController.browserState.scrollController.offset;
    }
    int itemsCount = browserController.browserState.items.length;
    var itemIndex = findItemIndexByOffset(_offset.dy + scroll, itemsCount, browserController.itemHeights);

    if (itemIndex == null) {
      return (null, null);
    }

    var treeItem = browserController.browserState.items[itemIndex];
    return (itemIndex, treeItem);
  }

  int? findItemIndexByOffset(double y, int itemsCount, Map<int, double> itemHeights) {
    double bufferY = y;
    for (var i = 0; i < itemsCount; i++) {
      var itemHeight = itemHeights[i] ?? 0;
      if (bufferY < itemHeight) {
        return i;
      }
      bufferY -= itemHeight;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _animController, curve: Curves.linear),
      builder: (context, child) {
        frameTick(context);
        return Stack(
          key: _boxKey,
          children: [
            Positioned(
              left: _offset.dx - cursrorDiameter / 2,
              top: _offset.dy - cursrorDiameter / 2,
              child: Container(
                width: cursrorDiameter,
                height: cursrorDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 241, 165, 77).withOpacity(0.6 * (1 - _animController.value) + 0.1),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
