import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:todotree/util/logger.dart';
import 'package:todotree/util/numbers.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';

class CursorIndicator extends StatefulWidget {
  CursorIndicator({super.key});

  @override
  State<CursorIndicator> createState() => CursorIndicatorState();
}

const double diameter = 25;
const brakeFactor = 0.999;
const velocityTransmission = 1.0;

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
    double w = renderBox?.size.width ?? 0;
    double h = ((renderBox?.size.height ?? 0) - 200).clampMin(0);

    final browserState = Provider.of<BrowserState>(context, listen: false);

    if (!dragging) {
      double offsetX = (_offset.dx + _velocity.dx * velocityTransmission * timeScale).clamp(0, w);
      double offsetY = (_offset.dy + _velocity.dy * velocityTransmission * timeScale).clamp(0, h);
      double velocityX = _velocity.dx * pow(1 - brakeFactor, timeScale);
      double velocityY = _velocity.dy * pow(1 - brakeFactor, timeScale);

      _offset = Offset(offsetX, offsetY);
      _velocity = Offset(velocityX, velocityY);
    }

    if (dragging && browserState.scrollController.hasClients) {
      double scroll = browserState.scrollController.offset;

      final overscrollUp = 100 - _offset.dy;
      if (overscrollUp > 0) {
        browserState.scrollController.jumpTo(
          scroll - overscrollUp * timeScale,
        );
      }
      final overscrollDown = _offset.dy + 100 - h;
      if (overscrollDown > 0) {
        browserState.scrollController.jumpTo(
          scroll + overscrollDown * timeScale,
        );
      }
    }

    lastTickTimestampUs = nowUs;
  }

  void onTap() {
    dragging = false;
    if (_velocity.distance > 1.0) {
      logger.debug('Gesture: TAP - stop velocity');
      _velocity = Offset.zero;
    } else {
      logger.debug('Gesture: TAP - click item');
      _velocity = Offset.zero;
    }
  }

  void onDragStart(DragStartDetails details) {
    logger.debug('Gesture: onPanStart: ${details.globalPosition}');
    dragging = true;
    dragStartPos = details.globalPosition;
  }

  void onDragUpdate(DragUpdateDetails details) {
    logger.debug('Gesture: onPanUpdate: ${details.delta}, ${details.globalPosition}');
    var dx = details.delta.dx;
    var dy = details.delta.dy;

    _offset = Offset(_offset.dx + dx, _offset.dy + dy);
    _velocity = Offset.zero;

    dragDelta = details.globalPosition - dragStartPos;

    lastTickTimestampUs = DateTime.now().microsecondsSinceEpoch;
    _animController.forward(from: 0);
  }

  void onDragEnd(DragEndDetails details) {
    logger.debug('Gesture: onPanEnd: ${details.velocity}');
    dragging = false;

    _velocity = details.velocity.pixelsPerSecond;

    if (dragDelta.distance >= 100.0) {
      const swipeAngleThreshold = 30;
      final angle = dragDelta.direction * 180.0 / pi; // [0; 180] on top, [0; -180] on bottom
      logger.debug('Gesture: angle: $angle');
      if (angle >= 180 - swipeAngleThreshold || angle <= -180 + swipeAngleThreshold) {
        logger.debug('Gesture: Swipe left');
      } else if (angle <= swipeAngleThreshold && angle >= -swipeAngleThreshold) {
        logger.debug('Gesture: Swipe right');
      }
    }
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
              left: _offset.dx - diameter / 2,
              top: _offset.dy - diameter / 2,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 241, 165, 77).withOpacity(0.5 * (1 - _animController.value) + 0.2),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
