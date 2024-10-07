import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todotree/settings/settings_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:todotree/components/cursor_indicator.dart';
import 'package:todotree/components/explosion_indicator.dart';
import 'package:todotree/components/ripple_indicator.dart';
import 'package:todotree/home/home_controller.dart';
import 'package:todotree/tree_browser/browser_controller.dart';
import 'package:todotree/tree_browser/browser_state.dart';
import 'package:todotree/tree_browser/cursor_state.dart';
import 'package:todotree/tree_browser/navigator_pad.dart';
import 'package:todotree/tree_browser/plus_item.dart';
import 'package:todotree/tree_browser/tree_item.dart';

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
    final browserController = Provider.of<BrowserController>(context, listen: false);
    final browserStateImmut = Provider.of<BrowserState>(context, listen: false);
    final cursorStateImmut = Provider.of<CursorState>(context, listen: false);
    cursorStateImmut.cursorNavigator = settingsProvider.cursorNavigator;
    return Stack(
      children: [
        RippleIndicator(key: _rippleIndicatorKey),
        CursorIndicator(
            key: _cursorIndicatorKey,
            rippleIndicatorKey: _rippleIndicatorKey,
            browserController: browserController,
            cursorState: cursorStateImmut,
            browserState: browserStateImmut,
          ),
        ExplosionIndicator(key: explosionIndicatorKey),
        TreeListView(rippleIndicatorKey: _rippleIndicatorKey, cursorIndicatorKey: _cursorIndicatorKey),
      ],
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
    final cursorState = context.watch<CursorState>();
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

    if (cursorState.cursorNavigator) {
      final homeController = Provider.of<HomeController>(context, listen: false);
      listview = Column(
        children: [
          Expanded(child: listview),
          NavigatorPad(cursorIndicatorKey: cursorIndicatorKey, homeController: homeController),
        ],
      );
    }

    return listview;
  }
}
