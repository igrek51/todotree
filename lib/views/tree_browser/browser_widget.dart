import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/services/settings_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todotree/util/collections.dart';
import 'package:todotree/util/errors.dart';

import 'package:todotree/views/components/cursor_indicator.dart';
import 'package:todotree/views/components/cursor_indicator.dart' as cursor_indicator;
import 'package:todotree/views/components/explosion_indicator.dart';
import 'package:todotree/views/components/ripple_indicator.dart';
import 'package:todotree/views/home/home_controller.dart';
import 'package:todotree/views/tree_browser/browser_controller.dart';
import 'package:todotree/views/tree_browser/browser_state.dart';
import 'package:todotree/views/tree_browser/plus_item.dart';
import 'package:todotree/views/tree_browser/tree_item.dart';

class BrowserWidget extends StatefulWidget {
  const BrowserWidget({super.key});

  @override
  State<BrowserWidget> createState() => _BrowserWidgetState();
}

class _BrowserWidgetState extends State<BrowserWidget> {
  final GlobalKey<RippleIndicatorState> _rippleIndicatorKey = GlobalKey<RippleIndicatorState>();
  final GlobalKey<CursorIndicatorState> _cursorIndicatorKey = GlobalKey<CursorIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    var cursorIndicator = settingsProvider.cursorNavigator
        ? CursorIndicator(key: _cursorIndicatorKey, rippleIndicatorKey: _rippleIndicatorKey)
        : null;
    return Stack(
      children: [
        RippleIndicator(key: _rippleIndicatorKey),
        cursorIndicator,
        ExplosionIndicator(key: explosionIndicatorKey),
        TreeListView(rippleIndicatorKey: _rippleIndicatorKey, cursorIndicatorKey: _cursorIndicatorKey),
      ].filterNotNull(),
    );
  }
}

class TreeListView extends StatelessWidget {
  const TreeListView({
    super.key,
    required this.rippleIndicatorKey,
    required this.cursorIndicatorKey,
  });

  final GlobalKey<RippleIndicatorState> rippleIndicatorKey;
  final GlobalKey<CursorIndicatorState> cursorIndicatorKey;

  @override
  Widget build(BuildContext context) {
    final browserState = context.watch<BrowserState>();
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    Widget listview = ReorderableListView.builder(
      onReorder: (int oldIndex, int newIndex) {
        browserController.reorderNodes(oldIndex, newIndex);
      },
      buildDefaultDragHandles: false,
      scrollController: browserState.scrollController,
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return Material(
          elevation: 4.0,
          color: Color(0x5ABEBEBE),
          child: child,
        );
      },
      physics: AlwaysScrollableScrollPhysics(),
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

    if (settingsProvider.slidableActions) {
      listview = SlidableAutoCloseBehavior(
        child: listview,
      );
    }

    if (settingsProvider.cursorNavigator) {
      final homeController = Provider.of<HomeController>(context, listen: false);
      listview = Column(
        children: [
          Expanded(child: listview),
          GestureDetector(
            onTap: () {
              cursorIndicatorKey.currentState?.onTap(browserController);
            },
            onPanStart: (DragStartDetails details) {
              cursorIndicatorKey.currentState?.onDragStart(details);
            },
            onPanUpdate: (DragUpdateDetails details) {
              cursorIndicatorKey.currentState?.onDragUpdate(details);
            },
            onPanEnd: (DragEndDetails details) {
              cursorIndicatorKey.currentState?.onDragEnd(details, browserController);
            },
            child: Card(
              color: Color(0x5ABEBEBE),
              child: SizedBox(
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
                          icon: Icon(Icons.keyboard_arrow_right, size: 32),
                          onPressed: () {
                            safeExecute(() {
                              cursorIndicatorKey.currentState?.goIntoHoveredItem(browserController);
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 32),
                          onPressed: () {
                            safeExecute(() {
                              cursorIndicatorKey.currentState?.addAboveHoveredItem(browserController);
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert, size: 32),
                          onPressed: () {
                            safeExecute(() {
                              cursorIndicatorKey.currentState?.moreOptionsOnHoveredItem(browserController);
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
        ],
      );
    }

    return listview;
  }
}
