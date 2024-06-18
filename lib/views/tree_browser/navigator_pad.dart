import 'package:flutter/material.dart';
import 'package:todotree/util/errors.dart';
import 'package:provider/provider.dart';

import 'package:todotree/views/components/cursor_indicator.dart';
import 'package:todotree/views/components/cursor_indicator.dart' as cursor_indicator;
import 'package:todotree/views/home/home_controller.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';

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
    final browserState = context.watch<BrowserState>();

    if (browserState.cursorNavigatorCollapsed) {
      return Card(
        color: const Color(0x39BEBEBE),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.keyboard_arrow_up, size: 32),
              onPressed: () {
                safeExecute(() {
                  cursorIndicatorKey.currentState?.expandNavigatorPad();
                });
              },
            ),
          ],
        ),
      );
    }

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
            height: cursor_indicator.touchpadHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_left, size: 32),
                  onPressed: () {
                    safeExecute(() async {
                      await homeController.goBack();
                    });
                  },
                ),
                SizedBox(
                  width: cursor_indicator.touchpadWidth,
                ),
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
                Spacer(),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down, size: 32),
                  onPressed: () {
                    safeExecute(() {
                      cursorIndicatorKey.currentState?.collapseNavigatorPad();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
