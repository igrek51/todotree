import 'package:flutter/material.dart';
import 'package:todotree/util/errors.dart';

import 'package:todotree/views/components/cursor_indicator.dart';
import 'package:todotree/views/components/cursor_indicator.dart' as cursor_indicator;
import 'package:todotree/views/home/home_controller.dart';

class NavigatorPad extends StatelessWidget {
  const NavigatorPad({
    super.key,
    required this.cursorIndicatorKey,
    required this.homeController,
  });

  final GlobalKey<CursorIndicatorState> cursorIndicatorKey;
  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        cursorIndicatorKey.currentState?.onTap();
      },
      onPanStart: (DragStartDetails details) {
        cursorIndicatorKey.currentState?.onDragStart(details);
      },
      onPanUpdate: (DragUpdateDetails details) {
        cursorIndicatorKey.currentState?.onDragUpdate(details);
      },
      onPanEnd: (DragEndDetails details) {
        cursorIndicatorKey.currentState?.onDragEnd(details);
      },
      child: Card(
        color: const Color(0x39BEBEBE),
        child: Center(
          child: SizedBox(
            width: cursor_indicator.touchpadWidth,
            height: cursor_indicator.touchpadHeight,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left, size: 32),
                  onPressed: () {
                    safeExecute(() async {
                      await homeController.goBack();
                    });
                  },
                ),
                Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, size: 32),
                      onPressed: () {
                        safeExecute(() {
                          cursorIndicatorKey.currentState?.addAboveHoveredItem();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_right, size: 32),
                      onPressed: () {
                        safeExecute(() {
                          cursorIndicatorKey.currentState?.goIntoHoveredItem();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, size: 32),
                      onPressed: () {
                        safeExecute(() {
                          cursorIndicatorKey.currentState?.moreOptionsOnHoveredItem();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
